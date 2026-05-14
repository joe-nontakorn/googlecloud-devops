variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "us-central1-a"
}

variable "instance_name" {
  description = "ชื่อของ GCE Instance"
  type        = string
  default     = "gcp-k3s-server"
}

variable "machine_type" {
  description = "ประเภทของ Machine (e2-medium แนะนำสำหรับ K3s)"
  type        = string
  default     = "e2-medium"
}

variable "network" {
  description = "VPC Network"
  type        = string
  default     = "default"
}

variable "ssh_user" {
  description = "SSH Username สำหรับเข้าถึง Instance"
  type        = string
  default     = "nontakorn_kha"
}

variable "ssh_public_key_path" {
  description = "Path ไปยัง SSH Public Key"
  type        = string
  default     = "~/.ssh/gcp_key.pub"
}
