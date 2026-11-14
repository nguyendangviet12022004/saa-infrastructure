module "network" {
  source = "../../modules/network"

  project         = var.project
  environment     = var.environment
  vpc_cidr        = var.vpc_cidr
  newbits         = var.newbits
  subnet_count    = var.subnet_count
  security_groups = var.security_groups
}