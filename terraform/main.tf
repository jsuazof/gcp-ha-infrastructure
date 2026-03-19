# ==============================================
# REDES
# ==============================================
resource "google_compute_network" "vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.network_name}-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
}

# ==============================================
# CLOUD NAT (para que las VMs puedan salir a internet)
# ==============================================
resource "google_compute_router" "router" {
  name    = "nat-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "nat-config"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# ==============================================
# FIREWALL
# ==============================================
resource "google_compute_firewall" "allow-health-checks" {
  name          = "allow-health-checks"
  network       = google_compute_network.vpc.name
  direction     = "INGRESS"
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  target_tags = ["allow-health-checks"]
}

resource "google_compute_firewall" "allow-http" {
  name          = "allow-http"
  network       = google_compute_network.vpc.name
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  target_tags = ["http-server"]
}

resource "google_compute_firewall" "allow-ssh" {
  name          = "allow-ssh"
  network       = google_compute_network.vpc.name
  source_ranges = ["YOUR_IP/32"]  # Reemplazar con tu IP

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["ssh-server"]
}

# ==============================================
# HEALTH CHECK
# ==============================================
resource "google_compute_health_check" "http" {
  name                = "http-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2

  http_health_check {
    port = 80
  }
}

# ==============================================
# INSTANCE TEMPLATE
# ==============================================
resource "google_compute_instance_template" "web_template" {
  name         = "web-template-${formatdate("YYYYMMDDhhmm", timestamp())}"
  machine_type = var.machine_type
  region       = var.region

  disk {
    source_image = "debian-cloud/debian-12"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network    = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.subnet.name
  }

  tags = ["allow-health-checks", "http-server", "ssh-server"]

  metadata = {
    startup-script = <<-EOF
      #!/bin/bash
      apt-get update
      apt-get install -y nginx curl
      
      # Obtener metadata
      NAME=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/hostname")
      IP=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip")
      ZONE=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/zone" | cut -d'/' -f4)
      
      # Página web
      cat <<HTML > /var/www/html/index.html
      <!DOCTYPE html>
      <html>
      <head><title>Servidor HA</title></head>
      <body>
        <h1>🚀 Servidor en GCP</h1>
        <p>Hostname: $NAME</p>
        <p>Zona: $ZONE</p>
        <p>IP: $IP</p>
        <p><small>Desplegado con Terraform + Ansible</small></p>
      </body>
      </html>
      HTML
      
      systemctl restart nginx
    EOF
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ==============================================
# MANAGED INSTANCE GROUP
# ==============================================
resource "google_compute_instance_group_manager" "web_mig" {
  name               = "web-mig"
  zone               = var.zones[0]
  base_instance_name = "web-vm"
  target_size        = var.instance_count
  version {
    instance_template = google_compute_instance_template.web_template.id
  }
  named_port {
    name = "http"
    port = 80
  }
  auto_healing_policies {
    health_check      = google_compute_health_check.http.id
    initial_delay_sec = 60
  }
}

# ==============================================
# BALANCEADOR DE CARGAS
# ==============================================
resource "google_compute_global_address" "lb_ip" {
  name = "web-lb-ip"
}

resource "google_compute_backend_service" "web_backend" {
  name             = "web-backend"
  protocol         = "HTTP"
  port_name        = "http"
  timeout_sec      = 10
  health_checks    = [google_compute_health_check.http.id]

  backend {
    group = google_compute_instance_group_manager.web_mig.instance_group
  }
}

resource "google_compute_url_map" "web_url_map" {
  name            = "web-url-map"
  default_service = google_compute_backend_service.web_backend.id
}

resource "google_compute_target_http_proxy" "web_proxy" {
  name    = "web-http-proxy"
  url_map = google_compute_url_map.web_url_map.id
}

resource "google_compute_global_forwarding_rule" "web_forwarding_rule" {
  name                  = "web-http-forwarding-rule"
  ip_protocol           = "TCP"
  port_range            = "80"
  target                = google_compute_target_http_proxy.web_proxy.id
  ip_address            = google_compute_global_address.lb_ip.address
  load_balancing_scheme = "EXTERNAL"
}
