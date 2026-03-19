#!/usr/bin/env python3
"""
Inventario dinámico para Ansible
Obtiene IPs de los outputs de Terraform
"""
import json
import sys
import os
import subprocess

def get_terraform_outputs():
    """Ejecuta terraform output y retorna JSON"""
    try:
        result = subprocess.run(
            ['terraform', '-chdir=../terraform', 'output', '-json'],
            capture_output=True,
            text=True,
            check=True
        )
        return json.loads(result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"Error ejecutando terraform output: {e}", file=sys.stderr)
        sys.exit(1)
    except FileNotFoundError:
        print("Terraform no encontrado. ¿Está instalado?", file=sys.stderr)
        sys.exit(1)

def main():
    # Si Ansible pide --list
    if len(sys.argv) > 1 and sys.argv[1] == '--list':
        outputs = get_terraform_outputs()
        
        # Construir inventario
        inventory = {
            "_meta": {
                "hostvars": {}
            },
            "webservers": {
                "hosts": [],
                "vars": {
                    "ansible_user": os.environ.get('ANSIBLE_USER', 'jorge-suazo'),
                    "ansible_ssh_private_key_file": os.environ.get('ANSIBLE_SSH_KEY', '~/.ssh/id_rsa')
                }
            }
        }
        
        # En un MIG real, necesitarías un data source para obtener IPs
        # Este es un placeholder - en producción usarías google_compute_instance_group_manager con data source
        inventory["webservers"]["hosts"] = [
            "web-01", "web-02"
        ]
        
        # Aquí podrías agregar IPs reales desde GCP API
        
        print(json.dumps(inventory, indent=2))
    
    elif len(sys.argv) > 1 and sys.argv[1] == '--host':
        # Para un host específico
        print(json.dumps({}))
    else:
        sys.exit(1)

if __name__ == '__main__':
    main()
