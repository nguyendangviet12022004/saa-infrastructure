# master_node

Runs `kubeadm init` once on a prepared node. Override
`master_node_kubeadm_init_extra_args` to set the pod CIDR or other kubeadm
options. Set `master_node_api_server_cert_extra_sans` to the public IPs or DNS
names used by kubectl. The default pod CIDR is `10.244.0.0/16`.

After initialization, the role downloads the admin kubeconfig to
`.kube/config` in the repository. Install a CNI plugin whose pod CIDR matches
the configured value, then generate a worker join command with
`kubeadm token create --print-join-command`.

The role now runs that command automatically and shares it with the
`worker_node` play. You normally do not need to copy the join command into the
inventory manually.

Use the downloaded configuration from the repository root:

```sh
export KUBECONFIG="$PWD/.kube/config"
kubectl get nodes
```

The kubeconfig contains cluster-admin credentials and is ignored by Git.
