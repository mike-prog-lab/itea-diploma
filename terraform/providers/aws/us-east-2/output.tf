output "openvpn_access_server" {
  value = {
    public_ipv4 = module.ec2_instance_openvpn_access_server.public_ip
  }
}

output "openvpn_access_server_init_pass" {
  value     = var.openvpn_access_server_init_pass
  sensitive = true
}