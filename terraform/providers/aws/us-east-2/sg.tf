module "sg_ops_ssh_public_access" {
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

  name        = "openvpn-as-sg"
  description = "SG for OpenVPN Access Server client and web access."
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = var.ops_cidrs
  ingress_rules       = ["https-443-tcp", "openvpn-tcp", "openvpn-udp"]

  egress_rules = ["all-all"]
}

module "sg_gitlab" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "gitlab-sg"
  description = "SG for self-hosted GitLab service."
  vpc_id      = module.vpc.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "ssh-tcp"
      source_security_group_id = module.sg_openvpn_access_server_allow.security_group_id
    },
    {
      rule                     = "https-443-tcp"
      source_security_group_id = module.sg_openvpn_access_server_allow.security_group_id
    }
  ]

  number_of_computed_ingress_with_source_security_group_id = 2

  egress_rules = ["all-all"]
}
