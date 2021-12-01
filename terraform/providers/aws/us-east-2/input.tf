variable "ops_cidrs" {
  type        = list(string)
  description = "CIDRs of operators."
}

variable "devops_pub_key" {
  type = string
}

variable "project_name" {
  type = string
}

# OpenVPN Access Server
variable "openvpn_access_server_init_pass" {
  type = string
}

variable "ec2_openvpn_access_server_ami" {
  type = string
}

variable "ec2_openvpn_access_server_type" {
  type = string
}

# GitLab
variable "ec2_gogs_ami" {
  type = string
}

variable "ec2_gogs_type" {
  type = string
}

variable "ec2_gogs_root_volume_size" {
  type    = number
  default = 50
}

# Jenkins
variable "ec2_jenkins_ami" {
  type = string
}

variable "ec2_jenkins_type" {
  type = string
}

variable "ec2_jenkins_root_volume_size" {
  type    = number
  default = 50
}
