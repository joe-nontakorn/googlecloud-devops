output "instance_name" {
  description = "ชื่อของ GCE Instance"
  value       = google_compute_instance.gcp_server.name
}

output "instance_external_ip" {
  description = "External IP ของ Instance"
  value       = google_compute_instance.gcp_server.network_interface[0].access_config[0].nat_ip
}

output "instance_internal_ip" {
  description = "Internal IP ของ Instance"
  value       = google_compute_instance.gcp_server.network_interface[0].network_ip
}

output "ssh_command" {
  description = "คำสั่ง SSH เพื่อเชื่อมต่อ Instance"
  value       = "ssh -i ~/.ssh/gcp_key ${var.ssh_user}@${google_compute_instance.gcp_server.network_interface[0].access_config[0].nat_ip}"
}

output "app_url" {
  description = "URL ของแอปพลิเคชัน"
  value       = "http://${google_compute_instance.gcp_server.network_interface[0].access_config[0].nat_ip}"
}
