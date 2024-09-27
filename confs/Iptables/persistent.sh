#!/bin/bash

# Instalar herramienta de persistencia
sudo apt install iptables-persistent

# Saltos de línea
echo -n "$IFS"
echo -n "$IFS"

# Salvar cambios
sudo netfilter-persistent save