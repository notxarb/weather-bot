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

variable "ACCUWEATHER_API_KEY" { type = string }

variable "SLACK_APP_TOKEN" { type = string }

variable "SLACK_BOT_TOKEN" { type = string }

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
      apt update
      apt install -y python3 python3-pip
      pip install slack_bolt requests
      cd /app/
      export ACCUWEATHER_API_KEY=${var.ACCUWEATHER_API_KEY}
      export SLACK_APP_TOKEN=${var.SLACK_APP_TOKEN}
      export SLACK_BOT_TOKEN=${var.SLACK_BOT_TOKEN}
      nohup python3 app.py &
    EOF
  }
}

resource "aws_instance" "weather-bot" {
  ami                    = "ami-0637e7dc7fcc9a2d9"
  instance_type          = "t2.micro"
  key_name               = "weather-bot"
  vpc_security_group_ids = [aws_security_group.weather-bot-sg.id]

  user_data = data.cloudinit_config.weather-bot.rendered
}

resource "aws_security_group" "weather-bot-sg" {
  name = "${random_pet.sg.id}-sg"

  # SSH access from the VPC
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "web-bot-address" {
  value = aws_instance.weather-bot.public_dns
}