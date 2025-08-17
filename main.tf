locals {
  vm_defaults = {
    target_node      = var.proxmox_node
    clone            = var.cloudinit_template_name
    full_clone       = true
    agent            = 1
    os_type          = "cloud-init"
    startup          = ""
    onboot           = true
    qemu_os          = "other"
    bios             = "seabios"
    automatic_reboot = false
    scsihw           = "virtio-scsi-single"
    bootdisk         = "scsi0"
    ipconfig0        = "ip=dhcp"
    nameserver       = "8.8.8.8"
    sshkeys          = var.ssh_pub_key
  }

  nodes = {
    control_plane = {
      count  = 1
      prefix = "k8s-control-plane"
      tags   = "k8s,control-plane"
    }
    worker = {
      count  = 2
      prefix = "k8s-worker"
      tags   = "k8s,worker-node"
    }
  }
}

resource "proxmox_vm_qemu" "control_plane" {
  count = local.nodes.control_plane.count
  name  = "${local.nodes.control_plane.prefix}-${count.index + 1}"

  target_node      = local.vm_defaults.target_node
  clone            = local.vm_defaults.clone
  full_clone       = local.vm_defaults.full_clone
  agent            = local.vm_defaults.agent
  os_type          = local.vm_defaults.os_type
  startup          = local.vm_defaults.startup
  onboot           = local.vm_defaults.onboot
  qemu_os          = local.vm_defaults.qemu_os
  bios             = local.vm_defaults.bios
  automatic_reboot = local.vm_defaults.automatic_reboot
  scsihw           = local.vm_defaults.scsihw
  bootdisk         = local.vm_defaults.bootdisk

  cpu {
    cores   = var.cpu_cores
    type    = "host"
    sockets = 1
  }
  memory = var.memory

  serial {
    id   = 0
    type = "socket"
  }

  disks {
    ide {
      ide0 {
        cloudinit {
          storage = var.storage
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          size      = var.disk_size
          iothread  = true
          replicate = false
          storage   = var.storage
        }
      }
    }
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  ipconfig0  = local.vm_defaults.ipconfig0
  nameserver = local.vm_defaults.nameserver
  sshkeys    = local.vm_defaults.sshkeys

  tags = local.nodes.control_plane.tags
}

resource "proxmox_vm_qemu" "worker_node" {
  count = local.nodes.worker.count
  name  = "${local.nodes.worker.prefix}-${count.index + 1}"

  target_node      = local.vm_defaults.target_node
  clone            = local.vm_defaults.clone
  full_clone       = local.vm_defaults.full_clone
  agent            = local.vm_defaults.agent
  os_type          = local.vm_defaults.os_type
  startup          = local.vm_defaults.startup
  onboot           = local.vm_defaults.onboot
  qemu_os          = local.vm_defaults.qemu_os
  bios             = local.vm_defaults.bios
  automatic_reboot = local.vm_defaults.automatic_reboot
  scsihw           = local.vm_defaults.scsihw
  bootdisk         = local.vm_defaults.bootdisk

  cpu {
    cores   = var.cpu_cores
    type    = "host"
    sockets = 1
  }
  memory = var.memory

  serial {
    id   = 0
    type = "socket"
  }

  disks {
    ide {
      ide0 {
        cloudinit {
          storage = var.storage
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          size      = var.disk_size
          iothread  = true
          replicate = false
          storage   = var.storage
        }
      }
    }
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  ipconfig0  = local.vm_defaults.ipconfig0
  nameserver = local.vm_defaults.nameserver
  sshkeys    = local.vm_defaults.sshkeys

  tags = local.nodes.worker.tags
}
