data "aws_ip_ranges" "eu_west_2_codebuild" {
  regions  = ["eu-west-2"]
  services = ["codebuild"]
}

data "aws_ip_ranges" "eu_west_2_ec2" {
  regions  = ["eu-west-2"]
  services = ["ec2"]
}