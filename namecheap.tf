// Important:
// Due to API restrictions, SRV and Dynamic DNS Records can't be created with
// terraform, so I need to use `MERGE` mode and set those manually on the
// namecheap web UI
// https://registry.terraform.io/providers/namecheap/namecheap/latest/docs
//
// - SRV Record:
//     service: _matrix
//     protocol: _tcp
//     priority: 0
//     weight: 10
//     port: 443
//     target: matrix.monotremata.xyz
//     TTL: 30 min
//
// - SRV Record:
//     service: _xmpp-client
//     protocol: _tcp
//     priority: 5
//     weight: 0
//     port: 5222
//     target: xmpp.monotremata.xyz
//     TTL: 30 min
//
// - SRV Record:
//     service: _xmpp-server
//     protocol: _tcp
//     priority: 5
//     weight: 0
//     port: 5269
//     target: xmpp.monotremata.xyz
//     TTL: 30 min
//
// - A + Dynamic DNS Record:
//     host: wg
//
//  I also enable DNSSEC from the web UI, because I can't do that with
//  terraform...



variable "hosts" {
  default = {
    // Alpine VPS hosted on Linode
    caladan = {
      v4 = "139.162.137.29"
      v6 = "2a01:7e01::f03c:92ff:fea2:5d7c"
    }
    // OpenBSD VPS hosted on Vultr
    fugu = {
      v4 = "217.69.5.52"
      v6 = "2001:19f0:6801:1d34:5400:03ff:fe18:7588"
    }
  }
}

// These are subdomains for services hosted on the host named `caladan`.
// Both A and AAAA records should be made for them pointing to caladan's ipv4
// and ipv6 respectively
variable "caladan-subdomains" {
  type = set(string)
  default = [
    "@",
    "filite",
    "git",
    "gts",
    "kb",
    "keyoxide",
    "matrix",
    "mx2",
    "pleroma",
    "xmpp",
    "groups.xmpp",
    "proxy.xmpp",
    "upload.xmpp",
  ]
}

// These are subdomains for services hosted on the host named `narwhal`.
// They are only accessible from my internal network and my internal DNS server
// takes care of that.
// But I set the public A record to caladan's ipv4 just for renewing their
// letsencrypt certificates. No need to set the AAAA record.
variable "narwhal-subdomains" {
  type = set(string)
  default = [
    "authelia",
    "calibre",
    "dav",
    "esphome",
    "git.narwhal",
    "gotify",
    "grafana",
    "hass",
    "homer",
    "influxdb",
    "jellyfin",
    "kodi",
    "mirrors",
    "mpd",
    "music",
    "nextcloud",
    "nodered",
    "openbooks",
    "pg",
    "rainloop",
    "registry",
    "rss-bridge",
    "syncthing",
    "transmission",
    "wallabag",
    "woodpecker",
  ]
}

// These are subdomains for services hosted on the host named `sloth`.
// They are only accessible from my internal network and my internal DNS server
// takes care of that.
// But I set the public A record to caladan's ipv4 just for renewing their
// letsencrypt certificates. No need to set the AAAA record.
variable "sloth-subdomains" {
  type = set(string)
  default = [
    "kodi",
    "mympd",
    "snapweb",
  ]
}

provider "namecheap" {
  user_name   = "gthar"
  api_user    = "gthar"
  client_ip   = var.hosts.caladan.v4
  use_sandbox = false
}

resource "namecheap_domain_records" "monotremata-xyz" {
  domain     = "monotremata.xyz"
  mode       = "MERGE"
  email_type = "MX"

  dynamic "record" {
    for_each = var.caladan-subdomains
    content {
      hostname = record.value
      type     = "A"
      address  = var.hosts.caladan.v4
    }
  }

  dynamic "record" {
    for_each = var.narwhal-subdomains
    content {
      hostname = record.value
      type     = "A"
      address  = var.hosts.caladan.v4
    }
  }

  dynamic "record" {
    for_each = var.sloth-subdomains
    content {
      hostname = record.value
      type     = "A"
      address  = var.hosts.caladan.v4
    }
  }

  dynamic "record" {
    for_each = var.caladan-subdomains
    content {
      hostname = record.value
      type     = "AAAA"
      address  = var.hosts.caladan.v6
    }
  }

  record {
    hostname = "mail"
    type     = "A"
    address  = var.hosts.fugu.v4
  }

  record {
    hostname = "mail"
    type     = "AAAA"
    address  = var.hosts.fugu.v6
  }

  record {
    hostname = "@"
    type     = "MX"
    address  = "mail.monotremata.xyz"
    mx_pref  = 0
  }

  record {
    hostname = "@"
    type     = "MX"
    address  = "mx2.monotremata.xyz"
    mx_pref  = 5
  }

  record {
    hostname = "@"
    type     = "TXT"
    address  = "v=spf1 mx -all"
  }

  record {
    hostname = "_dmarc"
    type     = "TXT"
    address  = "v=DMARC1;p=quarantine;pct=100;rua=mailto:postmaster@monotremata.xyz;;"
  }

  record {
    hostname = "20201210._domainkey"
    type     = "TXT"
    address  = "v=DKIM1;k=rsa;p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC3dRTQXNdRNKjM/hnTIQ9d6h4qr7hDkoo3D8ySrV4tEcOC9cCD5fWiUzc560GuWPW5nm/VCDt6gHTGbkwsU/ULO+mjKJtvhZtEJnO4WqVG9Hr2whypODkGM9FSwh0yaWV96OJd51upsNRD/S5fKDMRcl09aBYe2rsn/877re/M0wIDAQAB;"
  }

}
