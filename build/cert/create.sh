#!/bin/bash

# Generate Root CA
openssl genrsa -out ca.key 2048 || exit 1
openssl req -new -x509 -days 365 -key ca.key \
    -subj "/C=DE/ST=Bayern/L=TEAM23 Development/O=TEAM23 GmbH/OU=TEAM23 Development/CN=Local CA Root Cert" \
    -out ca.crt || exit 2

# Generate domain cert
openssl genrsa -out t23dev.key 2048 || exit 3
openssl req -new -sha256 \
    -key t23dev.key \
    -subj "/C=DE/ST=Bayern/L=TEAM23 Development/O=TEAM23 GmbH/OU=TEAM23 Development/CN=traefik.t23dev" \
    -reqexts SAN \
    -config <(cat /usr/local/etc/openssl/openssl.cnf <(printf "\n[SAN]\nsubjectAltName=DNS:traefik.t23dev,DNS:*.t23dev,DNS:*.*.t23dev,DNS:*.*.*.t23dev,DNS:*.*.*.*.t23dev")) \
    -out t23dev.csr || exit 4

# Sign local cert
openssl x509 -req \
    -extfile <(printf "subjectAltName=DNS:traefik.t23dev,DNS:*.t23dev,DNS:*.*.t23dev,DNS:*.*.*.t23dev,DNS:*.*.*.*.t23dev") \
    -days 1825 -in t23dev.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out t23dev.crt || exit 5

# Show certificate information
openssl x509 -in t23dev.crt -text || exit 6
