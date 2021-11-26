resource "aws_key_pair" "devops" {
  key_name   = "student7-diploma-devops-key"
  public_key = var.devops_pub_key
}