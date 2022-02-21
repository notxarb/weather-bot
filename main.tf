terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.26.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.0.1"
    }
  }
  required_version = ">= 1.1.0"

  cloud {
    organization = "hugginsfamily"

    workspaces {
      name = "gh-actions"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "random_pet" "sg" {}

locals {
  cloud_config_config = <<-END
    #cloud-config
    ${jsonencode({
  write_files = [
    {
      path        = "/app/app.py"
      permissions = "0644"
      owner       = "root:root"
      encoding    = "b64"
      content     = filebase64("${path.module}/app.py")
    },
  ]
})}
  END
}

data "cloudinit_config" "weather-bot" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    filename     = "app.py"
    content      = local.cloud_config_config
  }

  part {
    content_type = "text/x-shellscript"
    filename     = "weather-bot.sh"
    content      = <<-EOF
      #!/bin/bash
      pip install slack_bolt requests
      cd /app/
      nohup python3 app.py &
    EOF
  }
}

resource "aws_instance" "weather-bot" {
  ami                    = "ami-0637e7dc7fcc9a2d9"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.weather-bot-sg.id]

  user_data = data.cloudinit_config.weather-bot.rendered
}

resource "aws_security_group" "weather-bot-sg" {
  name = "${random_pet.sg.id}-sg"
}

output "web-bot-address" {
  value = aws_instance.weather-bot.public_dns
}