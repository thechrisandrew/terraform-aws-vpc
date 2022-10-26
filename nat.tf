locals {
  nat_gateway_type          = lower(var.nat_gateway_type)
  instance_family           = split(".", var.nat_instance_type)[0]
  nat_instance_architecture = try(regex("g$", local.instance_family), false) == "g" ? "arm64" : "x86_64"
}

# multi gateway
resource "aws_eip" "multi_gateway" {
  count = local.nat_gateway_type == "multi_gateway" ? length(var.availability_zones) : "0"
  vpc   = true
}

resource "aws_nat_gateway" "multi_gateway" {
  count = local.nat_gateway_type == "multi_gateway" ? length(var.availability_zones) : "0"

  allocation_id = element(aws_eip.multi_gateway.*.allocation_id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.aws-igw]
}

resource "aws_route_table" "multi_gateway" {
  count  = local.nat_gateway_type == "multi_gateway" ? length(var.availability_zones) : "0"
  vpc_id = aws_vpc.aws-vpc.id

  tags = {
    Name        = "${var.vpc_name}-route-table-private"
    Environment = var.environment
  }
}

resource "aws_route" "multi_gateway" {
  count = local.nat_gateway_type == "multi_gateway" ? length(var.availability_zones) : "0"

  route_table_id         = element(aws_route_table.multi_gateway.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = element(aws_nat_gateway.multi_gateway.*.id, count.index)
}

resource "aws_route_table_association" "multi_gateway" {
  count          = local.nat_gateway_type == "multi_gateway" ? length(var.private_subnets) : "0"
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.multi_gateway.*.id, count.index)
}

# single gateway
resource "aws_eip" "single_gateway" {
  count = local.nat_gateway_type == "single_gateway" ? "1" : "0"
  vpc   = true
}

resource "aws_nat_gateway" "single_gateway" {
  count = local.nat_gateway_type == "single_gateway" ? "1" : "0"

  allocation_id = element(aws_eip.single_gateway.*.allocation_id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.aws-igw]
}

resource "aws_route_table" "single_gateway" {
  count  = local.nat_gateway_type == "single_gateway" ? "1" : "0"
  vpc_id = aws_vpc.aws-vpc.id

  tags = {
    Name        = "${var.vpc_name}-route-table-private"
    Environment = var.environment
  }
}

resource "aws_route" "single_gateway" {
  count = local.nat_gateway_type == "single_gateway" ? "1" : "0"

  route_table_id         = element(aws_route_table.single_gateway.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = element(aws_nat_gateway.single_gateway.*.id, count.index)
}

resource "aws_route_table_association" "single_gateway" {
  count          = local.nat_gateway_type == "single_gateway" ? length(var.private_subnets) : "0"
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.single_gateway[0].id
}

# single instance
resource "aws_security_group" "single_instance" {
  count = local.nat_gateway_type == "single_instance" ? "1" : "0"

  name        = "nat_instance_security_group"
  description = "allow all traffic from within the vpc cidr"
  vpc_id      = aws_vpc.aws-vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "single_instance" {
  count = local.nat_gateway_type == "single_instance" ? "1" : "0"

  ami           = local.nat_instance_architecture == "arm64" ? data.aws_ami.fck_nat_arm.id : data.aws_ami.fck_nat_x86.id
  instance_type = var.nat_instance_type

  associate_public_ip_address = true
  source_dest_check           = false

  vpc_security_group_ids = [aws_security_group.single_instance[0].id]
  subnet_id              = aws_subnet.public[0].id

  tags = {
    Name = "${var.vpc_name}-nat-instance"
  }
}

resource "aws_route_table" "single_instance" {
  count  = local.nat_gateway_type == "single_instance" ? "1" : "0"
  vpc_id = aws_vpc.aws-vpc.id

  tags = {
    Name        = "${var.vpc_name}-route-table-private"
    Environment = var.environment
  }
}

resource "aws_route" "single_instance" {
  count = local.nat_gateway_type == "single_instance" ? "1" : "0"

  route_table_id         = aws_route_table.single_instance[0].id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.single_instance[0].primary_network_interface_id
}

resource "aws_route_table_association" "single_instance" {
  count = local.nat_gateway_type == "single_instance" ? length(var.availability_zones) : "0"

  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.single_instance[0].id
}
