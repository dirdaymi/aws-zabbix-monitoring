#!/bin/bash
# Script d'installation Docker pour ${PREFIX}-Zabbix-Server

echo "=========================================="
echo "INSTALLATION DOCKER - ${PREFIX}-Zabbix-Server"
echo "=========================================="

# Mise à jour du système
echo "1. Mise à jour du système..."
sudo apt update
sudo apt upgrade -y

# Installation Docker
echo "2. Installation de Docker..."
sudo apt install -y docker.io

# Installation Docker Compose
echo "3. Installation de Docker Compose..."
sudo apt install -y docker-compose

# Ajouter l'utilisateur au groupe docker
echo "4. Configuration des permissions..."
sudo usermod -aG docker $USER
sudo systemctl restart docker

# Vérification
echo "5. Vérification de l'installation..."
docker --version
docker-compose --version

echo "=========================================="
echo "INSTALLATION TERMINÉE AVEC SUCCÈS"
echo "Reconnectez-vous pour appliquer les changements de groupe"
echo "=========================================="
