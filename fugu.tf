# https://registry.terraform.io/providers/vultr/vultr/latest/docs/resources/instance
resource "vultr_instance" "fugu-vm" {
  app_id   = 0
  backups  = "disabled"
  hostname = "fugu"
  os_id    = 412
  plan     = "vc2-1c-1gb"
  region   = "cdg"
  tags     = []
}
