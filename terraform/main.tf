terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# ===== Firewall Rules =====

# อนุญาต SSH (port 22)
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.instance_name}-allow-ssh"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = [var.instance_name]
}

# อนุญาต HTTP (port 80) และ HTTPS (port 443)
resource "google_compute_firewall" "allow_http_https" {
  name    = "${var.instance_name}-allow-http-https"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = [var.instance_name]
}

# อนุญาต K3s API Server (port 6443)
resource "google_compute_firewall" "allow_k3s_api" {
  name    = "${var.instance_name}-allow-k3s-api"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["6443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = [var.instance_name]
}

# อนุญาต NodePort range (30000-32767) สำหรับ K8s Services
resource "google_compute_firewall" "allow_nodeport" {
  name    = "${var.instance_name}-allow-nodeport"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["30000-32767"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = [var.instance_name]
}

# อนุญาต Kubernetes Dashboard (port 3001)
resource "google_compute_firewall" "allow_dashboard" {
  name    = "${var.instance_name}-allow-dashboard"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["3001"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = [var.instance_name]
}

# ===== GCE Instance =====
# หมายเหตุ: ถ้า Instance 34.66.183.14 ถูกสร้างไว้แล้ว
# ให้ใช้ terraform import เพื่อนำเข้า:
# terraform import google_compute_instance.gcp_server <project>/<zone>/<instance-name>

resource "google_compute_instance" "gcp_server" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  tags = [var.instance_name]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 30
      type  = "pd-balanced"
    }
  }

  network_interface {
    network = var.network

    access_config {
      # ถ้ามี Static IP อยู่แล้วให้ระบุ
      # nat_ip = "34.66.183.14"
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_public_key_path)}"
  }

  # Startup script สำหรับติดตั้ง dependencies เบื้องต้น
  metadata_startup_script = <<-SCRIPT
    #!/bin/bash
    apt-get update
    apt-get install -y python3 python3-pip sudo curl
  SCRIPT
}
