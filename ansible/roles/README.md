# Kubernetes cluster setup guide

This guide brings up the dev kubeadm cluster using Terraform EC2 instances and
the `node`, `master_node`, and `worker_node` roles. Run commands from the
repository root unless stated otherwise. The examples use Ubuntu 24.04 and
the default pod CIDR `10.244.0.0/16`.

## 1. Configure access and provision the nodes

In `terraform/environments/dev/terraform.tfvars`, set an EC2 key pair that
exists in the selected AWS region, then allow SSH and Kubernetes API access
from your administrator IP or network. For example:

```hcl
key_name  = "my-dev-key"
ssh_cidrs = ["198.51.100.25/32"]
api_cidrs = ["198.51.100.25/32"]
```

Replace the example CIDR with your actual public IP in CIDR notation. Leave
`node_subnet_ids = null` to use the generated public subnets, or provide subnet
IDs to change placement. A `subnet_id` can also be set on an individual node.
The default dev configuration creates one control plane and two workers. EC2
`Name` tags use `<project>-<environment>-<node-key>`, such as
`saa-dev-master-1`.

Provision the network and instances:

```sh
terraform -chdir=terraform/environments/dev init
terraform -chdir=terraform/environments/dev plan
terraform -chdir=terraform/environments/dev apply
```

The SSH username for the Ubuntu AMI is `ubuntu`. Use the private key matching
the EC2 key pair selected above.

## 2. Install the Ansible collection and fill the inventory

The node role uses `ansible.posix.sysctl`. Install the collection:

```sh
ansible-galaxy collection install -r ansible/requirements.yml
```

Get the EC2 public IPs:

```sh
terraform -chdir=terraform/environments/dev output kubernetes_public_ips
```

Edit `ansible/inventories/dev/hosts.yml` and replace the three
`REPLACE_WITH_*_PUBLIC_IP` placeholders. If your key is not loaded in
`ssh-agent`, set `ansible_ssh_private_key_file` under `all.vars`, for example:

```yaml
ansible_ssh_private_key_file: /home/me/.ssh/my-dev-key.pem
```

Check connectivity:

```sh
ansible all -m ping
```

## 3. Initialize the control plane

The `node` role runs as a dependency of `master_node` and `worker_node`. It
disables swap, loads kernel networking modules, configures sysctls and
containerd, and installs kubelet, kubeadm, and kubectl. The `master_node` role
then initializes the cluster with the configured pod CIDR.

Run only the master play first:

```sh
ansible-playbook ansible/playbooks/kubernetes.yml --limit master_node
```

The equivalent core Linux command is:

```sh
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
```

To change the CIDR, set `master_node_kubeadm_init_extra_args` in inventory or
group variables, then configure the CNI with the same CIDR.

## 4. Install a pod network (CNI)

`kubeadm init` does not install a pod network. Choose a CNI plugin and follow
its current installation instructions. The plugin must support the configured
pod CIDR. Flannel is one option for `10.244.0.0/16`; see the
[Flannel project instructions](https://github.com/flannel-io/flannel) for
current installation details.

For example, after installing Helm on the machine with the cluster kubeconfig:

```sh
helm repo add flannel https://flannel-io.github.io/flannel/
helm repo update
helm install flannel --set podCidr="10.244.0.0/16" \
  --namespace kube-flannel --create-namespace flannel/flannel
```

The cluster security group allows the Kubernetes API, etcd, kubelet,
scheduler, controller-manager, kube-proxy, and NodePort traffic between nodes.
CNI plugins can need additional ports; add plugin-specific rules to the
`k8s_cluster` security group in `terraform.tfvars` when required.

Wait for the control plane and CNI pods to become ready:

```sh
kubectl get nodes -o wide
kubectl get pods --all-namespaces
```

To use kubectl from your workstation, copy `/etc/kubernetes/admin.conf` from
the control-plane host to `~/.kube/config`, then protect the file:

```sh
mkdir -p "$HOME/.kube"
chmod 700 "$HOME/.kube"
chmod 600 "$HOME/.kube/config"
```

## 5. Join the workers

On the control-plane host, generate the worker join command:

```sh
sudo kubeadm token create --print-join-command
```

Paste the full output into `worker_node_kubeadm_join_command` under
`worker_node.vars` in `ansible/inventories/dev/hosts.yml`. It has this form;
use the real token and CA hash printed by kubeadm:

```yaml
worker_node_kubeadm_join_command: "kubeadm join MASTER_PRIVATE_IP:6443 --token TOKEN --discovery-token-ca-cert-hash sha256:CA_HASH"
```

Join the workers:

```sh
ansible-playbook ansible/playbooks/kubernetes.yml --limit worker_node
```

The equivalent Linux command on each worker is the `kubeadm join ...` command
printed by the control plane. Treat its token as a temporary cluster
credential and do not commit it to Git.

## 6. Verify the cluster

From a machine with the cluster kubeconfig:

```sh
kubectl get nodes -o wide
kubectl get pods --all-namespaces
```

All three nodes should become `Ready` after the CNI is healthy. If a node
remains `NotReady`, inspect kubelet and containerd:

```sh
sudo systemctl status kubelet containerd
sudo journalctl -u kubelet -n 100 --no-pager
```
