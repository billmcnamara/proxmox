#!/bin/sh
echo "Attempting to login to Vault..."
env
vault login -method=userpass \
    username={{my_username}} \
    password={{my_username}}1

mkdir -p /private/ansible-vault
vault kv get -field=password -mount="ansible" "ansible-vault" > /private/ansible-vault/ansible.pw

exec "$@"
