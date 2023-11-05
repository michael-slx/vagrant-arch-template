build {
  sources = ["sources.virtualbox-iso.arch64"]

  provisioner "file" {
    source = "${path.root}/../files"
    destination = "/tmp/upload-files"
  }
  provisioner "file" {
    source = "${path.root}/../scripts"
    destination = "/tmp/upload-scripts"
  }

  provisioner "shell" {
    inline = [
      "chmod -R +x $SCRIPTS_DIR",
      "$SCRIPTS_DIR/base/install.sh"
    ]
    env = {
      "FILES_DIR" = "/tmp/upload-files",
      "SCRIPTS_DIR" = "/tmp/upload-scripts"
    }
  }

  post-processors {  
    post-processor "vagrant" {
      output = "output/${var.build_name}_{{ .Provider }}_${var.build_date}.box"
    }
  }  
}
