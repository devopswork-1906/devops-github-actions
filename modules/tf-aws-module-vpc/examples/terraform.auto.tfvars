environment    = "dev"
region         = "us-east-2"
aws_account_id = ["302263080338"]
application    = "ims"
# VPC
vpc_config = {
  vpc_cidr              = "10.0.0.0/16"
  public_subnets_cidr   = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20"]
  private_subnets_cidr  = ["10.0.64.0/20", "10.0.80.0/20", "10.0.96.0/20"]
  database_subnets_cidr = ["10.0.128.0/20", "10.0.144.0/20", "10.0.160.0/20"]
}