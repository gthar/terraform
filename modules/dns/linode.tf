# todo:
# I am also creating the subdomain `wg.monotremata.xyz` manually
# I decided to manage that subdomain outside of terraform because it has a
# dynamic IP that I update with a cron job

resource "linode_domain" "monotremata_xyz" {
  type      = "master"
  domain    = var.domain
  soa_email = format("admin@%s", var.domain)
}

resource "linode_domain_record" "caladan_a" {
  domain_id   = linode_domain.monotremata_xyz.id
  name        = each.key
  record_type = "A"
  target      = var.caladan.ipv4
  for_each    = var.caladan.domains
}

resource "linode_domain_record" "caladan_aaaa" {
  domain_id   = linode_domain.monotremata_xyz.id
  name        = each.key
  record_type = "AAAA"
  target      = var.caladan.ipv6
  for_each    = var.caladan.domains
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
      target   = var.fugu.ipv4
      priority = null
    }
    AAAA = {
      name     = "mail"
      target   = var.fugu.ipv6
      priority = null
    }
    MX = {
      name     = var.domain,
      target   = format("mail.%s", var.domain)
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
      target   = var.caladan.ipv4
      priority = null
    }
    AAAA = {
      name     = "mx2"
      target   = var.caladan.ipv6
      priority = null
    }
    MX = {
      name     = var.domain
      target   = format("mx2.%s", var.domain)
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
      name   = var.domain
      target = "v=spf1 mx -all"
    }
    dmarc = {
      name   = "_dmarc"
      target = format("v=DMARC1;p=quarantine;pct=100;rua=mailto:postmaster@%s;;", var.domain)
    }
    dkim = {
      name   = "20201210._domainkey"
      target = format("v=DKIM1;k=rsa;p=%s;", var.dkim_pub_key)
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
  target      = format("matrix.%s", var.domain)
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
  target      = format("xmpp.%s", var.domain)
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
