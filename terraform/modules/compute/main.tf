resource "aws_instance" "this" {
  for_each = var.nodes

  ami                         = var.ami_id
  instance_type               = each.value.instance_type
  subnet_id                   = each.value.subnet_id != null ? each.value.subnet_id : element(var.subnet_ids, index(keys(var.nodes), each.key) % length(var.subnet_ids))
  key_name                    = var.key_name
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = each.value.associate_public_ip_address
  user_data                   = each.value.user_data
  user_data_replace_on_change = true

  root_block_device {
    volume_size           = each.value.root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = merge(var.tags, each.value.tags, {
    Name = "${var.project}-${var.environment}-${each.key}"
    Role = each.value.role
  })
}
