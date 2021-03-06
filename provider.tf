terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.26.0"
    }
  }
}

provider "google" {
  project = var.project_name
  region  = var.region
  zone    = "${var.region}-a"
}
