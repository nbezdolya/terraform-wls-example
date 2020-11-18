/*
 * Copyright (c) 2019, 2020, Oracle and/or its affiliates. All rights reserved.
 */
variable "tenancy_ocid" {}
variable "availability_domain" {}
variable "compartment_ocid" {}

variable "region" {}

variable "instance_shape" {
  type = string
}

variable "instance_name" {
  default = "bastion-instance"
}

variable "instance_count" {}

variable "vm_count" {
  description = "Number of wls vm nodes"
}

variable "is_bastion_instance_required" {
  type = bool
  default = true
}

variable "existing_bastion_instance_id" {
  type        = string
}

variable "bastion_subnet_ocid" {
  type = list
}

variable "ssh_public_key" {
  type = string
}

variable "bastion_bootstrap_file" {
  type    = string
  default = "./modules/compute/bastion-instance/userdata/bastion-bootstrap"
}

variable "instance_image_id" {
  type = string
}

variable "defined_tags" {
  type=map
  default = {}
}

variable "freeform_tags" {
  type=map
  default = {}
}

variable "use_existing_subnet" {
  type = bool
}

/*
* Using https://docs.cloud.oracle.com/iaas/images/image/ca429258-2487-45da-a540-2df4142583b5/
* Oracle-provided image = Oracle-Linux-7.6-2019.06.15-0
*
* Also see https://docs.us-phoenix-1.oraclecloud.com/images/ to pick another image in future.
*/
variable "bastion_instance_image_ocid" {
  type = map

  default = {
    us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaa5b5tbfa4qkmu5fkm2m4aaluaqu73f32peylcjhs3vaglu6e223yq"
    us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaay66pu7z27ltbx2uuatzgfywzixbp34wx7xoze52pk33psz47vlfa"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaazfzlw2infpo3svzjgrcl237xsbod4l5yuzfpqdqmmawia2womz5q"
    uk-london-1    = "ocid1.image.oc1.uk-london-1.aaaaaaaaahbkgd2yhw7yg6io76mbuwwtuk4monzpsr3r7nuiegttu5q75r6q"
    ca-toronto-1   = "ocid1.image.oc1.ca-toronto-1.aaaaaaaafdgjpavzr7iwzj4avsk7hzov3jwheu6k3sltlarac6mg6bhopkbq"
    us-langley-1   = "ocid1.image.oc2.us-langley-1.aaaaaaaarz5ttmul4hbpmybwl2qktwpuzaba3a7qkdvem3rzobmlkwmdjv5q"
    us-luke-1      = "ocid1.image.oc2.us-luke-1.aaaaaaaasqw3noi2umcscn5qy4soakwp5t36xvmesbs7zcgn7gp7igdqssaq"
    ap-seoul-1     = "ocid1.image.oc1.ap-seoul-1.aaaaaaaa6jrkptivowaai45lsbrk7ox3kdveyylzdcfttnjzlg5i4idlg6ta"
    ap-tokyo-1     = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaad4gozsm4dexrtoazw7esigotehv5uhbq4plmqrfrz2gxhag6lgja"
  }
}
