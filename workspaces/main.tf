terraform {
  backend "s3" {
    bucket = "tf-infrastructure-as-code"
    key    = "workspaces/terraform.tfstate"
    region = "eu-west-2"

    dynamodb_table = "tf-infrastructure-as-code-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_instance" "servidor" {
  instance_type = "t2.micro"
  ami           = "ami-007ec828a062d87a5"
}