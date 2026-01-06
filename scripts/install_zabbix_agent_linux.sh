#!/bin/bash
# Script d'installation de Zabbix Agent 2 pour Louki-Client-Linux

echo "=========================================="
echo "INSTALLATION ZABBIX AGENT - Louki-Client-Linux"
echo "=========================================="

# Variables
ZABBIX_SERVER="10.0.1.249"
HOSTNAME="Louki-Client-Linux"

# Installation des dépendances
echo "1. Mise à jour du système..."
sudo apt update
sudo apt upgrade -y

# Téléchargement du package Zabbix
echo "2. Téléchargement de l'agent Zabbix..."
wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-4+ubuntu22.04_all.deb

# Installation du package
echo "3. Installation du package..."
sudo dpkg -i zabbix-release_6.0-4+ubuntu22.04_all.deb
sudo apt update

# Installation de l'agent Zabbix 2
echo "4. Installation de Zabbix Agent 2..."
sudo apt install -y zabbix-agent2

# Configuration de l'agent
echo "5. Configuration de l'agent..."
sudo tee /etc/zabbix/zabbix_agent2.conf << CONFIGEOF
# Configuration Zabbix Agent 2 - Louki-Client-Linux
PidFile=/run/zabbix/zabbix_agent2.pid
LogFile=/var/log/zabbix/zabbix_agent2.log
LogFileSize=0
Server=
ServerActive=
Hostname=DESKTOP-TFHTUH6
HostMetadataItem=system.uname
Include=/etc/zabbix/zabbix_agent2.d/*.conf
CONFIGEOF

# Démarrage du service
echo "6. Démarrage du service..."
sudo systemctl restart zabbix-agent2
sudo systemctl enable zabbix-agent2

# Vérification
echo "7. Vérification de l'installation..."
sudo systemctl status zabbix-agent2 --no-pager

echo "=========================================="
echo "AGENT ZABBIX INSTALLÉ AVEC SUCCÈS"
echo "Hostname: DESKTOP-TFHTUH6"
echo "Serveur Zabbix: "
echo "=========================================="
