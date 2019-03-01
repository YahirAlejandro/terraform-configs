
provider "google" {
  credentials = "${file("terraform.json")}"
  project     = "gke-node-replications"
}

resource "random_string" "cluster_suffix" {
    length = 4
    special = false
    number = false
    upper = false
}

output "cluster_name" {
  value = "${random_string.cluster_suffix.result}"
}

resource "google_container_cluster" "primary" {
  name   = "${random_string.cluster_suffix.result}"
  zone = "us-central1-a"
  remove_default_node_pool = true
  initial_node_count = 1

  # Setting an empty username and password explicitly disables basic auth
  master_auth {
    username = ""
    password = ""
  }

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "my-node-pool"
  region     = "us-central1"
  cluster    = "${google_container_cluster.primary.name}"
  node_count = 1

  node_config {
    preemptible  = false
    machine_type = "n1-standard-1"

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

  labels = {
      type = "regular"
    }

    tags = ["terraform", "t400"]
  }
}
 
}