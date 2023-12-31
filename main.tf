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
  allow_stopping_for_update = true
  


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

resource "google_service_account" "terraform_sa" {
 account_id   = "final-408221"
 display_name = "terraform_sa"

}


output "ip" {
  value = google_compute_instance.vm_instance.network_interface.0.network_ip
}




resource "google_compute_firewall" "firewall_rules" {
  project     = "final-408221"
  name    = "terraf-firewall"
  network = google_compute_network.default.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "1000-2000"]
  }

  source_tags = ["web"]
}

resource "google_compute_network" "default" {
  name = "terraform-rules"
}








resource "google_storage_bucket" "terraf_bucket" {
  project     = "final-408221"
  name          = "terraform_bucket_for_final"
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
  public_access_prevention = "enforced"
}


resource "google_compute_attached_disk" "default" {
  disk     = google_compute_disk.disk.id
  instance = google_compute_instance.vm_instance.id
  device_name = "terraf-disk"
}


resource "google_compute_disk" "disk" {
  project  = "final-408221"
  name = "terraf-disk"
  image = "debian-11-bullseye-v20231212"
  type = "pd-standard"
  zone = "us-central1-f"
  size = "10"
}

