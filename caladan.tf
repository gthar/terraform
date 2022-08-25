# https://www.linode.com/docs/guides/import-existing-infrastructure-to-terraform/
resource "linode_instance" "caladan-vm" {
  label  = "caladan"
  region = "eu-central"
  type   = "g6-nanode-1"

  config {
    label       = "My Alpine 3.13 Disk Profile"
    kernel      = "linode/grub2"
    root_device = "/dev/sda"

    devices {
      sda {
        disk_label = "Alpine 3.13 Disk"
      }
      sdb {
        disk_label = "512 MB Swap Image"
      }
    }
  }

  disk {
    label = "Alpine 3.13 Disk"
    size  = 25088
  }
  disk {
    label = "512 MB Swap Image"
    size  = 512
  }
}
