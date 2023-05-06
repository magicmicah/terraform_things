provider "oci" {
  tenancy_ocid     = var.tenancy_ocid[var.oci_environment]
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region[var.oci_environment]
}

resource "random_string" "instance_password" {
  length = 16
  special = true
}

data "template_cloudinit_config" "cloudinit_config" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "cloudinit.ps1"
    content_type = "text/x-shellscript"
    content      = local.cloudinit_ps1
  }
}

data "oci_identity_availability_domains" "ad" {
  compartment_id = var.tenancy_ocid[var.oci_environment]
  ad_number      = var.availability_domain
}

resource "oci_core_instance" "instance" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id = var.compartment_ocid[var.oci_environment]
  display_name = var.instance_name
  shape = var.shape

  shape_config {
    ocpus = var.shape_ocpus
    memory_in_gbs = var.shape_memory
  }

  metadata = {
    user_data = data.template_cloudinit_config.cloudinit_config.rendered
  }

  create_vnic_details {
    subnet_id = oci_core_subnet.subnet.id
    assign_public_ip = true
  }
  source_details {
    boot_volume_size_in_gbs = 50
    source_type = "image"
    source_id = "ocid1.image.oc1.iad.aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  }
  freeform_tags = local.tags
}

data "oci_core_instance_credentials" "instance_credentials" {
  instance_id = oci_core_instance.instance.id
}
