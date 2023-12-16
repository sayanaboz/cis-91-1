variable "zone" {
  default = "us-central1-f"
}


terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {


  project = "final-408221"
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "f1-micro"
  zone         = var.zone
  tags         = ["dev", "web"]

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }
}


output "ip" {
  value = google_compute_instance.vm_instance.network_interface.0.network_ip
}


resource "google_compute_firewall" "firewall_rules" {
  project     = "final-408221"
  name        = "terraform"
  network     = "default"
  description = "firewall rule for terraform"

  allow {
    protocol  = "tcp"
    ports     = ["80", "8080", "1000-2000"]
  }

  source_tags = ["dev"]
  target_tags = ["web"]
}


resource "google_storage_bucket" "syanaboz_bucket" {
  project     = "final-408221"
  name          = "bucket_terraform_sayanaboz"
  location      = "US"
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 3
    }
    action {
      type = "Delete"
    }
  }

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}

# Using pd-standard because it's the default for Compute Engine

resource "google_compute_disk" "default" {
  project  = "final-408221"
  name = "terraform-disk"
  type = "pd-standard"
  zone = "us-west1-a"
  size = "10"
}