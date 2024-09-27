#!/bin/bash

# Instala la herramienta
sudo apt install iptables

# Saltos de línea
echo -n "$IFS"
echo -n "$IFS"

# Consulta iptables
sudo iptables -L

# Saltos de línea
echo -n "$IFS"
echo -n "$IFS"

# Consulta tabla nat
sudo iptables -L -nv -t nat

# Saltos de línea
echo -n "$IFS"
echo -n "$IFS"

# Crear regla de enmascaramiento
sudo iptables -t nat -A POSTROUTING -o ens160 -j MASQUERADE