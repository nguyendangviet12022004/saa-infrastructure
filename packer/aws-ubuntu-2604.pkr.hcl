source "amazon-ebs" "ubuntu_2604" {
  region          = var.aws_region
  instance_type   = var.instance_type
  ssh_username    = "ubuntu"
  ssh_timeout     = "10m"
  ami_name        = "${var.ami_name_prefix}-{{timestamp}}"
  ami_description = "Ubuntu 26.04 with Docker, MySQL, and Nginx installed by Ansible."


  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd-gp3/ubuntu-resolute-26.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name          = "${var.ami_name_prefix}-{{timestamp}}"
    ManagedBy     = "Packer"
    BaseOS        = "Ubuntu"
    UbuntuRelease = "26.04"
  }
}

