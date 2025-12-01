variable "build_timeout" {
  default = "60"
}

variable "codebuild_private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for CodeBuild."
}

variable "compute_type" {
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
  description = "The builder instance class"
}

variable "environment" {
}

variable "github_token" {
  type    = string
  default = ""
}

variable "encrypt_ami" {
  type    = bool
  default = true
}

variable "environment_build_image" {
  type        = string
  default     = "aws/codebuild/standard:1.0"
  description = "Docker image used by CodeBuild"
}

variable "packer_build_subnet_ids" {
  type        = list(string)
  description = "Public subnet where Packer build instacen should run."
}

variable "packer_file_location" {
  type        = string
  description = "The file path of the .json packer to build."
}

variable "packer_vars_file_location" {
  type        = string
  default     = ""
  description = "The file path to where extra Packer vars can be referenced"
}

variable "project_name" {
  type        = string
  description = "Name of the CodeBuild Project"
}

variable "source_repository_url" {
  type        = string
  description = "The source repository URL"
}

variable "vpc_id" {
}

variable "common_tags" {
  type = map(string)
}

variable "additional_environment_variables" {
  description = "Additional environment variables to pass to CodeBuild. These are merged with the default AWS_CODEBUILD_SG_ID variable."
  type = list(object({
    name  = string
    value = string
    type  = optional(string, "PLAINTEXT")
  }))
  default = []
}

locals {
  ami_install_commands = [
  ]

  ami_pre_build_commands = [
    "echo Installing HashiCorp Packer...",
    "curl -qL -o packer.zip https://releases.hashicorp.com/packer/1.11.2/packer_1.11.2_linux_amd64.zip && unzip -o packer.zip",
    "echo Create build number from git hash",
    "BUILD_NUMBER=$(git rev-parse --short HEAD)",
    "BUILD_INITIATOR=$CODEBUILD_INITIATOR",
    "PACKER_BUILD_VPC_ID=\"${var.vpc_id}\"",
    "PACKER_BUILD_SUBNET_ID=\"${var.packer_build_subnet_ids[0]}\"",
    "PACKER_PLUGIN_PATH=$(pwd)",
    "echo Installing required plugins...",
    "./packer plugins install github.com/hashicorp/ansible",
    "./packer plugins install github.com/hashicorp/amazon",
    "echo Validating packer template to build...",
    "./packer validate -var-file=\"${var.packer_vars_file_location}\" ${var.packer_file_location}",
  ]

  ami_build_commands = [
    "./packer build -var-file=\"${var.packer_vars_file_location}\" -color=false ${var.packer_file_location} | tee build.log",
  ]

  ami_post_build_commands = [
    "egrep \"${data.aws_region.current.name}\\:\\sami\\-\" build.log | cut -d' ' -f2 > ami_id.txt",
    "test -s ami_id.txt || exit 1",
    "if [ \"${var.encrypt_ami}\" = true ] ; then sed -i.bak \"s/<<AMI-ID>>/$(cat ami_id.txt)/g\" ami_builder_event.json && aws events put-events --entries file://ami_builder_event.json; fi",
    "echo build completed on `date`",
  ]
}

