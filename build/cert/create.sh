#!/bin/bash

# Generate Root CA
openssl genrsa -out ca.key 2048 || exit 1
openssl req -new -x509 -days 365 -key ca.key \
    -subj "/C=DE/ST=Bayern/L=Kreativkombinat Development/O=Kreativkombinat GbR/OU=TEAM23 Development/CN=Local CA Root Cert" \
    -out ca.crt || exit 2

# Generate domain cert
openssl genrsa -out a25dev.key 2048 || exit 3
openssl req -new -sha256 \
    -key a25dev.key \
    -subj "/C=DE/ST=Bayern/L=Kreativkombinat Development/O=Kreativkombinat GbR/OU=Kreativkombinat Development/CN=traefik.a25dev" \
    -reqexts SAN \
    -config <(cat /usr/local/etc/openssl/openssl.cnf <(printf "\n[SAN]\nsubjectAltName=DNS:traefik.a25dev,DNS:*.a25dev,DNS:*.*.a25dev,DNS:*.*.*.a25dev,DNS:*.*.*.*.a25dev")) \
    -out a25dev.csr || exit 4

# Sign local cert
openssl x509 -req \
    -extfile <(printf "subjectAltName=DNS:traefik.a25dev,DNS:*.a25dev,DNS:*.*.a25dev,DNS:*.*.*.a25dev,DNS:*.*.*.*.a25dev") \
    -days 1825 -in a25dev.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out a25dev.crt || exit 5

# Show certificate information
openssl x509 -in a25dev.crt -text || exit 6
