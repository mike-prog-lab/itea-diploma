resource "aws_ssm_parameter" "openvpn_access_server_init_pass" {
  name  = "/openvpn/initial/password"
  type  = "SecureString"
  value = var.openvpn_access_server_init_pass
}