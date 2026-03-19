#!/bin/bash
# Funciones comunes para todos los scripts

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Verificar que estamos en el directorio correcto
check_project_root() {
    if [ ! -d "terraform" ] || [ ! -d "ansible" ]; then
        error "Debes ejecutar este script desde la raíz del proyecto"
    fi
}

# Verificar dependencias
check_dependencies() {
    command -v terraform >/dev/null 2>&1 || error "Terraform no está instalado"
    command -v ansible >/dev/null 2>&1 || error "Ansible no está instalado"
    command -v gcloud >/dev/null 2>&1 || error "gcloud no está instalado"
    command -v python3 >/dev/null 2>&1 || error "Python3 no está instalado"
    log "✅ Dependencias verificadas"
}

# Esperar a que las VMs estén listas
wait_for_vms() {
    log "Esperando 30 segundos para que las VMs inicien..."
    sleep 30
}
