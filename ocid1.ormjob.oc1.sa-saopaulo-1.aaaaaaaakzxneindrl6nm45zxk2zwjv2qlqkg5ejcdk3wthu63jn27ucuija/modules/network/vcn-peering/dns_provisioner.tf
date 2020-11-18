/**
 * Once both DNS resolver VMs are created, scp the setup script and execute.
 */
data "oci_core_vnic_attachments" "ocidb_vmnics" {
  count               = var.is_vcn_peering?1:0
  compartment_id      = lookup(data.oci_database_db_systems.ocidb_db_systems[0].db_systems[0], "compartment_id")
  availability_domain = lookup(data.oci_database_db_systems.ocidb_db_systems[0].db_systems[0], "availability_domain")
  instance_id         = oci_core_instance.ocidb_dns_vm[0].id
}

data "oci_core_vnic" "ocidb_vnic" {
  count   = var.is_vcn_peering?1:0
  vnic_id = lookup(data.oci_core_vnic_attachments.ocidb_vmnics[0].vnic_attachments[0],"vnic_id")
}

data "oci_core_vnic_attachments" "wls_vmnics-newvcn" {
  count               = var.is_vcn_peering && var.wls_vcn_name != ""?1:0
  compartment_id      = var.compartment_ocid
  availability_domain = var.wls_availability_domain
  instance_id         = oci_core_instance.wls_dns_vm-newvcn[0].id
}

data "oci_core_vnic_attachments" "wls_vmnics-existingvcn" {
  count               = var.is_vcn_peering && var.wls_vcn_name == ""?1:0
  compartment_id      = var.compartment_ocid
  availability_domain = var.wls_availability_domain
  instance_id         = oci_core_instance.wls_dns_vm-existingvcn[0].id
}

data "oci_core_vnic" "wls_vnic-newvcn" {
  count   = var.is_vcn_peering && var.wls_vcn_name != ""?1:0
  vnic_id = lookup(data.oci_core_vnic_attachments.wls_vmnics-newvcn[0].vnic_attachments[0],"vnic_id")
}

data "oci_core_vnic" "wls_vnic-existingvcn" {
  count   = var.is_vcn_peering && var.wls_vcn_name == ""?1:0
  vnic_id = lookup(data.oci_core_vnic_attachments.wls_vmnics-existingvcn[0].vnic_attachments[0],"vnic_id")
}

data "template_file" "generate_wls_dnsmasq_conf" {
  count    = var.is_vcn_peering?1:0
  template = file("./modules/network/vcn-peering/templates/wls_dnsmasq.conf.tpl")

  vars = {
    ocidb_dns_private_ip = data.oci_core_vnic.ocidb_vnic[0].private_ip_address
    ocidb_zone           = "${lookup(data.oci_core_vcns.ocidb_vcn[0].virtual_networks[0], "dns_label")}.oraclevcn.com"
  }
}

data "template_file" "generate_ocidb_dnsmasq_conf_newvcn" {
  count    = var.is_vcn_peering && var.wls_vcn_name != ""?1:0
  template = file("./modules/network/vcn-peering/templates/ocidb_dnsmasq.conf.tpl")

  vars = {
    wls_dns_private_ip = data.oci_core_vnic.wls_vnic-newvcn[0].private_ip_address
    wls_zone           = "${lookup(data.oci_core_vcns.wls_vcn[0].virtual_networks[0], "dns_label")}.oraclevcn.com"
  }
}

data "template_file" "generate_ocidb_dnsmasq_conf_existingvcn" {
  count    = var.is_vcn_peering && var.wls_vcn_name == ""?1:0
  template = file("./modules/network/vcn-peering/templates/ocidb_dnsmasq.conf.tpl")

  vars = {
    wls_dns_private_ip = data.oci_core_vnic.wls_vnic-existingvcn[0].private_ip_address
    wls_zone           = "${lookup(data.oci_core_vcns.wls_vcn[0].virtual_networks[0], "dns_label")}.oraclevcn.com"
  }
}

