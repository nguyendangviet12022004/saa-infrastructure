variable "ami_id" {
  description = "AMI ID used by all compute nodes."
  type        = string
}

variable "nodes" {
  description = "EC2 nodes to create, keyed by node name."
  type = map(object({
    role                        = string
    instance_type               = optional(string, "t3.medium")
    subnet_id                   = optional(string)
    associate_public_ip_address = optional(bool, true)
    root_volume_size            = optional(number, 30)
    user_data                   = optional(string)
    tags                        = optional(map(string), {})
  }))
  validation {
    condition     = length(var.nodes) > 0
    error_message = "At least one compute node must be configured."
  }
}

variable "subnet_ids" {
  description = "Fallback subnet IDs used when a node does not specify subnet_id."
  type        = list(string)
  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "At least one subnet ID must be supplied."
  }
}

variable "key_name" {
  description = "Optional EC2 key pair name for SSH access."
  type        = string
  default     = null
}

variable "project" {
  description = "Project name included in the EC2 Name tag."
  type        = string
}

variable "environment" {
  description = "Environment name included in the EC2 Name tag."
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs attached to every node."
  type        = list(string)
}

variable "tags" {
  description = "Tags applied to every node."
  type        = map(string)
  default     = {}
}
