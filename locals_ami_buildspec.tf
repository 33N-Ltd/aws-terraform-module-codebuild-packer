locals {
  ami_buildspec = <<EOF
version: 0.2
phases:
  install:
    commands:
      - ${join("\n      - ", local.ami_install_commands)}
  pre_build:
    commands:
      - ${join("\n      - ", local.ami_pre_build_commands)}
  build:
    commands:
      - ${join("\n      - ", local.ami_build_commands)}
  post_build:
    commands:
      - ${join("\n      - ", local.ami_post_build_commands)}
EOF
}
