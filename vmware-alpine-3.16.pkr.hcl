# VMware Section
# ----------------

variable "vm_name" {
  type    = string
  default = "Alpine 3.16"
}

variable "cpu" {
  type    = string
  default = "1"
}

variable "ram_size" {
  type    = string
  default = "1024"
}

variable "disk_size" {
  type    = string
  default = "8000"
}

variable "iso_checksum" {
  type    = string
  default = "2b7151b90b14b01dba851e60cc1b9140fa2915b32d4f2c001ef4da09655e0ef0"
}

variable "iso_checksum_type" {
  type    = string
  default = "sha256"
}

variable "iso_url" {
  type    = string
  default = "https://dl-cdn.alpinelinux.org/alpine/v3.16/releases/x86_64/alpine-standard-3.16.0-x86_64.iso"
}

variable "output_directory" {
  type    = string
  default = "output-alpine"
}

# Account Section
# ---------------

variable "user_name" {
  type    = string
  default = "alpine"
}

variable "user_password" {
  type    = string
  default = "Alpine3.16"
}

variable "user_sshkey" {
  type    = string
  default = "%%%%xxxx"
}

# VMWARE image section
# --------------------

source "vmware-iso" "alpine" {
  boot_command = [
    "root<enter><wait>",
    "ifconfig eth0 up && udhcpc -i eth0<enter><wait5>",
    "wget http://{{ .HTTPIP }}:{{ .HTTPPort }}/answers<enter><wait>",
    "setup-alpine -f ./answers<enter><wait5>",
    "${var.user_password}<enter><wait>",
    "${var.user_password}<enter><wait5>",
    "chrony<enter><wait20>",
    "${var.user_name}<enter><wait5>",
    "<enter><wait5>",
    "${var.user_password}<enter><wait>",
    "${var.user_password}<enter><wait5>",
    "<enter><wait20>",
    "y<enter><wait60>",
    "rc-service sshd stop<enter>",
    "mount /dev/sda3 /mnt<enter>",
    "echo 'PermitRootLogin yes' >> /mnt/etc/ssh/sshd_config<enter>",
    "umount /mnt<enter>",
    "reboot<enter>",
  ]

  boot_wait            = "20s"
  communicator         = "ssh"
  cpus                 = "${var.cpu}"
  disk_size            = "${var.disk_size}"
  http_directory       = "./linux/http"
  iso_checksum         = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url              = "${var.iso_url}"
  memory               = "${var.ram_size}"
  shutdown_command     = "poweroff"
  ssh_timeout          = "10m"
  ssh_username         = "root"
  ssh_password         = "${var.user_password}"
  vm_name              = "${var.vm_name}"
  guest_os_type        = "other-64"
  output_directory     = "${var.output_directory}"
  format = "ova"
}

build {
  sources = [
    "source.vmware-iso.alpine"
  ]

  provisioner "shell-local" {
    inline = [
      "mkdir -p ./secrets",
      "rm -f ./secrets/idpriv* || true",
      "ssh-keygen -t ed25519 -f ./secrets/idpriv -C '${var.user_name}' -N '${var.user_password}'"
    ]
  }

  provisioner "file" {
    source = "./secrets/idpriv.pub"
    destination = "/tmp/idpriv.pub"
    generated = true
  }
  
  provisioner "file" {
    source = "./assets/00_update_issue.start"
    destination = "/etc/local.d/00_update_issue.start"
    generated = true
  }

  provisioner "shell" {
    execute_command = "{{ .Vars }} sh {{ .Path }}"
    environment_vars = [
      "ALPINE_USER_NAME=${var.user_name}",
    ]
    scripts = [
      "./scripts/update.sh",
      "./scripts/install.sh",
    ]
  }
  
  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -S -E sh {{ .Path }}"
    environment_vars = [
      "ALPINE_USER_NAME=${var.user_name}",
    ]
    scripts = [
      "./scripts/usermgmt.sh",
    ]
  }

}
