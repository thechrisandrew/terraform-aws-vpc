module "vpc" {
  source = "../../"

  vpc_name    = "example-vpc"
  environment = "testing"

  availability_zones = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  public_subnets     = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  private_subnets    = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
  enable_nat_gateway = false
}
