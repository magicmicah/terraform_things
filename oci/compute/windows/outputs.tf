output "user"{
  value = oci_core_instance.instance.metadata["user"]
}

output "password" {
  value = oci_core_instance.instance.metadata["password"]
}

output "instance_private_ip"{
  value = oci_core_instance.instance.private_ip
}