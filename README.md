# 🚀 Proyecto HA en GCP - Infraestructura como Código

## 📋 Descripción
Proyecto profesional que demuestra habilidades en:
- **Terraform**: Infraestructura como Código (VPC, MIG, LB, Cloud NAT)
- **Ansible**: Configuration Management (Nginx, SSL, páginas web)
- **GCP**: Cloud computing, redes, balanceo de cargas
- **DevOps**: Automatización, scripts, buenas prácticas

## 🏗️ Arquitectura
```
[Usuario] → [Load Balancer Global] → [Managed Instance Group]
                                         ├── VM1 (us-central1-a)
                                         └── VM2 (us-central1-b)
```

## 🛠️ Tecnologías
- Terraform ≥ 1.5
- Ansible ≥ 2.15
- Google Cloud Platform
- Python 3
- Bash

## 📁 Estructura
```
├── terraform/          # Código de infraestructura
├── ansible/            # Playbooks y configuración
├── scripts/            # Orquestación (crear/destruir)
├── outputs/            # Outputs generados
└── docs/               # Documentación adicional
```

## 🚀 Uso Rápido
```bash
# 1. Configurar variables
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Editar con tu project_id

# 2. Ejecutar menú interactivo
./menu.sh
```

## 📊 Lo que demuestra este proyecto
✅ Infraestructura como Código profesional  
✅ Alta disponibilidad y escalabilidad  
✅ Automatización completa (crear/configurar/destruir)  
✅ Buenas prácticas de seguridad  
✅ Documentación clara  
✅ Scripting profesional  

## 👨‍💻 Autor
**Jorge Suazo** - [GitHub](https://github.com/jsuazof)

## 📅 Fecha de creación
2026-03-19
