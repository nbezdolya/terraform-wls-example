#
# Copyright (c) 2019, 2020, Oracle and/or its affiliates. All rights reserved.
#

variable "tenancy_ocid" {}
variable "compartment_ocid" {}

variable "availability_domain" {}

variable "subnet_ocid" {}

variable "ssh_public_key" {
  type = string
}

variable "compute_name_prefix" {
  default = "wlsc-instance"
}

variable "vnic_prefix" {
  default = "wls"
}

variable "instance_image_ocid" {}

# Defines the number of instances to deploy
variable "numVMInstances" {
  type    = string
  default = "2"
}

# WLS Related variables
variable "wls_admin_user" {
  type = string
}

variable "wls_domain_name" {
  type = string
}

variable "wls_admin_server_name" {
  type = string
}

variable "wls_admin_password" {
  type = string
}

variable "bootStrapFile" {
  type    = string
  default = "./modules/compute/instance/userdata/bootstrap"
}

variable "instance_shape" {
  type = string
}

variable "region" {
  type = string
}

variable "wls_extern_admin_port" {
  default = "7001"
}

variable "wls_extern_ssl_admin_port" {
  default = "7002"
}

variable "provisioning_timeout_mins" {
  default = 30
}

variable "wls_admin_server_wait_timeout_mins" {
  default = 30
}

variable "wls_admin_port" {
  default = "9071"
}

variable "wls_admin_ssl_port" {
  default = "9072"
}

variable "wls_nm_port" {
  default = "5556"
}

variable "wls_provisioning_timeout" {
  default = "10"
}

variable "wls_cluster_name" {
  default = "jcsoci_cluster"
}

variable "wls_ms_port" {
  default = "9074"
}

variable "wls_ms_extern_port" {
  default = "7003"
}

variable "wls_ms_extern_ssl_port" {
  default = "9073"
}

variable "wls_ms_ssl_port" {
  default = "7004"
}

variable "wls_ms_server_name" {
  default = "jcsoci_server_"
}

variable "wls_cluster_mc_port" {
  default = "5555"
}

variable "wls_machine_name" {
  default = "jcsoci_machine_"
}

/*
********************
Common DB Config
********************
*/
variable "db_password" {
  default = ""
}

variable "db_user" {
  default = ""
}

variable "db_port" {
  default = "1521"
}
/*
********************
OCI DB Config
********************
*/
// Provide DB node count - for node count > 1, WLS AGL datasource will be created

variable "ocidb_compartment_id" {}

variable "ocidb_dbsystem_id" {}

variable "ocidb_database_id" {}

variable "ocidb_pdb_service_name" {}

//WLS Network Compartment
variable "network_compartment_id" {}

//WLS Subnet cidr
variable "wls_subnet_cidr" {}

//Service name prefix
variable "service_name_prefix" {}

//Add security list to existing db vcn
variable "ocidb_existing_vcn_add_seclist" {
  type = bool
}

//DB System Network Compartment
variable "ocidb_network_compartment_id" {}

//DB System Network
variable "ocidb_existing_vcn_id" {}

//WLS subnet id
variable "wls_subnet_id" {}

//WLS existing VCN Id
variable "wls_existing_vcn_id" {
  default = ""
}

// Was Bastion chosen?
variable "is_bastion_instance_required" {
  default = false
}

/*
********************
ATP DB Config
********************
*/

variable "atp_db_id" {}


variable "atp_db_level" {}

variable "rcu_component_list" {
  default = "MDS,WLS,STB,IAU_APPEND,IAU_VIEWER,UCSUMS,IAU,OPSS"
}

variable "wls_edition" {
  default = "EE"
}

// Required params for bootstrap.py (part of image)
variable "mode" {}

variable "tf_script_version" {}
variable "wls_version" {}

/**
 * Defines the mapping between wls_version and corresponding FMW zip.
 */
variable "wls_version_to_fmw_map" {
  type = map

  default = {
    "12.2.1.3" = "/u01/zips/jcs/FMW/12.2.1.3.0/fmiddleware.zip"
    "12.2.1.4" = "/u01/zips/jcs/FMW/12.2.1.4.0/fmiddleware.zip"
    "11.1.1.7" = "/u01/zips/jcs/FMW/11.1.1.7.0/fmiddleware.zip"
  }
}

