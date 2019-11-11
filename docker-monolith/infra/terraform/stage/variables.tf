variable project {
  description = "Project ID"
}

variable region {
  description = "Region"
  # Значение по-умолчанию
  default = "europe-west1"
}

variable public_key_path {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}

variable app_disk_image {
  description = "Disk image for reddit application"
  default     = "reddit-app-base"
}

variable db_disk_image {
  description = "Disk image for reddit db"
  default     = "reddit-db-base"
}

variable private_key_path {
  description = "Path to the private key used for ssh access"
}

variable zone {
  description = "Zone"
  # Значение по-умолчанию
  default = "europe-west1-b"
}

variable server_count {
  default = 1
}

variable environment {
  description = "Environment type: stage or prod"
  default = "stage"
}
