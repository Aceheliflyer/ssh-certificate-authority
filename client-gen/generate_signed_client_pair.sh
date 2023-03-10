#!/usr/bin/env sh
# -*- coding: utf-8 -*-
# shellcheck disable=3037,3045

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Variables
username="aceheliflyer"
ca_domain="achlfr.dev"
expiration_days=180

client_ssh_filename="ssh_client_${username}_ed25519"
client_ca_filename="ssh_client_ed25519_ca"
client_ssh_dir="${username}"
client_ca_dir="../ca-gen/client_ca"

client_ssh_path="${client_ssh_dir}/${client_ssh_filename}"
client_ca_path="${client_ca_dir}/${client_ca_filename}"

# Prompt for passphrases
echo
echo -e "${YELLOW}Obtaining passphrases...${NC}"
echo -n "Enter passphrase for client SSH key: "
read -rs client_ca_passphrase
echo
echo -n "Enter passphrase for client CA: "
read -rs host_ca_passphrase
echo
echo -e "${BLUE}Done.${NC}\n"

# Generate a new SSH key pair for the user
echo -e "${YELLOW}Generating client SSH key...${NC}"
ssh-keygen -t ed25519 \
  -f "${client_ssh_path}" \
  -N "${client_ca_passphrase}" \
  -C "${username}@${ca_domain}"
echo -e "${BLUE}Done.${NC}\n"

# Sign the public key with the SSH CA
echo -e "${YELLOW}Signing client SSH key...${NC}"
ssh-keygen -s "${client_ca_path}" \
  -I "${username}@${ca_domain}" \
  -n "${username}" \
  -V "+${expiration_days}d" \
  -P "${host_ca_passphrase}" \
  "${client_ssh_path}.pub"
echo -e "${BLUE}Done.${NC}\n"

echo -e "${GREEN}Successfully generated signed client keys!${NC}"
