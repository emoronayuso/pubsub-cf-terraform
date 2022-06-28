
locals {
  apis = [
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "appengine.googleapis.com",
    "datastore.googleapis.com",
    "firestore.googleapis.com",
    "cloudapis.googleapis.com",
    "containerregistry.googleapis.com",  
    "pubsub.googleapis.com"
  ]
  enabled_apis = { for p in local.apis : "${p}" => {
    google_api  = p
    }
  }
}

resource "google_project_service" "apis" {
  for_each = local.enabled_apis
  project  = "${var.project_name}" 
  service  = each.value.google_api

  disable_dependent_services = true
}

