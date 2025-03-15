packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 2"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
  }
}

variable "client_id" {
  type    = string
  default = "${env("ARM_CLIENT_ID")}"
}

variable "client_secret" {
  type    = string
  default = "${env("ARM_CLIENT_SECRET")}"
}

variable "subscription_id" {
  type    = string
  default = "${env("ARM_SUBSCRIPTION_ID")}"
}

variable "tenant_id" {
  type    = string
  default = "${env("ARM_TENANT_ID")}"
}

variable "github_source" {
  type    = string
  default = "coretek/Ansible_EUC"
}

variable "git_commit_sha" {
  type    = string
  default = "unknown"
}

variable "image_version" {
  type    = string
  default = "1.0.0"
}

variable "skip_create_image" {
  type    = bool
  default = true
}

variable "sa_password" {
  type    = string
  default = "${env("SA_PASSWORD")}"
}

variable "STORAGE_ACCOUNT_NAME" {
  type    = string
  default = "ctsfs01"
}

variable "DOMAIN_USER" {
  type    = string
  default = "${env("DOMAIN_USER")}"
}

variable "DOMAIN_PASS" {
  type    = string
  default = "${env("DOMAIN_PASS")}"
}

source "azure-arm" "avd_w11" {
  client_id                          = var.client_id
  client_secret                      = var.client_secret
  subscription_id                    = var.subscription_id
  tenant_id                          = var.tenant_id
  communicator                       = "winrm"
  image_offer                        = "windows-11"
  image_publisher                    = "MicrosoftWindowsDesktop"
  image_sku                          = "win11-23h2-avd"
  location                           = "eastus"
  os_type                            = "Windows"
  vm_size                            = "Standard_D4s_v3"
  managed_image_storage_account_type = "Premium_LRS"
  winrm_insecure                     = true
  winrm_timeout                      = "15m"
  winrm_use_ssl                      = true
  winrm_username                     = "packer"

  azure_tags = {
    Owner     = "EUC"
    Environment = "Dev"
    DR        = "No"
    Patching  = "No"
    Backup    = "No"
    BuildDate = "${formatdate("YYYY-MM-DD'T'hh:mm:ssZ", timestamp())}"
    Source    = "https://github.com/${var.github_source}"
    Commit    = var.git_commit_sha
    CreatedBy = "Packer"
    BaseImage = "win11-23h2-avd"
    AZM       = "CTS"
  }

 # virtual_network_name                   = "github-runner-vnet"
 # virtual_network_subnet_name            = "default"
 # virtual_network_resource_group_name    = "RG_Simpson_Ansible"

  # Skip image creation for PR check
  skip_create_image = var.skip_create_image
  shared_image_gallery_destination {
    subscription        = "${var.subscription_id}"
    gallery_name        = "SimpsonGallery"
    image_name          = "avd_win11"
    replication_regions = ["eastus"]
    resource_group      = "RG_Simpson_Ansible"
    image_version       = var.image_version
    specialized         = false
  }
}

build {
  sources = ["source.azure-arm.avd_w11"]

  # Run script to allow Ansible to connect to the VM
  provisioner "powershell" {
    script = "scripts/ConfigureRemotingForAnsible.ps1"
  }

  # Install pywinrm using pipx to allow Ansible to connect to the VM
  provisioner "shell-local" {
    inline_shebang = "/bin/bash -e"
    inline = [
      "pipx inject ansible-core pywinrm",
    ]
  }

  # Run Ansible playbook to configure the VM
  provisioner "ansible" {
    skip_version_check = false
    user               = "packer"
    use_proxy          = false
    playbook_file      = "ansible/avd-win11.yml"
    ansible_env_vars = [
      "STORAGE_ACCOUNT_NAME=${var.STORAGE_ACCOUNT_NAME}",
      "DOMAIN_USER=${var.DOMAIN_USER}",
      "DOMAIN_PASS=${var.DOMAIN_PASS}"
    ]
    extra_arguments = [
      "-e",
      "ansible_winrm_server_cert_validation=ignore",
      "-e",
      "ansible_winrm_transport=ntlm",
      "-vvv"
    ]
  }
    # Run script to sysprep the VM
  provisioner "powershell" {
    script = "scripts/Sysprep.ps1"
  }
}
