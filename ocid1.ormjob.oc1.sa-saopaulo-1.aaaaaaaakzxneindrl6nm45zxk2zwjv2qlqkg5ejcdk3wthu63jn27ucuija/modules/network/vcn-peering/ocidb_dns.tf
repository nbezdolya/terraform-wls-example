/*
 * Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
 */

resource "oci_core_security_list" "ocidb_dns_security_list" {
  count = var.is_vcn_peering ? 1:0

  #Required
  compartment_id = lookup(data.oci_database_db_systems.ocidb_db_systems[0].db_systems[0], "compartment_id")
  vcn_id         = var.ocidb_existing_vcn_id
  display_name   = "${var.service_name}-dbsystem-dns-security-list"

  // allow outbound traffic on all ports for all protocols
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"       // All protocols and all ports
  }

  // allow inbound ssh traffic
  ingress_security_rules {
    protocol  = "6"         // tcp
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 22
      max = 22
    }
  }

  // allow inbound icmp type 3 traffic (required for SSH)
  // To enable MTU negotiation for ingress internet traffic,
  // make sure to allow type 3 ("Destination Unreachable")
  // code 4 ("Fragmentation Needed and Don't Fragment was Set").
  ingress_security_rules {
    protocol  = "1"         // ICMP
    source    = "0.0.0.0/0"
    stateless = false

    icmp_options {
      #Required
      type = "3"
      code = "4"
    }
  }

  // allow inbound traffic to DNS port 53 for UDP protocol for WLS VCN CIDR
  ingress_security_rules {
    protocol  = "17"                  // udp
    source    = var.wls_vcn_cidr == "" ? lookup(data.oci_core_vcns.wls_vcn[0].virtual_networks[0], "cidr_block") : var.wls_vcn_cidr
    stateless = false

    udp_options {
      min = 53
      max = 53
    }
  }

  // allow inbound traffic to DNS port 53 for tcp protocol for WLS VCN CIDR
  ingress_security_rules {
    protocol  = "6"                   // tcp
    source    = var.wls_vcn_cidr == "" ? lookup(data.oci_core_vcns.wls_vcn[0].virtual_networks[0], "cidr_block") : var.wls_vcn_cidr
    stateless = false

    tcp_options {
      min = 53
      max = 53
    }
  }

  // allow inbound traffic to DNS port 53 for UDP protocol for OCI DB VCN CIDR
  ingress_security_rules {
    protocol  = "17"                    // udp
    source    = lookup(data.oci_core_vcns.ocidb_vcn[0].virtual_networks[0],"cidr_block")
    stateless = false

    udp_options {
      min = 53
      max = 53
    }
  }

  // allow inbound traffic to DNS port 53 for tcp protocol for OCI DB VCN CIDR
  ingress_security_rules {
    protocol  = "6"                     // tcp
    source    = lookup(data.oci_core_vcns.ocidb_vcn[count.index].virtual_networks[0],"cidr_block")
    stateless = false

    tcp_options {
      min = 53
      max = 53
    }
  }
  defined_tags = var.defined_tags
  freeform_tags = var.freeform_tags
}

resource "oci_core_dhcp_options" "ocidb-dns-dhcp-options" {
  count          = var.is_vcn_peering ? 1:0
  compartment_id = lookup(data.oci_database_db_systems.ocidb_db_systems[0].db_systems[0], "compartment_id")
  vcn_id         = var.ocidb_existing_vcn_id
  display_name   = "${var.service_name}-dbsystem-dns-dhcp-option"

  // required
  options {
    type        = "DomainNameServer"
    server_type = "VcnLocalPlusInternet"
  }
  defined_tags = var.defined_tags
  freeform_tags = var.freeform_tags
}

resource "oci_core_subnet" "ocidb-dns-subnet" {
  count               = var.is_vcn_peering ? 1:0
  availability_domain = var.use_regional_subnet?"":lookup(data.oci_database_db_systems.ocidb_db_systems[0].db_systems[0], "availability_domain")
  cidr_block          = var.ocidb_dns_subnet_cidr
  display_name        = "${var.service_name}-dbsystem-dns-subnet-${lookup(data.oci_database_db_systems.ocidb_db_systems[0].db_systems[0], "availability_domain")}"
  dns_label           = local.dns_label
  compartment_id      = lookup(data.oci_database_db_systems.ocidb_db_systems[0].db_systems[0], "compartment_id")
  vcn_id              = var.ocidb_existing_vcn_id
  security_list_ids   = [oci_core_security_list.ocidb_dns_security_list[count.index].id]

  // Using the route table created with rule for LPG
  route_table_id  = oci_core_route_table.ocidb-route-table[count.index].id
  dhcp_options_id = oci_core_dhcp_options.ocidb-dns-dhcp-options[count.index].id

  defined_tags = var.defined_tags
  freeform_tags = var.freeform_tags
}

resource "oci_core_instance" "ocidb_dns_vm" {
  count               = var.is_vcn_peering ? 1:0
  availability_domain = lookup(data.oci_database_db_systems.ocidb_db_systems[0].db_systems[0], "availability_domain")
  compartment_id      = lookup(data.oci_database_db_systems.ocidb_db_systems[0].db_systems[0], "compartment_id")
  display_name        = "${var.service_name}-dbsystem-dns"
  shape               = var.instance_shape

  create_vnic_details {
    subnet_id        = oci_core_subnet.ocidb-dns-subnet[count.index].id
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "${var.service_name}-dbsystem-dns-vnic-${count.index}"
  }

  source_details {
    source_type = "image"
    source_id   = var.instance_image_id

    # Apply this to set the size of the boot volume that's created for this instance.
    # Otherwise, the default boot volume size of the image is used.
    # This should only be specified when source_type is set to "image".
    #boot_volume_size_in_gbs = "60"
  }

  metadata = {
    ssh_authorized_keys = "${var.ssh_public_key}\n${tls_private_key.dns_opc_key[count.index].public_key_openssh}"
  }

  timeouts {
    create = "60m"
  }

  defined_tags = var.defined_tags
  freeform_tags = var.freeform_tags
}
