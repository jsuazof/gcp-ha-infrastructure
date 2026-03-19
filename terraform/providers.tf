terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
  backend "gcs" {
    # Configurar bucket para estado remoto (opcional pero profesional)
    # bucket = "terraform-state-${PROJECT_ID}"
    # prefix = "ha-webapp/terraform.tfstate"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
