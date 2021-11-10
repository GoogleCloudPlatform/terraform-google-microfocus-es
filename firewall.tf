#Access to ESCWA from restricted IP
resource "google_compute_firewall" "escwa" {
  name    = "${var.name}-firewall-rule-escwa"
  network = var.create_network ? google_compute_network.vpc[0].name : var.vpc_network
  target_tags = ["escwa"]
  allow {
    protocol = "tcp"
    ports    = ["10086"]
  }
  source_ranges=[var.ssh_ip]
}

#Access to ES TN3270 listener from load balancer
resource "google_compute_firewall" "tn3270" {
  name    = "${var.name}-firewall-rule-tn3270"
  network = var.create_network ? google_compute_network.vpc[0].name : var.vpc_network
  target_tags = ["es"]
  allow {
    protocol = "tcp"
    ports    = ["5557"]
  }
  source_ranges=["0.0.0.0/0"]
}

#Access to mfds, escwa and comms processes between ES instances
resource "google_compute_firewall" "esserver" {
  name    = "${var.name}-firewall-rule-esserver"
  network = var.create_network ? google_compute_network.vpc[0].name : var.vpc_network
  target_tags = ["es", "escwa"]
  allow {
    protocol = "tcp"
    ports    = ["1086", "10086", "5500-5600"]
  }
  source_tags = ["es", "escwa"]
}

#SSH RDP access
resource "google_compute_firewall" "ssh" {
  name    = "${var.name}-firewall-rule-ssh"
  network = var.create_network ? google_compute_network.vpc[0].name : var.vpc_network

  allow {
    protocol = "tcp"
    ports    = ["22","3389"]
  }
  source_tags = ["es", "escwa"]
}

resource "google_compute_firewall" "activedirectory" {
  name    = "${var.name}-firewall-rule-activedirectory"
  network = var.create_network ? google_compute_network.vpc[0].name : var.vpc_network
  target_tags = ["ad"]
  allow {
    protocol = "tcp"
    ports    = ["389"]
  }
  
  allow {
    protocol = "udp"
    ports    = ["389"]
  }
  
  source_tags = ["es", "escwa"]
}
