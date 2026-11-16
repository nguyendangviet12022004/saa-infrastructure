resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name        = "${local.name_prefix}-vpc"
    Project     = var.project
    Environment = var.environment
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name        = "${local.name_prefix}-igw"
    Project     = var.project
    Environment = var.environment
  })
}

resource "aws_subnet" "public" {
  count = var.subnet_count

  vpc_id                  = aws_vpc.this.id
  availability_zone       = element(local.availability_zones, count.index)
  cidr_block              = cidrsubnet(var.vpc_cidr, var.newbits, count.index)
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name        = "${local.name_prefix}-public-${count.index + 1}"
    Project     = var.project
    Environment = var.environment
    Tier        = "public"
  })
}

resource "aws_subnet" "private" {
  count = var.subnet_count

  vpc_id            = aws_vpc.this.id
  availability_zone = element(local.availability_zones, count.index)
  cidr_block        = cidrsubnet(var.vpc_cidr, var.newbits, var.subnet_count + count.index)

  tags = merge(var.tags, {
    Name        = "${local.name_prefix}-private-${count.index + 1}"
    Project     = var.project
    Environment = var.environment
    Tier        = "private"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.tags, {
    Name        = "${local.name_prefix}-public-rt"
    Project     = var.project
    Environment = var.environment
  })
}

resource "aws_route_table_association" "public" {
  count = var.subnet_count

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name        = "${local.name_prefix}-private-rt"
    Project     = var.project
    Environment = var.environment
  })
}

resource "aws_route_table_association" "private" {
  count = var.subnet_count

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "this" {
  for_each = var.security_groups

  name        = "${local.name_prefix}-${each.key}"
  description = each.value.description
  vpc_id      = aws_vpc.this.id

  tags = merge(var.tags, {
    Name        = "${local.name_prefix}-${each.key}"
    Project     = var.project
    Environment = var.environment
  })
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = local.ingress_rules

  security_group_id = aws_security_group.this[each.value.security_group_key].id
  cidr_ipv4         = each.value.source_cidr != null && !strcontains(each.value.source_cidr, ":") ? each.value.source_cidr : null
  cidr_ipv6         = each.value.source_cidr != null && strcontains(each.value.source_cidr, ":") ? each.value.source_cidr : null
  referenced_security_group_id = (
    each.value.source_security_group_key != null
    ? aws_security_group.this[each.value.source_security_group_key].id
    : each.value.source_security_group_id
  )
  from_port   = each.value.from_port
  to_port     = each.value.to_port
  ip_protocol = each.value.protocol
  description = each.value.description
}

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = local.egress_rules

  security_group_id = aws_security_group.this[each.value.security_group_key].id
  cidr_ipv4         = each.value.destination_cidr != null && !strcontains(each.value.destination_cidr, ":") ? each.value.destination_cidr : null
  cidr_ipv6         = each.value.destination_cidr != null && strcontains(each.value.destination_cidr, ":") ? each.value.destination_cidr : null
  referenced_security_group_id = (
    each.value.destination_security_group_key != null
    ? aws_security_group.this[each.value.destination_security_group_key].id
    : each.value.destination_security_group_id
  )
  from_port   = each.value.from_port
  to_port     = each.value.to_port
  ip_protocol = each.value.protocol
  description = each.value.description
}

resource "aws_vpc_security_group_egress_rule" "default" {
  for_each = local.default_egress_security_groups

  security_group_id = aws_security_group.this[each.key].id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = -1
  to_port           = -1
  ip_protocol       = "-1"
  description       = "Allow all outbound traffic by default"
}
