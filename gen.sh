#!/usr/bin/env bash

mkdir -p certs

for i in 0 1 2; do
  openssl req  -nodes -new -x509 -keyout certs/client_$i.key -out certs/client_$i.cert -subj "/C=DK/ST=CPH/CN=localhost"
done

openssl req  -nodes -new -x509 -keyout certs/hospital.key -out certs/hospital.cert -subj "/C=DK/ST=CPH/CN=localhost"
