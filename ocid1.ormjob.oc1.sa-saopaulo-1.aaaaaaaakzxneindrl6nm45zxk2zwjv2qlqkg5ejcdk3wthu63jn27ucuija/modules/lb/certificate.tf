/*
 * Copyright (c) 2020, Oracle and/or its affiliates. All rights reserved.
 */

data "oci_core_subnet" "lb_subnet" {
    count = var.add_load_balancer?1:0

    #Required
    subnet_id = var.subnet_ocids[0]
}

resource "tls_private_key" "ss_private_key" {
  count = var.add_load_balancer?1:0
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "tls_self_signed_cert" "demo_cert" {
  count = var.add_load_balancer?1:0

  key_algorithm     = "RSA"
  private_key_pem   = tls_private_key.ss_private_key[0].private_key_pem

  subject {
    common_name         = format("%s-%s", data.oci_core_subnet.lb_subnet[0].display_name,data.oci_core_subnet.lb_subnet[0].subnet_domain_name)
    organization        = "Demo"
    organizational_unit = "FOR TESTING ONLY"
  }

  #1 year validity
  validity_period_hours = 24 * 365

  allowed_uses = [
    "digital_signature",
    "cert_signing",
    "crl_signing",
  ]
}