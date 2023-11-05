variable "iso_url" {
  type = string
  default = "https://geo.mirror.pkgbuild.com/iso/latest/archlinux-x86_64.iso"
}

variable "iso_hash_url" {
  type = string
  default = "https://geo.mirror.pkgbuild.com/iso/latest/sha256sums.txt"
}

variable "build_name" {
  type = string
  description = "Name of image to be built"
}

variable "build_date" {
  type = string
  description = "Date string for versioning built image"
}

variable "build_cpus" {
  type = number
  description = "Number of CPUs to use during build"

  validation {
    condition     = var.build_cpus >= 1
    error_message = "At least 1 CPU must be used during build."
  }
}

variable "build_memory" {
  type = number
  description = "Amount of memory in MB to use during build"

  validation {
    condition     = var.build_memory >= 512
    error_message = "At least 512 MB must be used during build."
  }
}

variable "boot_wait_time" {
  type = number
  description = "Number of seconds to wait until typing boot command"

  validation {
    condition     = var.boot_wait_time >= 30
    error_message = "At least 30 seconds wait time is required."
  }
}

variable "image_cpus" {
  type = number
  description = "Number of CPUs to use in exported image"

  validation {
    condition     = var.image_cpus >= 1
    error_message = "At least 1 CPU must be used in exported image."
  }
}

variable "image_memory" {
  type = number
  description = "Amount of memory in MB to use in exported image"

  validation {
    condition     = var.image_memory >= 512
    error_message = "At least 512 MB must be used in exported image."
  }
}
