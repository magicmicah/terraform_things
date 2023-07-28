terraform {
  required_providers {
    ssh = {
      source = "loafoe/ssh"
      version = "2.6.0"
    }
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

provider "ssh" {
  # Configuration options
}

data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = 1
}

resource "oci_core_vcn" "k3s_vcn" {
  compartment_id = var.compartment_ocid
  cidr_block     = "10.1.0.0/16"
  display_name   = "k3s-vcn"
  dns_label      = "k3svcn"
}

# Network
resource "oci_core_subnet" "k3s_subnet" {
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.k3s_vcn.id
  cidr_block        = "10.1.20.0/24"
  display_name      = "k3s-subnet"
  dns_label         = "k3ssubnet"
  security_list_ids = [oci_core_vcn.k3s_vcn.default_security_list_id]
  route_table_id    = oci_core_vcn.k3s_vcn.default_route_table_id
  dhcp_options_id   = oci_core_vcn.k3s_vcn.default_dhcp_options_id
}

resource "oci_core_internet_gateway" "k3s_internet_gateway" {
  compartment_id = var.compartment_ocid
  display_name   = "TestInternetGateway"
  vcn_id         = oci_core_vcn.k3s_vcn.id
}

resource "oci_core_default_route_table" "default_route_table" {
  manage_default_resource_id = oci_core_vcn.k3s_vcn.default_route_table_id
  display_name               = "DefaultRouteTable"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.k3s_internet_gateway.id
  }
}


# Node
resource "oci_core_instance" "k3s_master_node" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_ocid
  display_name        = "k3s-master-node"
  shape               = var.instance_shape

  shape_config {
    ocpus         = var.instance_shape_config[var.instance_shape].ocpus
    memory_in_gbs = var.instance_shape_config[var.instance_shape].memory
  }

  create_vnic_details {
    subnet_id                 = oci_core_subnet.k3s_subnet.id
    display_name              = "k3s-master-node-vnic"
    assign_public_ip          = true
    assign_private_dns_record = true
    hostname_label            = "k3s-master-node"
    nsg_ids = [
      oci_core_network_security_group.k3s_master_nsg.id
    ]
  }

  source_details {
    boot_volume_size_in_gbs = var.instance_block_volume_size
    source_type             = "image"
    source_id               = var.instance_image_ocid[var.region]
  }

  metadata = {
    ssh_authorized_keys = local.ssh_public_key
    user_data           = base64encode(file("${path.module}/userdata/cloudinit_master.sh"))
  }
}

# sleep for two minutes while K3s is installed
resource "null_resource" "sleep" {
  depends_on = [oci_core_instance.k3s_master_node]
  provisioner "local-exec" {
    command = "sleep 300"
  }
}

resource "ssh_resource" "k3s_master_token" {
  depends_on = [ 
    oci_core_instance.k3s_master_node,
    null_resource.sleep
  ]
  host = oci_core_instance.k3s_master_node.public_ip
  user = "ubuntu"
  private_key = file(var.ssh_private_key_file)

  commands = [
    "while [ ! -f '/var/lib/rancher/k3s/server/node-token' ]; do echo 'File does not exist yet. Checking in 10 seconds.'; sleep 10; done",
    "sudo cat /var/lib/rancher/k3s/server/node-token"
  ]
}

locals {
  cloudinit_worker = templatefile("${path.module}/userdata/cloudinit_worker.sh", {
    k3s_master_ip = oci_core_instance.k3s_master_node.private_ip
    k3s_master_token = try(ssh_resource.k3s_master_token.result, {})
  })
}

# Worker Nodes
resource "oci_core_instance" "k3s_worker_node" {

  depends_on = [ 
    oci_core_instance.k3s_master_node,
    null_resource.sleep,
    ssh_resource.k3s_master_token
  ]
  count               = var.k3s_worker_node_count
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_ocid
  display_name        = "k3s-worker-node-${count.index}"
  shape               = var.instance_shape

  shape_config {
    ocpus         = var.instance_shape_config[var.instance_shape].ocpus
    memory_in_gbs = var.instance_shape_config[var.instance_shape].memory
  }

  create_vnic_details {
    subnet_id                 = oci_core_subnet.k3s_subnet.id
    display_name              = "k3s-worker-node-vnic-${count.index}"
    assign_public_ip          = true
    assign_private_dns_record = true
    hostname_label            = "k3s-worker-node-${count.index}"
    nsg_ids = [oci_core_network_security_group.k3s_worker_nsg.id]
  }

  source_details {
    boot_volume_size_in_gbs = var.instance_block_volume_size
    source_type             = "image"
    source_id               = var.instance_image_ocid[var.region]
  }

  metadata = {
    ssh_authorized_keys = local.ssh_public_key
    user_data           = base64encode(local.cloudinit_worker)
  }
}

# NSG

resource oci_core_network_security_group "k3s_worker_nsg" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.k3s_vcn.id
  display_name   = "k3s-worker-nsg"
}

resource oci_core_network_security_group "k3s_master_nsg" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.k3s_vcn.id
  display_name   = "k3s-master-nsg"
}

resource "oci_core_network_security_group_security_rule" "k3s_master_nsg_rule" {
  network_security_group_id = oci_core_network_security_group.k3s_master_nsg.id
  direction                = "INGRESS"
  protocol                 = "6"
  source                   = oci_core_network_security_group.k3s_worker_nsg.id
  source_type              = "NETWORK_SECURITY_GROUP"
  tcp_options {
    destination_port_range {
      max = 6443
      min = 6443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "k3s_master_nsg_rule_2" {
  network_security_group_id = oci_core_network_security_group.k3s_master_nsg.id
  direction                = "INGRESS"
  protocol                 = "1"
  source                   = oci_core_network_security_group.k3s_worker_nsg.id
  source_type              = "NETWORK_SECURITY_GROUP"
}




# Load Balancer
## TODO - Create Load balancer vip and add worker nodes to it

