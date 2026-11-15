build {
  name    = "saa-infrastructure-ubuntu-2604"
  sources = ["source.amazon-ebs.ubuntu_2604"]

  provisioner "ansible" {
    playbook_file = "${path.root}/../ansible/playbooks/server_setup.yml"
    user          = "ubuntu"

    ansible_env_vars = [
      "ANSIBLE_CONFIG=${path.root}/../ansible.cfg",
    ]
  }
}
