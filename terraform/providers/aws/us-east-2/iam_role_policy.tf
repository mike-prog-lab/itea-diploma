resource "aws_iam_role_policy" "openvpn_access_server" {
  name = "OpenvpnAccessServerPolicy"
  role   = aws_iam_role.openvpn_access_server.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter"
        ]
        Resource = [
          aws_ssm_parameter.openvpn_access_server_init_pass.arn,
        ]
      }
    ]
  })
}