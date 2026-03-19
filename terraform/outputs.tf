output "load_balancer_ip" {
  description = "IP pública del balanceador"
  value       = google_compute_global_address.lb_ip.address
}

output "instance_ips" {
  description = "IPs privadas de las instancias"
  value       = google_compute_instance_group_manager.web_mig.instance_group
  # En un MIG real, necesitarías un data source para obtener IPs
  # Esto es simplificado para el ejemplo
}

output "project_id" {
  value = var.project_id
}

output "region" {
  value = var.region
}

output "network_name" {
  value = google_compute_network.vpc.name
}
