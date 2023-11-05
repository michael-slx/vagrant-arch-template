packer {
  required_plugins {
    virtualbox = {
      source  = "github.com/hashicorp/virtualbox"
      version = "~> 1.0.5"
    }

    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> v1.1.1"
    }
  }
}
