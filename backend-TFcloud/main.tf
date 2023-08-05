terraform {
  cloud {
    organization = "my_infra"

    workspaces {
      name = "terraform-infrastructure-as-code"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_instance" "servidor" {
  instance_type = "t2.micro"
  ami           = "ami-007ec828a062d87a5"
}
