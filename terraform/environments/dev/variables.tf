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

variable "nodes" {
  description = "Kubernetes EC2 nodes keyed by node name."
  type = map(object({
    role                        = string
    instance_type               = optional(string, "t3.medium")
    subnet_id                   = optional(string)
    associate_public_ip_address = optional(bool, true)
    root_volume_size            = optional(number, 30)
    user_data                   = optional(string)
    tags                        = optional(map(string), {})
  }))
  default = {
    master-1 = { role = "master_node" }
    worker-1 = { role = "worker_node" }
    worker-2 = { role = "worker_node" }
  }
}

variable "node_subnet_ids" {
  description = "Subnet IDs used by nodes without a per-node subnet_id. Defaults to public subnet IDs."
  type        = list(string)
  default     = null
}

variable "key_name" {
  description = "Optional EC2 key pair name attached to Kubernetes nodes."
  type        = string
  default     = null
}

variable "ami_id" {
  description = "Optional AMI override. Defaults to the latest Ubuntu 24.04 LTS amd64 image."
  type        = string
  default     = null
}

variable "ssh_cidrs" {
  description = "CIDRs permitted to SSH to the Kubernetes nodes. Empty disables SSH ingress."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "api_cidrs" {
  description = "CIDRs permitted to connect to the Kubernetes API on port 6443. Empty disables external API access."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

