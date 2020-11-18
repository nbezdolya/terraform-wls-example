/*
 * Copyright (c) 2019, 2020, Oracle and/or its affiliates. All rights reserved.
 */
/*
 * Load Balancer - This resource provides the Load Balancer resource in Oracle Cloud Infrastructure Load Balancer service.
 * See https://www.terraform.io/docs/providers/oci/r/load_balancer_load_balancer.html
 */

locals {
  /* count decides whether to provision load balancer */
  useHttpsListenerCount = var.add_load_balancer ?1:0
  health_check_url_path = var.is_idcs_selected=="true"?"/cloudgate":"/"
}

resource "oci_load_balancer_backend_set" "wls-lb-backendset" {
  count            = var.lbCount
  name             = var.lb_backendset_name
  load_balancer_id = var.load_balancer_id
  policy           = var.lb_policy

  health_checker {
    port                = var.is_idcs_selected == "true" ? var.idcs_cloudgate_port : var.wls_ms_port
    protocol            = var.lb-protocol
    response_body_regex = ".*"
    url_path            = local.health_check_url_path
    return_code         = var.return_code
  }

  # Set the session persistence to lb-session-persistence with all default values.
  lb_cookie_session_persistence_configuration {}
}

resource "oci_load_balancer_listener" "wls-lb-listener-https" {
  count                    = local.useHttpsListenerCount
  load_balancer_id         = var.load_balancer_id
  name                     = "https"
  default_backend_set_name = oci_load_balancer_backend_set.wls-lb-backendset[count.index].name
  port                     = var.lb-https-lstr-port
  protocol                 = var.lb-protocol
  rule_set_names           = [oci_load_balancer_rule_set.SSL_headers[count.index].name]

  connection_configuration {
    idle_timeout_in_seconds = "10"
  }
  ssl_configuration {
    #Required
    certificate_name = oci_load_balancer_certificate.demo_certificate[0].certificate_name
    verify_peer_certificate = false
  }
}

resource "oci_load_balancer_backend" "wls-lb-backend" {
  count            = var.add_load_balancer ?var.numVMInstances:0
  load_balancer_id = var.load_balancer_id
  backendset_name  = oci_load_balancer_backend_set.wls-lb-backendset[0].name
  ip_address       = var.instance_private_ips[count.index]
  port             = var.is_idcs_selected == "true" ? var.idcs_cloudgate_port : var.wls_ms_port
  backup           = false
  drain            = false
  offline          = false
  weight           = var.policy_weight

  lifecycle {
    ignore_changes = [offline]
  }
}

resource "oci_load_balancer_rule_set" "SSL_headers" {
  count            = local.useHttpsListenerCount
  load_balancer_id = var.load_balancer_id
  name             = "SSLHeaders"
  items {
    action = "ADD_HTTP_REQUEST_HEADER"
    header = "WL-Proxy-SSL"
    value  = "true"
  }
  items {
    action = "ADD_HTTP_REQUEST_HEADER"
    header = "is_ssl"
    value  = "ssl"
  }
}

resource "oci_load_balancer_certificate" "demo_certificate" {
  count = var.lbCount
  #Required
  certificate_name = var.lb_certificate_name
  load_balancer_id = var.load_balancer_id

  #Optional
  public_certificate = tls_self_signed_cert.demo_cert[0].cert_pem
  private_key        = tls_private_key.ss_private_key[0].private_key_pem

  lifecycle {
    create_before_destroy = true
  }
}