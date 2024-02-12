disable_sealwrap = true
ui = true
api_addr = "0.0.0.0:8200"
cluster_addr = "https://127.0.0.1:8201"
default_lease_ttl = "168h"
max_lease_ttl = "0h"

listener "tcp" {
  address = "[::]:8200"
  tls_disable = false
  tls_cert_file = "/vault/config/ssl/vault.crt"
  tls_key_file = "/vault/config/ssl/vault_private_key"
}

storage "raft" {
  path = "/vault/data"
  node_id = "raft_node_1"
}

backend "file" {
  path = "/vault/file"
}