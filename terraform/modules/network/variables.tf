variable "project" {
  description = "Project name used in resource names and tags."
  type        = string
}

variable "environment" {
  description = "Environment name used in resource names and tags."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "newbits" {
  description = "Number of additional network bits used to calculate each subnet CIDR."
  type        = number
  default     = 4

  validation {
    condition     = var.newbits >= 0 && floor(var.newbits) == var.newbits
    error_message = "newbits must be a non-negative whole number."
  }
}

variable "subnet_count" {
  description = "Number of public and private subnets to create."
  type        = number
  default     = 3

  validation {
    condition     = var.subnet_count > 0 && floor(var.subnet_count) == var.subnet_count
    error_message = "subnet_count must be a positive whole number."
  }

  validation {
    condition     = var.subnet_count * 2 <= pow(2, var.newbits)
    error_message = "newbits must provide enough distinct CIDR blocks for all public and private subnets."
  }
}

variable "tags" {
  description = "Additional tags applied to network resources."
  type        = map(string)
  default     = {}
}

variable "security_groups" {
  description = "Security groups and their ingress/egress rules. Each rule uses exactly one CIDR or security-group source/destination."
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


  validation {
    condition = alltrue(flatten([
      for security_group in values(var.security_groups) : [
        for rule in values(security_group.ingress) :
        (rule.source_cidr != null ? 1 : 0) +
        (rule.source_security_group_key != null ? 1 : 0) +
        (rule.source_security_group_id != null ? 1 : 0) == 1
      ]
    ]))
    error_message = "Each ingress rule must specify exactly one of source_cidr, source_security_group_key, or source_security_group_id."
  }

  validation {
    condition = alltrue(flatten([
      for security_group in values(var.security_groups) : [
        for rule in values(security_group.egress) :
        (rule.destination_cidr != null ? 1 : 0) +
        (rule.destination_security_group_key != null ? 1 : 0) +
        (rule.destination_security_group_id != null ? 1 : 0) == 1
      ]
    ]))
    error_message = "Each egress rule must specify exactly one of destination_cidr, destination_security_group_key, or destination_security_group_id."
  }

  validation {
    condition = alltrue(flatten([
      for security_group in values(var.security_groups) : concat(
        [
          for rule in values(security_group.ingress) :
          rule.source_security_group_key == null || contains(keys(var.security_groups), rule.source_security_group_key)
        ],
        [
          for rule in values(security_group.egress) :
          rule.destination_security_group_key == null || contains(keys(var.security_groups), rule.destination_security_group_key)
        ]
      )
    ]))
    error_message = "Security-group key references in rules must match a key in security_groups."
  }
}
