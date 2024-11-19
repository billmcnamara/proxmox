path "ansible/*" {
  capabilities = ["read", "list"]
}

path "*" {
  capabilities = ["read", "list"]
}