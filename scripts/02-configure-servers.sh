#!/bin/bash
source scripts/common.sh

check_project_root

# Esperar a que las VMs estén listas
wait_for_vms

log "🔧 Configurando servidores con Ansible"

cd ansible || error "No se encuentra directorio ansible"

# Ejecutar playbook
log "Ejecutando playbook setup-webserver.yml..."
ansible-playbook -i inventories/dynamic_inventory.py playbooks/setup-webserver.yml

if [ $? -eq 0 ]; then
    log "✅ Servidores configurados exitosamente"
    
    # Mostrar IP del balanceador
    cd ../terraform || return
    LB_IP=$(terraform output -raw load_balancer_ip 2>/dev/null || echo "No disponible")
    cd ..
    
    log "🌐 Prueba accediendo a: http://$LB_IP"
    log "🔐 HTTPS: https://$LB_IP (certificado autofirmado)"
else
    error "Fallo en la configuración con Ansible"
fi
