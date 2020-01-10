variable "project_id" {
  description = "Project ID"
}

variable "region" {
  description = "Region"
  default = "europe-west1"
}

variables "zones" {
  description = "Zones"
  default = ["europe-west1-b", "europe-west1-c", "europe-west1-d"]
}

variable "subnetwork" {
  description = "Subnetwork"
  default = "europe-west1-01"
}

variable "ip_range_pods" {
  description = "IP port range"
  default = "europe-west1-01-gke-01-pods"
}

variable "ip_range_services" {
  description = "IP services range"
  default = "europe-west1-01-gke-01-services"
}

variable "compute_engine_service_account" {
  description = "Service account"
}
