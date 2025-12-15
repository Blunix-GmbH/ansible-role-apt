terraform {
  required_providers {
    ionoscloud = {
      source  = "ionos-cloud/ionoscloud"
      version = ">= 6.4.5"
    }
    local = {
      source = "hashicorp/local"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

# Provider authentication is read from:
#   TF_VAR_ionosctl_token_value (wired from IONOSCTL_TOKEN_VALUE/IONOSCTL_TOKEN/IONOS_TOKEN by run-tests.sh)
#   or TF_VAR_ionos_token / TF_VAR_ionosctl_token
provider "ionoscloud" {
  token = coalesce(
    var.ionosctl_token_value,
    var.ionosctl_token,
    var.ionos_token,
    ""
  )
}

variable "ionosctl_token_value" {
  description = "IONOSCTL token value (preferred)"
  type        = string
  default     = ""
}

variable "ionosctl_token" {
  description = "IONOSCTL legacy token"
  type        = string
  default     = ""
}

variable "ionos_token" {
  description = "IONOS token fallback"
  type        = string
  default     = ""
}

# Debian 13 image
data "ionoscloud_image" "example" {
  type        = "HDD"
  cloud_init  = "V1"
  image_alias = "debian:13"
  location    = "de/fra"
}

# Choose a Cube template (size)
data "ionoscloud_template" "cube" {
  # adjust to the Cube flavor you want (XS/S/M/…)
  name = "Basic Cube XS"
}

resource "ionoscloud_datacenter" "example" {
  name                = "cus_dev_prod_web"
  location            = "de/fra"
  description         = "cus_dev_prod_web"
  sec_auth_protection = false
}

resource "ionoscloud_lan" "example" {
  datacenter_id = ionoscloud_datacenter.example.id
  public        = true
  name          = "Lan Example"
}

resource "ionoscloud_ipblock" "example" {
  location = ionoscloud_datacenter.example.location
  size     = 1
  name     = "example"
}

data "cloudinit_config" "server_config" {
  gzip          = false
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = <<-EOF
      #cloud-config
      package_update: true
      package_upgrade: false
      runcmd:
        - apt-get update
    EOF
  }
}

resource "ionoscloud_cube_server" "example" {
  name          = "Server Example"
  datacenter_id = ionoscloud_datacenter.example.id
  image_name    = data.ionoscloud_image.example.name
  template_uuid = data.ionoscloud_template.cube.id

  # ✅ for Cube: pass *paths* to public key files
  ssh_key_path = [pathexpand("~/.ssh/id_ed25519.pub")]

  volume {
    name         = "system"
    disk_type    = "DAS"
    user_data    = data.cloudinit_config.server_config.rendered
  }

  nic {
    lan             = ionoscloud_lan.example.id
    name            = "system"
    dhcp            = true
    firewall_active = false
    ips             = [ionoscloud_ipblock.example.ips[0]]
  }
}


resource "random_password" "server_image_password" {
  length  = 16
  special = false
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/inventory/hosts"
  content  = <<EOF
[cus_dev_prod_web]
cus-dev-prod-web-1 ansible_host=${ionoscloud_ipblock.example.ips[0]} ansible_user=root ansible_python_interpreter=/usr/bin/python3 ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF
  depends_on = [ionoscloud_cube_server.example]
}

output "public_ip" {
  description = "Primary IPv4 for cus-dev-prod-web"
  value       = ionoscloud_ipblock.example.ips[0]
}
