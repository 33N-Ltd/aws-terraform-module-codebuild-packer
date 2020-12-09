resource "aws_security_group" "codebuild" {
  name        = "${upper(var.environment)}-${upper(var.project_name)}-CODEBUILD-SG"
  description = "Managed by Terraform"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "TCP"
    self      = true
    //    cidr_blocks = ["0.0.0.0/0"]
    cidr_blocks = data.aws_ip_ranges.eu_west_2_codebuild.cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    {
      "Name" = "${var.environment}-${upper(var.project_name)}-CODEBUILD-SG"
    },
  )
}

