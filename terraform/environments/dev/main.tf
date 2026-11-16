module "network" {
  source = "../../modules/network"

  project      = var.project
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr
  newbits      = var.newbits
  subnet_count = var.subnet_count
  security_groups = merge(var.security_groups, {
    k8s_cluster = {
      description = try(var.security_groups["k8s_cluster"].description, "Kubernetes node communication and optional SSH access")
      ingress = merge(
        try(var.security_groups["k8s_cluster"].ingress, {}),
        { for index, cidr in var.ssh_cidrs : "ssh-${index}" => {
          description = "SSH from configured administrator CIDRs"
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          source_cidr = cidr
          }
        },
        { for index, cidr in var.api_cidrs : "api-${index}" => {
          description = "Kubernetes API from configured administrator CIDRs"
          from_port   = 6443
          to_port     = 6443
          protocol    = "tcp"
          source_cidr = cidr
          }
        }
      )
      egress = try(var.security_groups["k8s_cluster"].egress, {})
    }
  })
}
module "compute" {
  source = "../../modules/compute"

  ami_id             = var.ami_id != null ? var.ami_id : data.aws_ami.ubuntu.id
  nodes              = var.nodes
  subnet_ids         = var.node_subnet_ids != null ? var.node_subnet_ids : module.network.public_subnet_ids
  key_name           = var.key_name
  project            = var.project
  environment        = var.environment
  security_group_ids = [module.network.security_group_ids["k8s_cluster"]]
  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

