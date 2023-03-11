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
ca_domain="achlfr.dev"
ca_fqdn="*.${ca_domain}"
ca_expiration_days=1825
client_ca_filename="ssh_client_ed25519_ca"
host_ca_filename="ssh_host_ed25519_ca"
client_ca_dir="client_ca"
host_ca_dir="host_ca"

# Create directories for the client and host CAs
mkdir -p "${client_ca_dir}" "${host_ca_dir}"

# Prompt for passphrases
echo
echo -e "${YELLOW}Obtaining passphrases...${NC}"
echo -n "Enter passphrase for client CA: "
read -rs client_ca_passphrase
echo
echo -n "Enter passphrase for host CA: "
read -rs host_ca_passphrase
echo
echo -e "${BLUE}Done.${NC}\n"

# Generate entropy for key generation
echo -e "${YELLOW}Generating entropy...${NC}"
dd if=/dev/urandom of=/dev/null bs=4096 count=10
echo -e "${BLUE}Done.${NC}\n"

# Generate a new SSH key pair for the client CA
echo -e "${YELLOW}Generating client CA key...${NC}"
ssh-keygen -t ed25519 \
  -N "${client_ca_passphrase}" \
  -f "${client_ca_dir}/${client_ca_filename}" \
  -C "client-ca@${ca_domain}"
echo -e "${BLUE}Done.${NC}\n"

# Sign the client CA public key with the client CA private key
echo -e "${YELLOW}Signing client CA key...${NC}"
ssh-keygen -s "${client_ca_dir}/${client_ca_filename}" \
  -I "client-ca@${ca_domain}" \
  -n "${ca_fqdn}" \
  -V "+${ca_expiration_days}d" \
  -P "${client_ca_passphrase}" \
  "${client_ca_dir}/${client_ca_filename}.pub"
echo -e "${BLUE}Done.${NC}\n"

# Generate a new SSH key pair for the host CA
echo -e "${YELLOW}Generating host CA key...${NC}"
ssh-keygen -t ed25519 \
  -N "${host_ca_passphrase}" \
  -f "${host_ca_dir}/${host_ca_filename}" \
  -C "host-ca@${ca_domain}"
echo -e "${BLUE}Done.${NC}\n"

# Sign the host CA public key with the host CA private key
echo -e "${YELLOW}Signing host CA key...${NC}"
ssh-keygen -s "${host_ca_dir}/${host_ca_filename}" \
  -I "host-ca@${ca_domain}" \
  -h \
  -n "${ca_fqdn}" \
  -V "+${ca_expiration_days}d" \
  -P "${host_ca_passphrase}" \
  "${host_ca_dir}/${host_ca_filename}.pub"
echo -e "${BLUE}Done.${NC}\n"

# Output results
echo -e "${GREEN}Successfully generated client and host CA pair!${NC}"
echo -e "Client CA key pair: ${BLUE}${client_ca_dir}/${client_ca_filename}${NC} ${BLUE}${client_ca_dir}/${client_ca_filename}.pub${NC}"
echo -e "Host CA key pair: ${BLUE}${host_ca_dir}/${host_ca_filename}${NC} ${BLUE}${host_ca_dir}/${host_ca_filename}.pub${NC}"
