# Packer

Build an Ubuntu 26.04 AMI with Docker, MySQL, and Nginx installed by the
Ansible roles in `ansible/`.

From this directory:

```sh
packer init .
packer fmt -check .
packer validate .
packer build .
```

Template configuration is split across:

- `plugins.pkr.hcl`: required Packer plugins.
- `variables.pkr.hcl`: required build inputs.
- `aws-ubuntu-2604.pkr.hcl`: AWS image source.
- `build.pkr.hcl`: Ansible provisioning.
- `dev.auto.pkrvars.hcl`: automatically loaded development values.

Packer automatically loads `*.auto.pkrvars.hcl`, so edit
`dev.auto.pkrvars.hcl` to change the AWS region, temporary instance type, or AMI
name prefix. No `-var` arguments are needed. For a separate, untracked values
file, copy the example to a filename such as `local.pkrvars.hcl` and run:

```sh
packer build -var-file=local.pkrvars.hcl .
```

Packer uses the AWS credential chain configured in your environment or AWS
profile. The build launches a temporary EC2 instance, provisions it using
`ansible/playbooks/server_setup.yml`, and creates an AMI in the selected region.
The build requires valid AWS credentials and permission to launch/terminate EC2
instances, create temporary networking resources, and create AMIs.
