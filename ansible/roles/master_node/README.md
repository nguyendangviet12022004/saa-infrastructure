# master_node

Runs `kubeadm init` once on a prepared node. Override `master_node_kubeadm_init_extra_args` to set the pod CIDR or other kubeadm options. The default pod CIDR is `10.244.0.0/16`.

After initialization, install a CNI plugin whose pod CIDR matches the configured value, then generate a worker join command with `kubeadm token create --print-join-command`.
