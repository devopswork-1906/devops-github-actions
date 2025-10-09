# ec2 key-pair module
module "keypair" {
  source             = "../../../modules/tf-aws-module-keypair/"
  key_name           = local.key_name
  create_private_key = true
  tags               = merge(var.tags["common_tags"], { "Name" = "${local.keypair_name}" })
}