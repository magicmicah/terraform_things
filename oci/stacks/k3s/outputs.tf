output "k3s_master_instance_private_ip" {
  value = [oci_core_instance.k3s_master_node.*.private_ip]
}

output "k3s_master_instance_public_ip" {
  value = [oci_core_instance.k3s_master_node.*.public_ip]
}

output "k3s_worker_instance_private_ips" {
  value = [oci_core_instance.k3s_worker_node.*.private_ip]
}

output "k3s_worker_instance_public_ips" {
  value = [oci_core_instance.k3s_worker_node.*.public_ip]
}

output "k3s_master_token" {
  sensitive = true
  value = try(ssh_resource.k3s_master_token.result, {})
}