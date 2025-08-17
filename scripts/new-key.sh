#!/bin/bash

ssh-keygen -t ed25519 -f ./terraform -C "terraform"

echo ''
echo 'Private key'
cat ./terraform
echo ''
echo ''
echo 'Public key'
cat ./terraform.pub
