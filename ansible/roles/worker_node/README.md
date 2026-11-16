# worker_node

Requires `worker_node_kubeadm_join_command` to contain the join command produced by the control plane. The role prepares the host through its `node` dependency and runs the join command once.
