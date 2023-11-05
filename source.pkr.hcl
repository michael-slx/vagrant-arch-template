source "virtualbox-iso" "arch64" {
  guest_os_type = "ArchLinux_64"

  iso_url = "${var.iso_url}"
  iso_checksum = "file:${var.iso_hash_url}"
 
  firmware = "efi"
  cpus = var.build_cpus
  memory = var.build_memory

  nested_virt = true

  gfx_controller = "none"
  headless = true

  disk_size = 65536
  hard_drive_interface = "sata"
  hard_drive_nonrotational = true
  hard_drive_discard = true
  iso_interface = "sata"

  guest_additions_mode = "disable"

  boot_wait = "${var.boot_wait_time}s"
  boot_command = [
    "echo 'root:root' | chpasswd<enter>"
  ]

  ssh_username = "root"
  ssh_password = "root"
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"

  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--acpi=on"],
    ["modifyvm", "{{.Name}}", "--apic=on"],
    ["modifyvm", "{{.Name}}", "--x2apic=on"],
    ["modifyvm", "{{.Name}}", "--ioapic=on"],
    ["modifyvm", "{{.Name}}", "--bios-apic=apic"],
    ["modifyvm", "{{.Name}}", "--hwvirtex=on"],
    ["modifyvm", "{{.Name}}", "--nested-hw-virt=on"],
    ["modifyvm", "{{.Name}}", "--paravirt-provider=default"],
    ["modifyvm", "{{.Name}}", "--pae=on"],
    ["modifyvm", "{{.Name}}", "--long-mode=on"],
    ["modifyvm", "{{.Name}}", "--nested-paging=on"],
    ["modifyvm", "{{.Name}}", "--large-pages=on"],
    ["modifyvm", "{{.Name}}", "--tpm-type=2.0"],

    ["storagectl", "{{.Name}}", "--name", "IDE Controller", "--remove"],
    ["storagectl", "{{.Name}}", "--name", "SATA Controller", "--hostiocache=on"],
  ]

  vboxmanage_post = [
    ["storagectl", "{{.Name}}", "--name", "SATA Controller", "--portcount=1"],

    ["modifyvm", "{{.Name}}", "--cpus=${var.image_cpus}"],
    ["modifyvm", "{{.Name}}", "--memory=${var.image_memory}"],
  ]
}
