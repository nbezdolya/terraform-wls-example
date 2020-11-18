Terraform CLI Execution
-----------------------

The CLI is a small-footprint tool that you can use on its own or with the Console to complete Oracle Cloud Infrastructure tasks. The CLI provides the same core functionality as the Console, plus additional commands. Some of these, such as the ability to run scripts, extend Console functionality.

How to Install and Configure Command Line Interface For Oracle Cloud Infrastructure In Linux -- https://mosemp.us.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=274208626330620&id=2432759.1

OCI Terraform Provider Configuration on Linux and Windows machine -- https://mosemp.us.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=101338705018173&id=2470410.1

Pre-requisites
--------------------

The terraform OCI provider supports API Key based authentication and Instance Principal based authentication.

User has to create an OCI account in the his tenancy. Here are the authentication information required 
for invocation of Terraform scripts. 

**Tenancy OCID** - The global identifier for your account, always shown on the bottom of the web console.

**User OCID** - The identifier of the user account you will be using for Terraform

**Fingerprint** - The fingerprint of the public key added in the above user's API Keys section of the web console. 

**Private key path** - The path to the private key stored on your computer. The public key portion must be added to the user account above in the API Keys section of the web console. 

How to get required keys and ocids -- https://docs.cloud.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm 

Purpose
-------

This solution creates single/multi node WLS cluster with OCI Database or ATP DB as INFRA DB optionally fronted 
by a load balancer. The solution will create only one stack at time and further modifications that are done will be 
done on the same stack. 

If multiple instances are desired then the user has to maintain terraform state in different locations or with different name. 
One terraform state file is generated per stack. So for multiple stacks ensure that a unique name is used for terraform state file. 
And this can be achieved by using the option -state="{unique dir or name of .tfstate file}" at the time of terraform apply.

**Public subnet Topology**
Creates following subnets under new VCN or existing VCN in different ADs.
* WLS Public subnet
* Loadbalancer Frontend Public Subnet
* Loadbalancer Backend Public Subnet

**Private Subnet Topology**
Creates following subnets under new VCN or existing VCN in different ADs.

* WLS Private Subnet
* Management Public Subnet (for bastion host, uses the same AD as WLS) 
* Loadbalancer Frontend Public Subnet
* Loadbalancer Backend Public Subnet

Note: Support for existing bastion host to be used in provisioning WLS with private subnet is enabled in terraform CLI only. This can be achieved by using the params, is_bastion_instance_required, existing_bastion_instance_id, and bastion_ssh_private_key.
For existing WLS subnet, user will need to open the port 22 for bastion IP/subnet CIDR. For new WLS subnet we create security listwith bastion private ip.

Organization
-------------

**inputs** - this directory consists of following:
* **env_vars_template** (for secret input variables - like user's api signing key details).
* **instance.tfvars.template** - for wls instance specific config
* **oci_db.tfvars.template** - for OCI DB specific config
* **atp_db.tfvars.template** - for ATP DB specific config

**Note:** rename the xx.tfvars.template to corresponding xx.tfvars and provide environment specific values.

* **main.tf** - is where we call the modules in order as defined in ../modules.
* **outputs.tf** - result printed on the stdout at the completion of terraform provisioning.
* **provider.tf** - oci provider is defined.
* **datasource.tf** - pre-fetch ADs, subnets etc that is then used to lookup based on user specified input.
* **variables.tf** - defines the variables that are passed to modules as input.

To invoke Terraform
--------------------

From solution dir (wls) execute:

### Initialize the terraform provider plugin
$ terraform init

### Init the environment with terraform environment vars
$ source inputs/env_vars

### Invoke apply passing all *.tfvars files as input
If you don't specify the -var-file then defaults in vars.tf will apply.

**WLS Non JRF:**
$ terraform apply -var-file=inputs/instance.tfvars 

**WLS JRF with OCI DB:**
$ terraform apply -var-file=inputs/instance.tfvars -var-file=inputs/oci_db.tfvars

**WLS JRF with ATP DB:**
$ terraform apply -var-file=inputs/instance.tfvars -var-file=inputs/atp_db.tfvars

**Creating Multiple instances from same solutions:**
$ terraform apply -var-file=inputs/instance.tfvars -state=<use unique dir or state file name for each stack>

### To destroy the infrastructure

**WLS Non JRF:**
$ terraform destroy -var-file=inputs/instance.tfvars 

**WLS JRF with OCI DB:**
$ terraform destroy -var-file=inputs/instance.tfvars -var-file=inputs/oci_db.tfvars

**WLS JRF with ATP DB:**
$ terraform destroy -var-file=inputs/instance.tfvars -var-file=inputs/atp_db.tfvars


To invoke Terraform using Resource Manager
--------------------

The artifacts are published to idoru by nightly builds. User will have to download the terraform scripts zip to use with Resource Manager.

* Idoru Link: http://idoru.oraclecorp.com/#/services/WebLogicOciNative
* Artifact Name: wlsoci-resource-manager
* Working directory: ./

Before you create a domain with Oracle WebLogic Server for Oracle Cloud Infrastructure, you must complete one or more prerequisite tasks. These are documented here --
https://docs.oracle.com/en/cloud/paas/weblogic-cloud/user/you-begin-oracle-weblogic-cloud.html

How to provision an Oracle WebLogic Server cluster in Oracle Cloud Infrastructure using Marketplace and Resource Manager -- https://docs.oracle.com/en/cloud/paas/weblogic-cloud/tutorial-get-started/

Managing Stacks and Jobs -- https://docs.cloud.oracle.com/en-us/iaas/Content/ResourceManager/Tasks/managingstacksandjobs.htm

What it does
-------------

**Pre-requisites for Non JRF Weblogic 12c :** 
* User will provide compartment OCID to provision Weblogic 12c with all the networking. 
* User also has option to use pre existing VCN. Only mandatory requirement is that it should have internet gateway pre-configured.


* **Inputs to terraform:**
    *  User will provide the following as param to terraform:
        * Authentication information
            * Tenancy OCID 
            * User OCID
            * Path to private key 
            * FingerPrint
        * WLS Compartment name
        * Region
        * WLS parameters 
            * wls_availability_domain_name
            * wls_admin_user
            * wls_admin_password_ocid
            * instance_shape
            * numVMInstances
            * SSH public key
        * Networking details 
            * network_compartment_id
            * VCN Name (if creating new VCN)
            * VCN OCID (if using existing VCN)
            * wls_subnet_cidr, lb_subnet_1_cidr and lb_subnet_2_cidr (if creating new VCN)
			* wls_subnet_id, lb_subnet_1_id and lb_subnet_2_id (if using existing VCN)
        * Optional Load Balancer 
            * add_load_balancer
        * Optional WLS private subnet
            * assign_weblogic_public_ip (defaults to true, false will create private subnet for WLS)
            * is_bastion_instance_required (defaults to true, false will not create bastion instance)
            * bastion_subnet_cidr (if creating new bastion)
			* bastion_subnet_id (if using existing bastion)

**NOTE:** We have to use FastConnect for provisioning in private subnet without using a bastion host.

Introduction to FastConnect -- https://docs.cloud.oracle.com/en-us/iaas/Content/Network/Concepts/fastconnect.htm


* **Provisioning flow will be as follows:
    * **Create VCN (if not using existing)**
    * **Create Internet gateway(if not preconfigured), Route tables, and Security Lists**
        * *Weblogic Security List*
        * *Load balancer Security Lists*
    * **Create Subnets**
        * Creates one or three subnets one in each Availabity Domains. Three subnets are created if Load balancer needs to be provisioned.
    * **Create VM Instances**
        * First instance hosts the Weblogic 12c admin server and one managed server. 
        * Additional instance host the Weblogic 12c managed servers with nodemanager. 
    * **Create Load balancer (if requested)**
        * If LB is being provisioned:
            * Create Loadbalancer
            * Create Loadbalancer listener
            * Create BackendSet with more than one backends based private ip addresses of the VMs.

**Pre-requisites for supporting OCI DB as infrastructure DB:** 

* User will configure the DB subnet's seclist with a secrule to open up 1521 (or the DB Listener's port) port for VCN CIDR or new WLS subnet CIDR.
* Also user should have created an internet gateway in the VCN.

