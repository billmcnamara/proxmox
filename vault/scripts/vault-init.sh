#!/bin/sh

# Check if Vault is already initialized
if vault status | grep -q 'Initialized.*true'; then
  echo "vault-init: Vault is already initialized."
  exit 0
else
 until vault status | grep -q 'Initialized.*false'; do
  echo "vault-init: Waiting for Vault to start and be ready for initialization..."
  sleep 2
 done
fi

# Initialize Vault and store the unseal keys and root token
vault operator init -key-shares=${VAULT_KEY_SHARES} -key-threshold=${VAULT_KEY_THRESHOLD} > /vault/init-output.txt

echo "vault-init: Vault initialized. Unseal keys and root token saved to /vault/init-output.txt"


# Get the first unseal key and use it to unseal Vault
UNSEAL_KEY=$(awk '/Unseal Key 1/ { print $NF }' /vault/init-output.txt)
ROOT_TOKEN=$(awk '/Initial Root Token/ { print $NF }' /vault/init-output.txt)

# Unseal Vault with the first unseal key
echo "vault-init: Unsealing Vault..."
vault operator unseal $UNSEAL_KEY

# Check if Vault is unsealed
until vault status | grep -q 'Sealed.*false'; do
  echo "vault-init: Waiting for Vault to unseal..."
  sleep 2
done

echo "vault-init: Vault is unsealed and ready."

# WARNING:
# tell user the keys:
echo "vault-init: Unseal Key 1: ${UNSEAL_KEY}"
echo "vault-init: Initial Root Token: ${ROOT_TOKEN}"

echo "vault-init: Vault initialized. remove keys and root token saved to /vault/init-output.txt"
# rm -f /vault/init-output.txt

export VAULT_ADDR=http://vault-container:8200

# Check if Vault is reachable
until vault status &>/dev/null; do
  echo "vault-init: Waiting for Vault to be reachable..."
  sleep 2
done

# Login using the root token (uncomment this if needed for the first time login)
vault login ${ROOT_TOKEN}

# Check if KV engine is already enabled
if ! vault secrets list | grep -q "ansible/"; then
  vault secrets enable -path=ansible -version=2 kv
fi

# Create a password secret at ansible/data/ansible-vault
vault kv put ansible/ansible-vault password="toto"

vault kv get ansible/ansible-vault

# Check if 'userpass' authentication is already enabled
if ! vault auth list | grep -q "userpass/"; then
  vault auth enable userpass
  vault policy write read-only read-only.hcl
  vault write auth/userpass/users/{{my_username}} password={{my_username}}1 policies=read-only
fi

echo "vault-init: Vault initialization and password creation complete."

# enable vault transit engine
#vault secrets enable transit
#
# create key1 with type ed25519
#vault write -f transit/keys/key1 type=ed25519
#
# create key2 with type ecdsa-p256
#vault write -f transit/keys/key2 type=ecdsa-p256
