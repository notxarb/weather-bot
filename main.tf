terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    random = {
      source = "hashicorp/random"
    }
  }

  cloud {
    organization = "hugginsfamily"

    workspaces {
      name = "gh-actions"
    }
  }
}