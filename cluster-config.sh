#!/bin/bash

export CONTROL_PLANE_IP="192.168.64.2"
WORKER_IP=("192.168.64.3" "192.168.64.4")
export CLUSTER_NAME="cuttlefish"
export DISK_NAME="vda"

## Generate cluster configuration files

talosctl gen config $CLUSTER_NAME https://$CONTROL_PLANE_IP:6443 --install-disk /dev/$DISK_NAME
talosctl config merge ./talosconfig

## Apply conifguration files

talosctl apply-config --insecure --nodes $CONTROL_PLANE_IP --file controlplane.yaml

for ip in "${WORKER_IP[@]}"; do
    echo "Applying config to worker node: $ip"
    talosctl apply-config --insecure --nodes "$ip" --file worker.yaml
done

talosctl --talosconfig=./talosconfig config endpoints $CONTROL_PLANE_IP

## Bootstrap etcd

sleep 180
talosctl bootstrap --nodes $CONTROL_PLANE_IP --talosconfig=./talosconfig

## Patch Pod Security for Open-telemetry
for ip in "${WORKER_IP[@]}"; do
    echo "Patching worker node: $ip"
    talosctl patch mc --patch @./patches/podsecurity_patch.yaml -n $ip
done


## Generate kubeconfig
talosctl kubeconfig ~/.kube/contexts/cuttlefish.yaml --nodes $CONTROL_PLANE_IP --talosconfig=./talosconfig
export KUBECONFIG=~/.kube/contexts/cuttlefish.yaml

## Apply configuration patches

