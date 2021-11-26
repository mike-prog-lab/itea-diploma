module "ec2_instance_openvpn_access_server" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "diploma-openvpn-access-server"

  ami                    = var.ec2_openvpn_access_server_ami
  instance_type          = var.ec2_openvpn_access_server_type
  key_name               = aws_key_pair.devops.key_name
  vpc_security_group_ids = [
    module.sg_ops_ssh_access.security_group_id, module.sg_openvpn_access_server_allow.security_group_id
  ]
  subnet_id              = module.vpc.public_subnets[0]
  user_data_base64       = filebase64("./static/openvpn/user_data.sh")
  iam_instance_profile   = aws_iam_instance_profile.openvpn_as.id

  tags = {
    Project = var.project_name
  }
}

#module "ec2_instance_gitlab" {
#  source  = "terraform-aws-modules/ec2-instance/aws"
#  version = "~> 3.0"
#
#  name = "diploma-openvpn"
#
#  # TODO: change AMI to CentOS 8
#  ami                    = var.ec2_gitlab_ami
#  instance_type          = var.ec2_gitlab_type
#  key_name               = aws_key_pair.devops.key_name
#  vpc_security_group_ids = [module.sg_ops_ssh_access.security_group_id]
#  subnet_id              = module.vpc.private_subnets[0]
#
#  user_data_base64 = filebase64("./static/openvpn/user_data.sh")
#}
#
#module "ec2_instance_jenkins" {
#  source  = "terraform-aws-modules/ec2-instance/aws"
#  version = "~> 3.0"
#
#  name = "diploma-jenkins"
#
#  ami                    = var.ec2_jenkins_ami
#  instance_type          = var.ec2_jenkins_type
#  key_name               = aws_key_pair.devops.key_name
#  vpc_security_group_ids = [module.sg_ops_ssh_access.security_group_id]
#  subnet_id              = module.vpc.private_subnets[0]
#}