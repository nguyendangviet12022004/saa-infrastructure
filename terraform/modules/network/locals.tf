locals {
  name_prefix        = "${var.project}-${var.environment}"
  availability_zones = data.aws_availability_zones.available.names

  ingress_rules = {
    for rule in flatten([
      for security_group_key, security_group in var.security_groups : [
        for rule_key, rule in security_group.ingress : {
          key                       = "${security_group_key}.${rule_key}"
          security_group_key        = security_group_key
          description               = rule.description
          from_port                 = rule.from_port
          to_port                   = rule.to_port
          protocol                  = rule.protocol
          source_cidr               = rule.source_cidr
          source_security_group_key = rule.source_security_group_key
          source_security_group_id  = rule.source_security_group_id
        }
      ]
    ]) : rule.key => rule
  }

  egress_rules = {
    for rule in flatten([
      for security_group_key, security_group in var.security_groups : [
        for rule_key, rule in security_group.egress : {
          key                            = "${security_group_key}.${rule_key}"
          security_group_key             = security_group_key
          description                    = rule.description
          from_port                      = rule.from_port
          to_port                        = rule.to_port
          protocol                       = rule.protocol
          destination_cidr               = rule.destination_cidr
          destination_security_group_key = rule.destination_security_group_key
          destination_security_group_id  = rule.destination_security_group_id
        }
      ]
    ]) : rule.key => rule
  }
}
