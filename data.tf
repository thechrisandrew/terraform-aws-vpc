data "aws_ami" "fck_nat_arm" {
  most_recent = true

  filter {
    name   = "name"
    values = ["fck-nat-ubuntu-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  owners = ["568608671756"]
}

data "aws_ami" "fck_nat_x86" {
  most_recent = true

  filter {
    name   = "name"
    values = ["fck-nat-ubuntu-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["568608671756"]
}