/**
 * Defines the mapping between wls_version and corresponding JDK zip.
 */
variable "wls_version_to_jdk_map" {
  type = map

  default = {
    "12.2.1.3" = "/u01/zips/jcs/JDK8.0/jdk.zip"
    "12.2.1.4" = "/u01/zips/jcs/JDK8.0/jdk.zip"
    "11.1.1.7" = "/u01/zips/jcs/JDK7.0/jdk.zip"
  }
}

variable "vmscripts_path" {
  default = "/u01/zips/TF/wlsoci-vmscripts.zip"
}

variable "wls_version_to_rcu_component_list_map" {
  type = map

  default = {
    "12.2.1.3" = "MDS,WLS,STB,IAU_APPEND,IAU_VIEWER,UCSUMS,IAU,OPSS"
    "12.2.1.4" = "MDS,WLS,STB,IAU_APPEND,IAU_VIEWER,UCSUMS,IAU,OPSS"
    "11.1.1.7" = "IAU,IAUOES,MDS,OPSS"
  }
}

variable "log_level" {
  default = "INFO"
}

variable "rebootFile" {
  type    = string
  default = "./modules/compute/instance/userdata/reboot"
}

variable "num_volumes" {
  type    = string
  default = "1"
}

variable "volume_size" {
  default = "50"
}

variable "volume_map" {
  type = list

  default = [
    {
      volume_mount_point = "/u01/app"
      display_name       = "middleware"
      device             = "/dev/sdb"
    },
    {
      volume_mount_point = "/u01/data"
      display_name       = "data"
      device             = "/dev/sdc"
    }
  ]
}

variable "deploy_sample_app" {
  default = "true"
}

variable "volume_info_file" {
  default = "/tmp/volumeInfo.json"
}

variable "domain_dir" {
  default = "/u01/data/domains"
}

variable "logs_dir" {
  default = "/u01/logs"
}

variable "assign_public_ip" {}

variable "opc_key" {
  type = map
}

variable "oracle_key" {
  type = map
}

variable "status_check_timeout_duration_secs" {
  default = "1800"
}

variable "is_vcn_peered" {}
variable "wls_dns_vm_ip" {}

/*
********************
IDCS Support
********************
*/
variable "is_idcs_selected" {}
variable "idcs_host" {}
variable "idcs_port" {}
variable "idcs_tenant" {}
variable "idcs_client_id" {}
variable "idcs_cloudgate_port" {}
variable "idcs_client_secret" {}
variable "idcs_app_prefix" {}

variable "idcs_artifacts_file" {
  default = "/u01/data/.idcs_artifacts.txt"
}
variable "idcs_conf_app_info_file" {
  default = "/tmp/.idcs_conf_app_info.txt"
}
variable "idcs_ent_app_info_file" {
  default = "/tmp/.idcs_ent_app_info.txt"
}
variable "idcs_cloudgate_info_file" {
  default = "/tmp/.idcs_cloudgate_info.txt"
}
variable "idcs_cloudgate_config_file" {
  default = "/u01/data/cloudgate_config/appgateway-env"
}
variable "idcs_cloudgate_docker_image_tar" {
  default = "/u01/zips/jcs/app_gateway_docker/19.2.1/app-gateway-docker-image.tar.gz"
}
variable "idcs_cloudgate_docker_image_version" {
  default = "19.2.1-1908290158"
}
variable "idcs_cloudgate_docker_image_name" {
  default = "opc-delivery.docker.oraclecorp.com/idcs/appgateway"
}
variable "lbip" {}
variable "is_idcs_internal" {
  default = "false"
}
variable "is_idcs_untrusted" {
  default = "false"
}
variable "idcs_ip" {
  default = ""
}

variable "defined_tags" {
  type=map
  default = {}
}

variable "freeform_tags" {
  type=map
  default = {}
}

variable "use_regional_subnet" {
  type = bool
}

variable "volume_name" {}

variable "allow_manual_domain_extension" {
  type = bool
  default = false
  description = "flag indicating that domain will be manually extended for managed servers"
}
variable "add_loadbalancer" {
  type = bool
}

variable "is_lb_private" {
  type = bool
}
variable "load_balancer_id" {
}
