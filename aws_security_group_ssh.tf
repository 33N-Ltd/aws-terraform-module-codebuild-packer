resource "aws_security_group" "ssh" {
  name        = "${var.environment}-33N-CODEBUILD-SG"
  description = "Managed by Terraform"
  vpc_id      = "${data.aws_vpc.codebuild.id}"

  # from bastion
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "TCP"
    self = true
    security_groups = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(var.common_tags,
    map("Name", "${var.environment}-EDP-PRI-SSH-SG"))}"
}