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

module "sg_allow_ssh_from_openvpn_as" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "ssh-from-openvpn-as-sg"
  description = "Allow ssh access from OpenVPN Access Server node."
  vpc_id      = module.vpc.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "ssh-tcp"
      source_security_group_id = module.sg_openvpn_access_server_allow.security_group_id
    }
  ]

  number_of_computed_ingress_with_source_security_group_id = 1
}

module "sg_gogs" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "gogs-sg"
  description = "SG for self-hosted Gogs service."
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 3000
      to_port                  = 3000
      protocol                 = "tcp"
      source_security_group_id = module.sg_openvpn_access_server_allow.security_group_id
    },
    {
      from_port                = 3000
      to_port                  = 3000
      protocol                 = "tcp"
      source_security_group_id = module.sg_jenkins.security_group_id
    },
  ]

  egress_rules = ["all-all"]
}

module "sg_jenkins" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "jenkins-sg"
  description = "SG for Jenkins service."
  vpc_id      = module.vpc.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
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
