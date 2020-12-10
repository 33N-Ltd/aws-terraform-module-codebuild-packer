data "aws_subnet" "private" {
  id = var.codebuild_private_subnet_ids[0]
}