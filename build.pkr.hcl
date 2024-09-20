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

variable tag {
  type = string
}

variable repository_uri {
  type = string
}

variable terraform_version {
  type = string
}

locals {
  repository_uri   = var.repository_uri
}

source "docker" "image" {
  image  = var.source_image
  fix_upload_owner = true
  commit = true
  changes = [
    "WORKDIR /home/actions",
    "ENTRYPOINT /opt/entrypoint.sh",
    "USER actions"
  ]
}


build {
  name = "github-runner"
  sources = [
    "source.docker.image"
  ]

  provisioner "shell" {
    inline = [
      "apt-get update && apt-get install -y apt-utils",
      "apt-get install -y python3-pip python3 sudo"
    ]
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive"
    ]
  }

  provisioner "ansible" {
    playbook_file = "github_runner.yaml"
    extra_arguments = [
      "-e terraform_version=${var.terraform_version}"
    ]
  }

  post-processors {
    post-processor "docker-tag" {
      repository = var.repository_uri
      tags       = ["${var.tag}"]
    }

    post-processor "docker-push" {
      ecr_login    = true
      login_server = var.repository_uri
    }
  }
}

