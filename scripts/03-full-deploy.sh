#!/bin/bash
source scripts/common.sh

log "🚀 INICIANDO DESPLIEGUE COMPLETO"
log "================================="

# Paso 1: Crear infraestructura
./scripts/01-create-infra.sh
if [ $? -ne 0 ]; then
    error "Fallo en creación de infraestructura"
fi

# Paso 2: Configurar servidores
./scripts/02-configure-servers.sh
if [ $? -ne 0 ]; then
    error "Fallo en configuración de servidores"
fi

log "================================="
log "✅ DESPLIEGUE COMPLETO EXITOSO"
log "================================="
