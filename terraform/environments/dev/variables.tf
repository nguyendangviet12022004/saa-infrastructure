variable "project" {
  description = "Project name used in network resource names."
  type        = string
}

variable "environment" {
  description = "Environment name used in network resource names."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the dev VPC."
  type        = string
}

variable "newbits" {
  description = "Additional network bits used to calculate subnet CIDRs."
  type        = number
}

variable "subnet_count" {
  description = "Number of public and private subnets to create."
  type        = number
}

variable "security_groups" {
  description = "Security groups and ingress/egress rules for the dev VPC."
  type = map(object({
    description = string
    ingress = optional(map(object({
      description               = optional(string)
      from_port                 = number
      to_port                   = number
      protocol                  = string
      source_cidr               = optional(string)
      source_security_group_key = optional(string)
      source_security_group_id  = optional(string)
    })), {})
    egress = optional(map(object({
      description                    = optional(string)
      from_port                      = number
      to_port                        = number
      protocol                       = string
      destination_cidr               = optional(string)
      destination_security_group_key = optional(string)
      destination_security_group_id  = optional(string)
    })), {})
  }))
  default = {}
}
