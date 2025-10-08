# ec2 key-pair module
module "keypair" {
  source             = "../"
  key_name           = "${var.environment}-${var.application}"
  create_private_key = true
  tags               = var.tags
}