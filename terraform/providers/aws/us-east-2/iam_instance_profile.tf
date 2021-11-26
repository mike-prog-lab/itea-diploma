resource "aws_iam_instance_profile" "openvpn_as" {
  name = "OpenvpnAccessServerProfile"
  role = aws_iam_role.openvpn_access_server.name
}