// Create SSH key pair for setting up DNS VMs - (see *_dns_provisioner.tf)
resource "tls_private_key" "dns_opc_key" {
  count     = var.is_vcn_peering ? 1:0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "null_resource" "wls-dns-configure-dnsmasq-newvcn" {
  count = var.is_vcn_peering && var.wls_vcn_name != "" ? 1:0

  connection {
    type        = "ssh"
    user        = "opc"
    private_key = tls_private_key.dns_opc_key[0].private_key_pem
    host        = data.oci_core_vnic.wls_vnic-newvcn[0].public_ip_address
    timeout     = "30m"
  }

  provisioner "file" {
    content     = data.template_file.generate_wls_dnsmasq_conf[0].rendered
    destination = "~/dnsmasq.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo firewall-offline-cmd --zone=public --add-port=53/udp",
      "sudo firewall-offline-cmd --zone=public --add-port=53/tcp",
      "sudo yum install dnsmasq -y",
      "sudo cp ~/dnsmasq.conf /etc/dnsmasq.conf",
      "sudo /bin/systemctl enable dnsmasq",
      "sudo /bin/systemctl restart dnsmasq",
      "sudo /bin/systemctl restart firewalld",
    ]
  }
}

resource "null_resource" "wls-dns-configure-dnsmasq-existingvcn" {
  count = var.is_vcn_peering && var.wls_vcn_name == "" ? 1:0

  connection {
    type        = "ssh"
    user        = "opc"
    private_key = tls_private_key.dns_opc_key[0].private_key_pem
    host        = data.oci_core_vnic.wls_vnic-existingvcn[0].public_ip_address
    timeout     = "30m"
  }

  provisioner "file" {
    content     = data.template_file.generate_wls_dnsmasq_conf[0].rendered
    destination = "~/dnsmasq.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo firewall-offline-cmd --zone=public --add-port=53/udp",
      "sudo firewall-offline-cmd --zone=public --add-port=53/tcp",
      "sudo yum install dnsmasq -y",
      "sudo cp ~/dnsmasq.conf /etc/dnsmasq.conf",
      "sudo /bin/systemctl enable dnsmasq",
      "sudo /bin/systemctl restart dnsmasq",
      "sudo /bin/systemctl restart firewalld",
    ]
  }
}

resource "null_resource" "ocidb-dns-configure-dnsmasq-newvcn" {
  count = var.is_vcn_peering && var.wls_vcn_name != ""? 1:0

  connection {
    type        = "ssh"
    user        = "opc"
    private_key = tls_private_key.dns_opc_key[0].private_key_pem
    host        = data.oci_core_vnic.ocidb_vnic[0].public_ip_address
    timeout     = "30m"
  }

  provisioner "file" {
    content     = data.template_file.generate_ocidb_dnsmasq_conf_newvcn[0].rendered
    destination = "~/dnsmasq.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo firewall-offline-cmd --zone=public --add-port=53/udp",
      "sudo firewall-offline-cmd --zone=public --add-port=53/tcp",
      "sudo yum install dnsmasq -y",
      "sudo cp ~/dnsmasq.conf /etc/dnsmasq.conf",
      "sudo /bin/systemctl enable dnsmasq",
      "sudo /bin/systemctl restart dnsmasq",
      "sudo /bin/systemctl restart firewalld",
    ]
  }
}

resource "null_resource" "ocidb-dns-configure-dnsmasq-existingvcn" {
  count = var.is_vcn_peering && var.wls_vcn_name == ""? 1:0

  connection {
    type        = "ssh"
    user        = "opc"
    private_key = tls_private_key.dns_opc_key[0].private_key_pem
    host        = data.oci_core_vnic.ocidb_vnic[0].public_ip_address
    timeout     = "30m"
  }

  provisioner "file" {
    content     = data.template_file.generate_ocidb_dnsmasq_conf_existingvcn[0].rendered
    destination = "~/dnsmasq.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo firewall-offline-cmd --zone=public --add-port=53/udp",
      "sudo firewall-offline-cmd --zone=public --add-port=53/tcp",
      "sudo yum install dnsmasq -y",
      "sudo cp ~/dnsmasq.conf /etc/dnsmasq.conf",
      "sudo /bin/systemctl enable dnsmasq",
      "sudo /bin/systemctl restart dnsmasq",
      "sudo /bin/systemctl restart firewalld",
    ]
  }
}
