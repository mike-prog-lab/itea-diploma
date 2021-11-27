output "ec2_openvpn_access_server" {
  value = {
    public_ipv4 = module.ec2_instance_openvpn_access_server.public_ip
  }
}

output "ec2_gitlab" {
  value = {
    private_ipv4 = module.ec2_instance_gitlab.private_ip
  }
}

output "openvpn_access_server_init_pass" {
  value     = var.openvpn_access_server_init_pass
  sensitive = true
}
