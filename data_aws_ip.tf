data "aws_ip_ranges" "eu_west_2_codebuild" {
  regions  = ["eu-west-2"]
  services = ["codebuild"]
}