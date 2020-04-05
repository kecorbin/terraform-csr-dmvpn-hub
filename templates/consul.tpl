#!/bin/bash
# WAN_IP=`curl http://169.254.169.254/latest/meta-data/public-ipv4`
LAN_IP=`curl http://169.254.169.254/latest/meta-data/local-ipv4`

#Utils
sudo apt-get update
sudo apt-get install -y unzip curl jq dnsmasq

#Download Consul
CONSUL_VERSION="1.7.0"
curl --silent --remote-name https://releases.hashicorp.com/consul/$${CONSUL_VERSION}/consul_$${CONSUL_VERSION}_linux_amd64.zip

#Install Consul
unzip consul_$${CONSUL_VERSION}_linux_amd64.zip
sudo chown root:root consul
sudo mv consul /usr/local/bin/
consul -autocomplete-install
complete -C /usr/local/bin/consul consul

#Create Consul User
sudo useradd --system --home /etc/consul.d --shell /bin/false consul
sudo mkdir --parents /opt/consul
sudo chown --recursive consul:consul /opt/consul

#Create Systemd Config
sudo cat << EOF > /etc/systemd/system/consul.service
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/consul.d/consul.hcl

[Service]
User=consul
Group=consul
ExecStart=/usr/local/bin/consul agent -bind $LAN_IP -config-dir=/etc/consul.d/
ExecReload=/usr/local/bin/consul reload
KillMode=process
Restart=always
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

#Create config dir
sudo mkdir --parents /etc/consul.d
sudo touch /etc/consul.d/consul.hcl
sudo chown --recursive consul:consul /etc/consul.d
sudo chmod 640 /etc/consul.d/consul.hcl


cat << EOF > /etc/consul.d/consul.hcl
datacenter = "${datacenter}"
primary_datacenter = "${primary_datacenter}"
data_dir = "/opt/consul"
connect {
  enabled = true
}
ui = true
server = true
bootstrap_expect = 1
ports {
  grpc = 8502
}
client_addr = "0.0.0.0"
enable_central_service_config = true
EOF

#Enable the service
sudo systemctl enable consul
sudo service consul start
sudo service consul status

#Install Docker
sudo snap install docker
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sleep 10
sudo usermod -aG docker ubuntu

cat << EOF > /home/ubuntu/proxy-defaults.hcl
Kind = "proxy-defaults"
Name = "global"
MeshGateway {
   Mode = "local"
}
EOF

consul config write proxy-defaults.hcl
mkdir -p /home/ubuntu/app
cat << EOF > /home/ubuntu/app/currency.hcl
service {
  name = "currency"
  id = "currency"
  address = "$LAN_IP"
  port = 9094
  connect {
    sidecar_service {
      port = 20000
      check {
        name = "Connect Envoy Sidecar"
        tcp = "$LAN_IP:20000"
        interval ="10s"
      }
    }
  }
}
EOF

    # Run currency service instances

cat << EOF > /home/ubuntu/app/docker-compose.yml
version: "3.3"
services:
  # Define currency service and envoy sidecar proxy for version 2 of the service
  currency:
    image: nicholasjackson/fake-service:v0.7.3
    network_mode: "host"
    environment:
      LISTEN_ADDR: 0.0.0.0:9094
      NAME: currency
      MESSAGE: "Currency Service running in ${datacenter}"
      SERVER_TYPE: "http"
    volumes:
      - "./currency.hcl:/config/currency.hcl"

  currency_proxy:
    image: nicholasjackson/consul-envoy
    network_mode: "host"
    environment:
      CONSUL_HTTP_ADDR: $LAN_IP:8500
      CONSUL_GRPC_ADDR: $LAN_IP:8502
      SERVICE_CONFIG: /config/currency.hcl
    volumes:
      - "./currency.hcl:/config/currency.hcl"
    command: ["consul", "connect", "envoy", "-admin-bind", "$LAN_IP:19094", "-sidecar-for", "currency"]

EOF
mkdir -p /home/ubuntu/gateway
cat << EOF > /home/ubuntu/gateway/docker-compose.yml
version: "3.3"
services:

  gateway:
    image: nicholasjackson/consul-envoy
    network_mode: "host"
    environment:
      CONSUL_HTTP_ADDR: $LAN_IP:8500
      CONSUL_GRPC_ADDR: $LAN_IP:8502
    command: [
      "consul",
      "connect", "envoy",
      "-mesh-gateway",
      "-register",
      "-address", "$LAN_IP:8443",
      "--",
      "-l", "debug"]    
EOF

sudo docker-compose -f /home/ubuntu/app/docker-compose.yml up -d
sudo docker-compose -f /home/ubuntu/gateway/docker-compose.yml up -d