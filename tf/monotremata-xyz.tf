# todo:
# I am also creating the subdomain `wg.monotremata.xyz` manually
# I decided to manage that subdomain outside of terraform because it has a
# dynamic IP that I update with a cron job

locals {
  domain = "monotremata.xyz"

  // Alpine VPS hosted on Linode
  caladan = {
    ipv4 = "139.162.137.29"
    ipv6 = "2a01:7e01::f03c:92ff:fea2:5d7c"
    // These are subdomains for services hosted on the host named `caladan`.
    // Both A and AAAA records should be made for them pointing to caladan's ipv4
    // and ipv6 respectively
    domains = toset([
      local.domain,
      "git",
      "gts",
      "kb",
      "keyoxide",
      "matrix",
      "mx2",
      "pleroma",
      "pg.caladan",
      "xmpp",
      "proxy.xmpp",
      "upload.xmpp",
      "groups.xmpp",
    ])
  }

  // OpenBSD VPS hosted on Vultr
  fugu = {
    ipv4 = "217.69.5.52"
    ipv6 = "2001:19f0:6801:1d34:5400:03ff:fe18:7588"
  }

  dkim_pub_key = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC3dRTQXNdRNKjM/hnTIQ9d6h4qr7hDkoo3D8ySrV4tEcOC9cCD5fWiUzc560GuWPW5nm/VCDt6gHTGbkwsU/ULO+mjKJtvhZtEJnO4WqVG9Hr2whypODkGM9FSwh0yaWV96OJd51upsNRD/S5fKDMRcl09aBYe2rsn/877re/M0wIDAQAB"

}

resource "namecheap_domain_records" "namecheap-monotremata-xyz" {
  domain = "monotremata.xyz"
  mode   = "OVERWRITE"
  nameservers = [
    "ns1.linode.com",
    "ns2.linode.com",
    "ns3.linode.com",
    "ns4.linode.com",
    "ns5.linode.com"
  ]
}

resource "linode_domain" "monotremata_xyz" {
  type      = "master"
  domain    = local.domain
  soa_email = format("admin@%s", local.domain)
}

resource "linode_domain_record" "caladan_a" {
  domain_id   = linode_domain.monotremata_xyz.id
  name        = each.key
  record_type = "A"
  target      = local.caladan.ipv4
  for_each    = local.caladan.domains
}

resource "linode_domain_record" "caladan_aaaa" {
  domain_id   = linode_domain.monotremata_xyz.id
  name        = each.key
  record_type = "AAAA"
  target      = local.caladan.ipv6
  for_each    = local.caladan.domains
}

resource "linode_domain_record" "mx" {
  domain_id   = linode_domain.monotremata_xyz.id
  name        = each.value.name
  target      = each.value.target
  record_type = each.key
  priority    = each.value.priority
  for_each = {
    A = {
      name     = "mail"
      target   = local.fugu.ipv4
      priority = null
    }
    AAAA = {
      name     = "mail"
      target   = local.fugu.ipv6
      priority = null
    }
    MX = {
      name     = local.domain,
      target   = format("mail.%s", local.domain)
      priority = 0
    }
  }
}

resource "linode_domain_record" "mx2" {
  domain_id   = linode_domain.monotremata_xyz.id
  name        = each.value.name
  target      = each.value.target
  record_type = each.key
  priority    = each.value.priority
  for_each = {
    A = {
      name     = "mx2"
      target   = local.caladan.ipv4
      priority = null
    }
    AAAA = {
      name     = "mx2"
      target   = local.caladan.ipv6
      priority = null
    }
    MX = {
      name     = local.domain
      target   = format("mx2.%s", local.domain)
      priority = 5
    }
  }
}

resource "linode_domain_record" "mail_txt" {
  domain_id   = linode_domain.monotremata_xyz.id
  record_type = "TXT"
  name        = each.value.name
  target      = each.value.target
  for_each = {
    spf = {
      name   = local.domain
      target = "v=spf1 mx -all"
    }
    dmarc = {
      name   = "_dmarc"
      target = format("v=DMARC1;p=quarantine;pct=100;rua=mailto:postmaster@%s;;", local.domain)
    }
    dkim = {
      name   = "20201210._domainkey"
      target = format("v=DKIM1;k=rsa;p=%s;", local.dkim_pub_key)
    }
  }
}

resource "linode_domain_record" "matrix_srv" {
  domain_id   = linode_domain.monotremata_xyz.id
  record_type = "SRV"
  service     = "matrix"
  protocol    = "tcp"
  priority    = 0
  weight      = 10
  port        = 443
  target      = format("matrix.%s", local.domain)
  ttl_sec     = 1800 // 30 min
}

resource "linode_domain_record" "xmpp_srv" {
  domain_id   = linode_domain.monotremata_xyz.id
  record_type = "SRV"
  service     = each.key
  protocol    = "tcp"
  port        = each.value.port
  priority    = 5
  weight      = 0
  target      = format("xmpp.%s", local.domain)
  ttl_sec     = 1800 // 30 min
  for_each = {
    xmpp-client = {
      port = 5222
    }
    xmpp-server = {
      port = 5269
    }
  }
}
