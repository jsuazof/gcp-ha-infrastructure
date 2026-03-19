#!/bin/bash
source scripts/common.sh

show_menu() {
    clear
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}   🚀 PROYECTO HA EN GCP - MENÚ PRINCIPAL${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo ""
    echo "  1) Crear infraestructura (Terraform)"
    echo "  2) Configurar servidores (Ansible)"
    echo "  3) Hacer TODO (infra + configuración)"
    echo "  4) Destruir TODO (limpieza total)"
    echo "  5) Ver IP del balanceador"
    echo "  6) Ver estado actual"
    echo "  7) Salir"
    echo ""
    echo -e "${BLUE}=========================================${NC}"
    echo -n "Opción: "
}

show_status() {
    echo ""
    info "Estado actual:"
    
    if [ -f "outputs/terraform-outputs.json" ]; then
        echo "  ✅ Infraestructura: CREADA"
        LB_IP=$(jq -r '.load_balancer_ip.value // "No disponible"' outputs/terraform-outputs.json 2>/dev/null)
        echo "  🌐 IP Balanceador: $LB_IP"
    else
        echo "  ❌ Infraestructura: NO CREADA"
    fi
    
    if [ -f "ansible/inventories/*.retry" ]; then
        echo "  ⚠️  Ansible: Puede haber errores"
    else
        echo "  ✅ Ansible: Configuración OK"
    fi
}

while true; do
    show_menu
    read -r option
    
    case $option in
        1)
            ./scripts/01-create-infra.sh
            read -p "Presiona Enter para continuar..."
            ;;
        2)
            ./scripts/02-configure-servers.sh
            read -p "Presiona Enter para continuar..."
            ;;
        3)
            ./scripts/03-full-deploy.sh
            read -p "Presiona Enter para continuar..."
            ;;
        4)
            ./scripts/04-destroy-all.sh
            read -p "Presiona Enter para continuar..."
            ;;
        5)
            if [ -f "outputs/terraform-outputs.json" ]; then
                LB_IP=$(jq -r '.load_balancer_ip.value // "No disponible"' outputs/terraform-outputs.json 2>/dev/null)
                info "🌐 IP del balanceador: $LB_IP"
                info "🔗 http://$LB_IP"
                info "🔒 https://$LB_IP"
            else
                warn "Infraestructura no creada aún"
            fi
            read -p "Presiona Enter para continuar..."
            ;;
        6)
            show_status
            read -p "Presiona Enter para continuar..."
            ;;
        7)
            log "¡Hasta luego! 🚀"
            exit 0
            ;;
        *)
            warn "Opción inválida"
            sleep 2
            ;;
    esac
done
