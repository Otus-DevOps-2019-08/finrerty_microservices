provider "google" {
  version = "~> 2.18.0"
}

module "gke" {
  source                 = "terraform-google-modules/kubernetes-engine/google"
  project_id             = var.project_id
  name                   = "cluster-1"
  regional               = true
  region                 = var.region
  network                = "default"
  subnetwork             = var.subnetwork
  ip_range_pods          = var.ip_range_pods
  ip_range_services      = var.ip_range_services
  create_service_account = false
  service_account        = var.compute_engine_service_account
}

  node_pools = [
    {
      name               = "default-node-pool"
      machine_type       = "g1-small"
      min_count          = 1
      max_count          = 5
      local_ssd_count    = 0
      disk_size_gb       = 20
      disk_type          = "pd-standard"
      image_type         = "COS"
      auto_repair        = true
      auto_upgrade       = true
      service_account    = var.compute_engine_service_account
      preemptible        = false
      initial_node_count = 3
    },
  ]

  node_pools_oauth_scopes = {
    all = []

    default-node-pool = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  node_pools_labels = {
    all = {}

    default-node-pool = {
      default-node-pool = true
    }
  }

  node_pools_metadata = {
    all = {}

    default-node-pool = {
      node-pool-metadata-custom-value = "my-node-pool"
    }
  }

  node_pools_taints = {
    all = []

    default-node-pool = [
      {
        key    = "default-node-pool"
        value  = true
        effect = "PREFER_NO_SCHEDULE"
      },
    ]
  }

  node_pools_tags = {
    all = []

    default-node-pool = [
      "default-node-pool",
    ]
  }
}
