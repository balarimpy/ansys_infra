terraform {
  required_providers {
    aws = {
      version = "= 5.33.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

terraform {
  backend "s3" {
    bucket         = "ansys-bucket-infra"
    key            = "terraform/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "ansys-table-infra"
    encrypt        = true
  }
}