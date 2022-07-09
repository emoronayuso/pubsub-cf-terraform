
## Bucket input_data
resource "google_storage_bucket" "input_data" {
  name     = "${var.project_name}-input-data"
  location = "EU"
}
##

## Topic and suscription topic_cf
resource "google_pubsub_topic" "topic_cf" {
  name = "topic-cf"
}

resource "google_service_account" "sa_publisher" {
  account_id   = "sa-publisher"
  display_name = "sa-publisher"
}

resource "google_pubsub_topic_iam_member" "role_sa_publisher" {
  project    = var.project_name
  topic      = google_pubsub_topic.topic_cf.name
  role       = "roles/pubsub.publisher"
  member     = "serviceAccount:${google_service_account.sa_publisher.email}"
  depends_on = [google_pubsub_topic.topic_cf]
}

resource "google_storage_bucket_iam_member" "role_sa_publisher_read_bucket" {
  bucket     = google_storage_bucket.input_data.name
  role       = "roles/storage.objectViewer"
  member     = "serviceAccount:${google_service_account.sa_publisher.email}"
  depends_on = [google_storage_bucket.input_data]
}

resource "google_pubsub_subscription" "topic_cf-subscription" {
  name    = "topic_cf-subscription"
  topic   = google_pubsub_topic.topic_cf.id
  project = var.project_name

  ack_deadline_seconds = 100

  retry_policy {
    minimum_backoff = "10s"
    maximum_backoff = "600s"
  }

  depends_on = [google_pubsub_topic.topic_cf]
}

resource "google_service_account" "sa_subscription" {
  account_id   = "sa-subscription"
  display_name = "sa-subscription"
}

resource "google_pubsub_subscription_iam_member" "role_sa_subscription_v" {
  project      = var.project_name
  subscription = google_pubsub_subscription.topic_cf-subscription.name
  role         = "roles/pubsub.viewer"
  member       = "serviceAccount:${google_service_account.sa_subscription.email}"
  depends_on   = [google_pubsub_subscription.topic_cf-subscription]
}

resource "google_pubsub_subscription_iam_member" "role_sa_subscription_s" {
  subscription = google_pubsub_subscription.topic_cf-subscription.name
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${google_service_account.sa_subscription.email}"
  depends_on   = [google_pubsub_subscription.topic_cf-subscription]
}
##

## Firestore
resource "google_app_engine_application" "firestore" {
  project       = var.project_name
  location_id   = var.region
  database_type = "CLOUD_FIRESTORE"
}

resource "google_service_account_iam_member" "role_sa_firestore" {
  service_account_id = google_service_account.sa_subscription.name
  role               = "roles/datastore.user"
  member             = "serviceAccount:${google_service_account.sa_subscription.email}"
}

resource "google_service_account_iam_member" "role_sa_firestore_develop" {
  service_account_id = google_service_account.sa_subscription.name
  role               = "roles/firebase.developAdmin"
  member             = "serviceAccount:${google_service_account.sa_subscription.email}"
}

resource "google_service_account_iam_member" "role_sa_firestore_serviceStorageAgent" {
  service_account_id = google_service_account.sa_subscription.name
  role               = "roles/firebasestorage.serviceAgent"
  member             = "serviceAccount:${google_service_account.sa_subscription.email}"
}

resource "google_service_account_iam_member" "role_sa_firestore_serviceAgent" {
  service_account_id = google_service_account.sa_subscription.name
  role               = "roles/firestore.serviceAgent"
  member             = "serviceAccount:${google_service_account.sa_subscription.email}"
}
##
