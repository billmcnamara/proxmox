
ui = true
api_addr = "http://0.0.0.0:8200"
disable_mlock = true

listener "tcp" {
  address                  = "0.0.0.0:8200"
  tls_disable              = "true"
//   proxy_protocol_behavior  = "use_always"
//   tls_cert_file            = "/vault/certs/localhost-fullchain.pem"
//   tls_key_file             = "/vault/certs/localhost.key"
//   tls_client_ca_file       = "/etc/ssl/cert.pem"
//   tls_disable_client_certs = "true"

  custom_response_headers {
    "default" = {
      "Cache-Control" = ["no-store", "no-cache", "must-revalidate", "max-age=0"],
      "Pragma"        = ["no-cache"],
      "Expires"       = ["0"]
    }
  }

}

storage "file" {
  path = "/vault/file"
}


