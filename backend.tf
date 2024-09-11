# terraform {
#   backend "remote" {
#     organization = "roknsound"
#     workspaces {
#       prefix = "github-repos-"
#     }
#   }
# }

terraform {
  backend "gcs" {
    bucket = "hpw-terraform-state"
    prefix = "github-runner-image"
  }
}

