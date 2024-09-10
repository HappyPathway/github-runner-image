packer {
  required_plugins {
    docker = {
      version = ">= 1.0.8"
      source = "github.com/hashicorp/docker"
    }
  }
}

variable login_password {
  type = string
}

variable login_username {
  type = string
}

variable repo {
  type = string
}

variable tag {
  type = string
}

variable docker_hub_org {
  type = string
  default = "happypathway"
}

variable source_image {
  type = string
  default = "ubuntu:latest"
} 

variable file_template {
  type = string
  default = "buildscript.sh.tpl"
}

variable vars_file {
  type = string
  default = "vars.json"
}

source "docker" "image" {
  image  = var.source_image
  fix_upload_owner = true
  commit = true
  changes = [
      "USER actions",
      "WORKDIR /actions-runner",
      "CMD [\"/usr/bin/bash\", \"/opt/entrypoint.sh\"]",
      "USER actions:actions"
    ]
}


build {
  name    = var.repo
  sources = [
    "source.docker.image"
  ]
  provisioner "file" {
    content = templatefile(
      var.file_template,
      jsondecode(file(var.vars_file))
    )
    destination = "/opt/buildscript"
  }

  provisioner file {
    source      = "entrypoint.sh"
    destination = "/opt/entrypoint.sh"
  }
  
  provisioner shell {
    inline = [
      "chmod +x /opt/entrypoint.sh",
      "chmod +x /opt/buildscript",
      "/opt/buildscript",
      "rm /opt/buildscript"
    ]
    skip_clean = true
  }

  post-processors {
    post-processor "docker-tag" {
        repository =  "${var.login_username}/${var.repo}"
        tags = [
          var.tag
        ]
      }
    post-processor "docker-push" {
      login_password = var.login_password
      login_username = var.login_username
      login = true
    }
  }
}