* **Inputs to terraform:**
    * User will provide the following as param to terraform in addition to the WLS parameters listed above  :
        
        * OCI database Params:
            * ocidb_existing_vcn_id
            * ocidb_compartment_id
            * ocidb_network_compartment_id ( it defaults to ocidb_compartment_id )
            * ocidb_dbsystem_id
            * ocidb_database_id
            * ocidb_pdb_service_name
            * oci_db_user = "sys"
            * oci_db_password_ocid
                   
         **NOTE:** If WLS instance & DB are using the same VCN, then VCN Peering is not required.

**VCN Peering:** 

* Criteria for VCN peering : if (wls_vcn_name or wls_existing_vcn_id) and ocidb_existing_vcn_id are being passed together and that vcn_ids are different.

	* If VCN Peering is required we need to set these params:
            * ocidb_dns_subnet_cidr -- new subnet in DB System VCN
            * wls_dns_subnet_cidr -- new subnet in WLS VCN
            * use_local_vcn_peering -- to enable/disable the feature for VCN peering. This is true by default.

* For existing DB subnet the following stateful security rules must be defined as a pre-requisite by the user:
        * Allow WLS VCN CIDR (e.g. 11.0.0.0/16) access to 1521 (db port)
        * Allow DB DNS Subnet CIDR (e.g 10.0.7.0/24) access to TCP/53 and UDP/53 ports.
        * DB Subnet should be setup to use - Default DHCP options for the VCN.

* For existing WLS Subnet the following stateful security rules must be defined as a pre-requisite by the user:
        * Allow 0.0.0.0/0 access to ICMP/3,4
        * Allow 0.0.0.0/0 access to TCP/22
        * Allow 0.0.0.0/0 access to TCP/7001-7002 (optional, only required for accessing console) - 7001 and 7002 are example, use the value for weblogic server admin console port and admin console ssl port.
        * Allow LB Subnet CIDR(s) access to TCP/7003-7004 ports - 7003 and 7004 are example values, use the value for weblogic managed server port and managed server SSL port.
        * Allow WLS Subnet CIDR  (e.g. 11.0.3.0/24) access to TCP/All ports - for VM to VM communication
        * Allow WLS DNS Subnet CIDR (e.g 11.0.7.0/24) access to TCP/53 and UDP/53 ports
        * WLS Subnet should be setup to use - Default DHCP options for the VCN.


**Pre-requisites for supporting ATP DB as infrastructure DB:** 
* If using existing VCN, internet gateway has to be pre-configured.

* **Inputs to terraform:**
    * User will provide the following as param to terraform in addtion to the WLS parameters listed above:
        * ATP database Params:
            * atp_db_level
            * atp_db_id
            * atp_db_password_ocid
            * atp_db_compartment_id


           
