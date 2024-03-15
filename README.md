# k8s-talos
A single node k8s cluster running on a Talos Linux

## Basic Configuration

Generate configuration:
`talosctl gen config kubernetes https://192.168.5.136:6443`

Apply configuration:
`talosctl apply-config --insecure -n 192.168.5.136 --file controlplane.yaml`

Bootstrap cluster
`talosctl bootstrap --nodes 192.168.5.136 --endpoints 192.168.5.136 --talosconfig=./talosconfig`

Merge talos config
`talosctl config merge ./talosconfig`
Note: edit ~/.talos/config, correct endpoint ip and add nodes beneath control plane

Patch controlplane for single node clusters\
`talosctl patch mc --patch @controlplane_patch.yaml `

Patch Pod Security for Open-telemetry
`talosctl patch mc --patch @podsecurity_patch.yaml`

Generate kubeconfig
`talosctl kubeconfig`

