terraform {
  backend "s3" {
    bucket = "tf-infrastructure-as-code"
    key    = "servidor/terraform.tfstate"
    region = "eu-west-2"

    dynamodb_table = "tf-infrastructure-as-code-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "tf-infrastructure-as-code"

  lifecycle {
    prevent_destroy = true
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "tf-infrastructure-as-code-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_instance" "servidor" {
  instance_type = "t2.micro"
  ami           = "ami-007ec828a062d87a5"
}
