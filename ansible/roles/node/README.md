# node

Prepares Ubuntu 22.04/24.04 hosts for kubeadm: disables swap, configures kernel networking, installs containerd, and installs pinned kubelet/kubeadm/kubectl packages from the Kubernetes community apt repository.

Set `node_kubernetes_minor_version` to the desired Kubernetes minor release (defaults to `1.37`). Override `node_runtime_sysctls` or `node_kubernetes_packages` as needed.
