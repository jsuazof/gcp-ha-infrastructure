variable "project_id" {
  description = "ID del proyecto GCP"
  type        = string
}

variable "region" {
  description = "Región de despliegue"
  type        = string
  default     = "us-central1"
}

variable "zones" {
  description = "Zonas para las instancias"
  type        = list(string)
  default     = ["us-central1-a", "us-central1-b"]
}

variable "network_name" {
  description = "Nombre de la VPC"
  type        = string
  default     = "vpc-ha"
}

variable "instance_count" {
  description = "Número de instancias en el MIG"
  type        = number
  default     = 2
}

variable "machine_type" {
  description = "Tipo de máquina"
  type        = string
  default     = "e2-micro"
}
