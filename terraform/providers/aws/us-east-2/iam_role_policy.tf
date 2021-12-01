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

resource "aws_iam_role_policy" "jenkins" {
  name = "JenkinsPolicy"
  role   = aws_iam_role.jenkins.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeSpotInstanceRequests",
          "ec2:CancelSpotInstanceRequests",
          "ec2:GetConsoleOutput",
          "ec2:RequestSpotInstances",
          "ec2:RunInstances",
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:TerminateInstances",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:DescribeInstances",
          "ec2:DescribeKeyPairs",
          "ec2:DescribeRegions",
          "ec2:DescribeImages",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "iam:ListInstanceProfilesForRole",
          "iam:PassRole",
          "ec2:GetPasswordData",
          "ec2:DescribeSpotPriceHistory",
        ]
        Resource = "*"
      }
    ]
  })
}