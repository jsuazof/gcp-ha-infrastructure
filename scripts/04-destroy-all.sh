#!/bin/bash
source scripts/common.sh

log "⚠️  ATENCIÓN: Esto destruirá TODA la infraestructura"
echo ""
echo "Recursos que serán eliminados:"
echo "- Managed Instance Groups"
echo "- Instance Templates"
echo "- Load Balancer"
echo "- Cloud NAT"
echo "- Firewall Rules"
echo "- VPC Network"
echo ""
read -p "¿Estás seguro? (escribir 'DESTRUIR' para confirmar): " confirm

if [ "$confirm" != "DESTRUIR" ]; then
    log "Operación cancelada"
    exit 0
fi

log "🔥 Destruyendo infraestructura..."

cd terraform || error "No se encuentra directorio terraform"

log "Ejecutando terraform destroy..."
terraform destroy -auto-approve || error "Fallo en terraform destroy"

cd ..

# Limpiar archivos temporales
rm -f outputs/terraform-outputs.json
rm -f ansible/inventories/*.retry

log "✅ Infraestructura destruida completamente"
log "📁 Archivos temporales eliminados"
