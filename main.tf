provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}


resource "aws_ecrpublic_repository" "github-runner" {
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

locals {
  repository_uri = aws_ecrpublic_repository.github-runner.repository_uri
  repository_id  = aws_ecrpublic_repository.github-runner.id
  aws_account_id = data.aws_caller_identity.current.account_id
  region         = "us-east-1"
  arn            = aws_ecrpublic_repository.github-runner.arn

}
output "repository_uri" {
  value = issensitive(local.repository_id) ? nonsensitive(local.repository_uri) : local.repository_uri
}

output "reppsitory_id" {
  value = issensitive(local.repository_id) ? nonsensitive(local.repository_id) : local.repository_id
}

output "aws_account_id" {
  value = issensitive(local.aws_account_id) ? nonsensitive(local.aws_account_id) : local.aws_account_id
}

output "region" {
  value = issensitive(local.region) ? nonsensitive(local.region) : local.region
}

output "arn" {
  value = issensitive(local.arn) ? nonsensitive(local.arn) : local.arn
}
