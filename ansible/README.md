# Ansible

The `docker`, `mysql`, and `nginx` roles install their Ubuntu packages and
enable/start the corresponding system services. They currently support Ubuntu
hosts only.

Add your servers to the appropriate inventory under `ansible/inventories/`,
then run from the repository root:

```sh
ansible-playbook -i ansible/inventories/dev/hosts.yml ansible/playbooks/server_setup.yml --ask-become-pass
```

Use the staging or production inventory as appropriate. The root
`ansible.cfg` sets `ansible/roles` as the role search path, so role names in the
playbook resolve when invoked from the repository root. The playbook applies
all three roles to every host in the selected inventory. Keep credentials out
of plaintext inventory files; use Ansible Vault for sensitive variables.

The Kubernetes node role uses `ansible.posix.sysctl`. Install its collection
before running the Kubernetes playbook:

```sh
ansible-galaxy collection install -r ansible/requirements.yml
ansible-playbook ansible/playbooks/kubernetes.yml
```
