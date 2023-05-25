resource "hetznerdns_zone" "monotremata_xyz" {
  name = var.domain
  ttl  = 86400
}

resource "hetznerdns_record" "caladan_a" {
  zone_id  = hetznerdns_zone.monotremata_xyz.id
  name     = each.key
  value    = var.caladan.ipv4
  type     = "A"
  ttl      = 86400
  for_each = var.caladan.domains
}

resource "hetznerdns_record" "caladan_aaaa" {
  zone_id  = hetznerdns_zone.monotremata_xyz.id
  name     = each.key
  value    = var.caladan.ipv6
  type     = "AAAA"
  ttl      = 86400
  for_each = var.caladan.domains
}

resource "hetznerdns_record" "mx" {
  zone_id = hetznerdns_zone.monotremata_xyz.id
  name    = each.value.name
  value   = each.value.value
  type    = each.value.type
  for_each = {
    A = {
      type  = "A"
      name  = "mail"
      value = var.fugu.ipv4
    }
    AAAA = {
      type  = "AAAA"
      name  = "mail"
      value = var.fugu.ipv6
    }
    MX = {
      type  = "MX"
      name  = var.domain,
      value = format("0 mail.%s", var.domain) # handle MX priority 0
    }
  }
}

resource "hetznerdns_record" "mx2" {
  zone_id = hetznerdns_zone.monotremata_xyz.id
  name    = each.value.name
  value   = each.value.value
  type    = each.value.type
  for_each = {
    A = {
      type  = "A"
      name  = "mx2"
      value = var.caladan.ipv4
    }
    AAAA = {
      type  = "AAAA"
      name  = "mx2"
      value = var.caladan.ipv6
    }
    MX = {
      type  = "MX"
      name  = var.domain
      value = format("5 mx2.%s", var.domain) # handle MX priority 5
    }
  }
}

resource "hetznerdns_record" "mail_txt" {
  zone_id = hetznerdns_zone.monotremata_xyz.id
  type    = "TXT"
  name    = each.value.name
  value   = each.value.value
  for_each = {
    spf = {
      name  = var.domain
      value = jsonencode("v=spf1 mx -all")
    }
    dmarc = {
      name  = "_dmarc"
      value = jsonencode(format("v=DMARC1;p=quarantine;pct=100;rua=mailto:postmaster@%s;;", var.domain))
    }
    dkim = {
      name  = "20201210._domainkey"
      value = jsonencode(format("v=DKIM1;k=rsa;p=%s;", var.dkim_pub_key))
    }
  }
}

resource "hetznerdns_record" "matrix_srv" {
  zone_id = hetznerdns_zone.monotremata_xyz.id
  type    = "SRV"

  # service: matrix
  # port: tcp
  name = "_matrix._tcp"

  # priority: 0
  # weight: 0
  # port: 443
  # target: matrix.monotremata.xyz
  value = format("0 10 443 matrix.%s", var.domain)

  ttl = 3600 # 1hour
}

resource "hetznerdns_record" "xmpp_srv" {
  zone_id = hetznerdns_zone.monotremata_xyz.id
  type    = "SRV"

  # service: xmpp-client or xmpp-server
  # protocol: tcp
  name = format("_%s._tcp", each.value.service)

  # priority: 5
  # weight: 0
  # port: 5222 or 5269
  # target: xmpp.monotremata.xyz
  value = format("5 0 %s xmpp.%s", each.value.port, var.domain)

  ttl = 1800 // 30 min

  for_each = {
    client = {
      service = "xmpp-client"
      port    = 5222
    }
    server = {
      service = "xmpp-server"
      port    = 5269
    }
  }
}
