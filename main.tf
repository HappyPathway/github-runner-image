provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}


resource "aws_ecrpublic_repository" "github-runner" {
  provider = aws.us_east_1

  repository_name = "github-runner"

  catalog_data {
    about_text        = "Github Runner Image"
    architectures     = ["x86_64"]
    description       = "Github Runner Image"
    logo_image_blob   = filebase64("hpw.png")
    operating_systems = ["Ubuntu"]
    usage_text        = "Creates a Github Runner Image"
  }

  tags = {
    env = "production"
  }
}

output "repository_uri" {
  value = aws_ecrpublic_repository.github-runner.repository_uri
}

output "reppsitory_id" {
  value = aws_ecrpublic_repository.github-runner.id
}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "region" {
  value = "us-east-1"
}

output "arn" {
  value = aws_ecrpublic_repository.github-runner.arn
}
