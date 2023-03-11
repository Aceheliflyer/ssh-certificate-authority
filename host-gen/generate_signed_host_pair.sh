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
host_domain="nuclear.achlfr.dev"
expiration_days=365
host_ssh_dir="${host_domain}"
host_ca_filename="ssh_host_ed25519_ca"
host_ca_dir="../ca-gen/host_ca"

# Create directory for the user
mkdir -p "${host_ssh_dir}"

# Prompt for passphrases
echo
echo -e "${YELLOW}Obtaining passphrase...${NC}"
echo -n "Enter passphrase for host CA: "
read -rs host_ca_passphrase
echo
echo -e "${BLUE}Done.${NC}\n"


# Generate a new SSH key pair for the host
echo -e "${YELLOW}Generating host SSH key...${NC}"
ssh-keygen -t ed25519 \
  -f "${host_ssh_dir}/ssh_host_${host_domain}_ed25519" \
  -N "" \
  -C "root@${host_domain}"
echo -e "${BLUE}Done.${NC}\n"


# Sign the public key with the SSH CA
echo -e "${YELLOW}Signing host SSH key...${NC}"
ssh-keygen -s "${host_ca_dir}/${host_ca_filename}" \
  -I "root@${host_domain}" \
  -h \
  -n "${host_domain}" \
  -V "+${expiration_days}d" \
  -P "${host_ca_passphrase}" \
  "${host_ssh_dir}/ssh_host_${host_domain}_ed25519.pub"
echo -e "${BLUE}Done.${NC}\n"

echo -e "${GREEN}Successfully generated signed host keys!${NC}"
echo -e "host SSH key pair: ${BLUE}${host_ssh_dir}/ssh_host_${host_domain}_ed25519${NC} ${BLUE}${host_ssh_dir}/ssh_host_${host_domain}_ed25519.pub${NC}"
