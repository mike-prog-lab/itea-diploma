module "sg_ops_ssh_access" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "ops-ssh-access"
  description = "Security group for operators to access via SSH."
  vpc_id      = module.vpc.vpc_id

  ingress_rules       = ["ssh-tcp"]
  ingress_cidr_blocks = var.ops_cidrs

  egress_rules = ["all-all"]
}

module "sg_openvpn_access_server_allow" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "ops-ssh-access"
  description = "SG for OpenVPN Access Server client and web access."
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = var.ops_cidrs
  ingress_rules       = ["https-443-tcp", "openvpn-tcp"]

  egress_rules = ["all-all"]
}