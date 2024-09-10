packer {
  required_plugins {
    # Docker plugin for Packer
    docker = {
      source  = "github.com/hashicorp/docker"
      version = "~> 1"
    }
    # Ansible plugin for Packer
    ansible = {
      version = "v1.1.1"
      source  = "github.com/hashicorp/ansible"
    }
    # Amazon plugin for Packer
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable source_image {
  type    = string
  default = "ubuntu:latest"
}

variable aws_account_id {
  type = string
}

variable aws_region {
  type = string
}

variable repo {
  type = string
}

variable tag {
  type = string
}

variable dest_docker_repo {
  type = string
}


locals {
  aws_account_id   = var.aws_account_id
  aws_region       = var.aws_region
  dest_image       = var.repo
  dest_tag         = var.tag
  dest_docker_repo = var.dest_docker_repo
}

source "docker" "image" {
  image  = var.source_image
  fix_upload_owner = true
  commit = true
  changes = [
    "USER actions",
    "WORKDIR /actions-runner",
    "ENTRYPOINT /opt/entrypoint.sh"
  ]
}


build {
  name = var.repo
  sources = [
    "source.docker.image"
  ]

  provisioner "ansible" {
    playbook_file = "github_runner.yaml"
  }

  post-processors {

    post-processors {
      post-processor "docker-tag" {
        repository = "${local.aws_account_id}.dkr.ecr.${local.aws_region}.amazonaws.com/${local.dest_docker_repo}/${local.dest_image}"
        tag        = [local.dest_tag]
      }

      post-processor "docker-push" {
        ecr_login    = true
        login_server = "${local.aws_account_id}.dkr.ecr.${local.aws_region}.amazonaws.com"
      }
    }
  }
}

