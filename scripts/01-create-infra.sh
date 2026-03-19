#!/bin/bash
source scripts/common.sh

check_project_root
check_dependencies

log "🚀 Creando infraestructura en GCP"

cd terraform || error "No se encuentra directorio terraform"

# Verificar si existe terraform.tfvars
if [ ! -f "terraform.tfvars" ]; then
    error "No existe terraform.tfvars. Copia desde terraform.tfvars.example y configura"
fi

log "Ejecutando terraform init..."
terraform init || error "Fallo en terraform init"

log "Ejecutando terraform plan..."
terraform plan -out=tfplan || error "Fallo en terraform plan"

log "Ejecutando terraform apply..."
terraform apply tfplan || error "Fallo en terraform apply"

# Guardar outputs
terraform output -json > ../outputs/terraform-outputs.json
log "✅ Outputs guardados en outputs/terraform-outputs.json"

# Mostrar IP del balanceador
LB_IP=$(terraform output -raw load_balancer_ip 2>/dev/null || echo "No disponible")
log "🌐 IP del balanceador: $LB_IP"

cd ..
log "✅ Infraestructura creada exitosamente"
