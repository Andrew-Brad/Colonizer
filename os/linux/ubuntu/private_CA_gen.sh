#!/bin/bash

# Prompt:
# I want to have my own private certificate authority named "Andrew's Homelab".
# I would also like to issue an ssl cert for various internal web services using my private CA.
# Please lay out a bash script for me that will do this step by step, and mark up each line with a brief description of what that particular step does, as well as a short metaphor explaining the core concept to someone who may not be an expert.
# Please call out the various command inputs as variables that can be referenced throughout the script.

# Set variables
CA_NAME="andrews_homelab"
SERVICE_DOMAIN=".homelab"
SERVICE_NAME="internal-service"
CERT_VALIDITY_DAYS=100000

# Step 1: Create a private key for the Certificate Authority (CA) (w/o passphrase for flexibility and/or k8s)
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:4096 -out "${CA_NAME}_CA.key"

# Explanation: Generating a key for the CA is like creating a master key for a secure vault. This key will be used to sign other keys (certificates).

# Step 2: Create a self-signed certificate for the CA using the private key
openssl req -x509 -new -nodes -key "${CA_NAME}_CA.key" -sha256 -days $CERT_VALIDITY_DAYS -subj "/CN=${CA_NAME} CA" -out "${CA_NAME}_root_CA.crt"
# Explanation: This is like creating an official seal using the master key. It validates that the certificates issued by this CA are trustworthy.

# Step 3: Generate a private key for the specific service
openssl genpkey -algorithm RSA -out "${SERVICE_NAME}_key.key"
# Explanation: Think of this as creating a unique lock for the specific service's secure box.

# Step 4: Create a Certificate Signing Request (CSR) for the service
openssl req -new -key "${SERVICE_NAME}_key.key" -out "${SERVICE_NAME}_csr.csr" -subj "/CN=${SERVICE_DOMAIN}"
# Explanation: Making a request for an official stamp from the CA for the lock of the specific service's secure box.

# Step 5: Sign the service's CSR with the CA's private key to generate a certificate
openssl x509 -req -in "${SERVICE_NAME}_csr.csr" -CA "${CA_NAME}_CA.crt" -CAkey "${CA_NAME}_CA.key" -CAcreateserial -out "${SERVICE_NAME}_cert.crt" -days $CERT_VALIDITY_DAYS -sha256
# Explanation: The CA uses its master seal to validate and officially approve the lock created for the specific service.

# Optional: Clean up intermediate files (uncomment the lines below if desired)
# rm "${SERVICE_NAME}_csr.csr" "${CA_NAME}_CA.srl"

# Output success message
echo "SSL certificate for ${SERVICE_DOMAIN} has been created and signed by ${CA_NAME} CA."
