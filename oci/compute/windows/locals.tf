locals {
  # This is the version of the Terraform template so I can track changes via tags.
  tf_template_version = "0.0.1"
  # This is a map of tags that will be applied to all resources.
  tags = {
    tf_template_version = local.tf_template_version
    app_name            = var.app_name
    environment         = var.oci_environment
  }
  # This is where the cloudinit script is generated with the templatefile function and assigned as a local.
  cloudinit_ps1 = templatefile("${path.module}/userdata/cloudinit.ps1", {
    instance_user     = oci_core_instance.instance.metadata["user"]
    instance_password = oci_core_instance.instance.metadata["password"]
    instance_name     = var.instance_name
  })
}