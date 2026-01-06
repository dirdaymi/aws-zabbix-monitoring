#!/bin/bash
# Script de création automatique du projet Zabbix AWS
# Auteur : Abdel-hamid Mahamat LOUKI
# Date : Janvier 2026

# Variables de configuration
PREFIX="Louki"
PROJECT_DIR="aws-zabbix-monitoring-louki"
ZABBIX_SERVER_IP="10.0.1.249"
LINUX_CLIENT_IP="10.0.1.103"
WINDOWS_CLIENT_IP="10.0.1.248"

echo "=========================================="
echo "CRÉATION DU PROJET ZABBIX AWS"
echo "Auteur : Abdel-hamid Mahamat LOUKI"
echo "Préfixe : $PREFIX"
echo "=========================================="

# Création de la structure de dossiers
echo "1. Création de la structure des dossiers..."
mkdir -p $PROJECT_DIR/{scripts,config,docs,screenshots/{aws,zabbix,terminal}}

# 1. FICHIER docker-compose.yml
echo "2. Création de docker-compose.yml..."
cat > $PROJECT_DIR/docker-compose.yml << 'EOF'
version: '3.5'
services:
  zabbix-server:
    image: zabbix/zabbix-server-mysql:ubuntu-6.0-latest
    container_name: zabbix-server
    restart: unless-stopped
    ports:
      - "10051:10051"
    environment:
      DB_SERVER_HOST: zabbix-mysql
      MYSQL_DATABASE: zabbix
      MYSQL_USER: zabbix
      MYSQL_PASSWORD: zabbixpassword
      MYSQL_ROOT_PASSWORD: rootpassword
    volumes:
      - zabbix_data:/var/lib/zabbix

  zabbix-web:
    image: zabbix/zabbix-web-nginx-mysql:ubuntu-6.0-latest
    container_name: zabbix-web
    restart: unless-stopped
    ports:
      - "80:8080"
      - "443:8443"
    environment:
      DB_SERVER_HOST: zabbix-mysql
      MYSQL_DATABASE: zabbix
      MYSQL_USER: zabbix
      MYSQL_PASSWORD: zabbixpassword
      ZBX_SERVER_HOST: zabbix-server
      PHP_TZ: "Europe/Paris"
    depends_on:
      - zabbix-server

  zabbix-mysql:
    image: mysql:8.0
    container_name: zabbix-mysql
    restart: unless-stopped
    command: --default-authentication-plugin=mysql_native_password
    environment:
      MYSQL_DATABASE: zabbix
      MYSQL_USER: zabbix
      MYSQL_PASSWORD: zabbixpassword
      MYSQL_ROOT_PASSWORD: rootpassword
    volumes:
      - mysql_data:/var/lib/mysql

volumes:
  mysql_data:
  zabbix_data:
EOF

# 2. FICHIER README.md
echo "3. Création de README.md..."
cat > $PROJECT_DIR/README.md << EOF
# Projet : Infrastructure Cloud de Supervision Centralisée sous AWS

## Auteur
**Abdel-hamid Mahamat LOUKI**  
Étudiant en 2e année cycle ingénieur informatique  
Université Mundiapolis - Année 2025/2026  
Encadré par : Prof. Azeddine KHIAT

## Description
Déploiement d'une infrastructure de monitoring centralisée sur AWS utilisant Zabbix en conteneurs Docker pour surveiller un parc hybride (Linux & Windows).

## Architecture AWS
- **VPC** : Zabbix-VPC (10.0.0.0/16)
- **Subnet** : Public-Subnet (10.0.1.0/24)
- **Instances EC2** :
  - ${PREFIX}-Zabbix-Server (t3.large Ubuntu) - IP: ${ZABBIX_SERVER_IP}
  - ${PREFIX}-Client-Linux (t3.medium Ubuntu) - IP: ${LINUX_CLIENT_IP}
  - ${PREFIX}-Client-Windows (t3.large Windows Server) - IP: ${WINDOWS_CLIENT_IP}

## Structure du dépôt
\`\`\`
aws-zabbix-monitoring-louki/
├── docker-compose.yml          # Configuration Docker Zabbix
├── scripts/                    # Scripts d'installation
├── config/                     # Configurations agents
├── docs/                       # Documentation
└── screenshots/                # Captures d'écran
\`\`\`

## Installation

### 1. Serveur Zabbix
\`\`\`bash
cd ~
git clone https://github.com/LoukiAbdelhamid/aws-zabbix-monitoring-louki.git
cd aws-zabbix-monitoring-louki
sudo apt install docker.io docker-compose -y
docker-compose up -d
\`\`\`

### 2. Client Linux
\`\`\`bash
# Exécuter le script d'installation
chmod +x scripts/install_zabbix_agent_linux.sh
sudo ./scripts/install_zabbix_agent_linux.sh
\`\`\`

### 3. Client Windows
Exécuter \`scripts/install_zabbix_windows.ps1\` en tant qu'Administrateur

## Accès
- Interface Zabbix : http://<IP_PUBLIQUE_SERVEUR>
- Identifiants : Admin / zabbix

## Documentation
Voir le dossier \`docs/\` pour le guide d'installation détaillé.

## Licence
Projet académique - Université Mundiapolis 2025/2026
EOF

# 3. SCRIPT install_docker.sh
echo "4. Création de scripts/install_docker.sh..."
cat > $PROJECT_DIR/scripts/install_docker.sh << 'EOF'
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
EOF

# 4. SCRIPT install_zabbix_agent_linux.sh
echo "5. Création de scripts/install_zabbix_agent_linux.sh..."
cat > $PROJECT_DIR/scripts/install_zabbix_agent_linux.sh << EOF
#!/bin/bash
# Script d'installation de Zabbix Agent 2 pour ${PREFIX}-Client-Linux

echo "=========================================="
echo "INSTALLATION ZABBIX AGENT - ${PREFIX}-Client-Linux"
echo "=========================================="

# Variables
ZABBIX_SERVER="${ZABBIX_SERVER_IP}"
HOSTNAME="${PREFIX}-Client-Linux"

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
# Configuration Zabbix Agent 2 - ${PREFIX}-Client-Linux
PidFile=/run/zabbix/zabbix_agent2.pid
LogFile=/var/log/zabbix/zabbix_agent2.log
LogFileSize=0
Server=${ZABBIX_SERVER}
ServerActive=${ZABBIX_SERVER}
Hostname=${HOSTNAME}
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
echo "Hostname: ${HOSTNAME}"
echo "Serveur Zabbix: ${ZABBIX_SERVER}"
echo "=========================================="
EOF

# 5. SCRIPT install_zabbix_windows.ps1
echo "6. Création de scripts/install_zabbix_windows.ps1..."
cat > $PROJECT_DIR/scripts/install_zabbix_windows.ps1 << EOF
# Script PowerShell pour installer Zabbix Agent sur ${PREFIX}-Client-Windows
# À exécuter en tant qu'Administrateur

Write-Host "==========================================" -ForegroundColor Green
Write-Host "INSTALLATION ZABBIX AGENT - ${PREFIX}-Client-Windows" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

# Configuration
\$ZabbixServer = "${ZABBIX_SERVER_IP}"
\$Hostname = "${PREFIX}-Client-Windows"
\$DownloadURL = "https://cdn.zabbix.com/zabbix/binaries/stable/6.0/6.0.43/zabbix_agent2-6.0.43-windows-amd64-openssl.msi"
\$InstallerPath = "\$env:TEMP\\zabbix_agent2.msi"

# Téléchargement
Write-Host "1. Téléchargement de l'agent Zabbix..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri \$DownloadURL -OutFile \$InstallerPath
    Write-Host "   ✓ Téléchargement réussi" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Erreur de téléchargement: \$_" -ForegroundColor Red
    exit 1
}

# Installation
Write-Host "2. Installation en cours..." -ForegroundColor Yellow
\$InstallArgs = "/i `"\$InstallerPath`" /quiet /norestart SERVER=\$ZabbixServer HOSTNAME=\$Hostname"
Start-Process msiexec.exe -Wait -ArgumentList \$InstallArgs

# Vérification du service
Write-Host "3. Vérification de l'installation..." -ForegroundColor Yellow
\$Service = Get-Service "Zabbix Agent 2" -ErrorAction SilentlyContinue
if (\$Service) {
    Write-Host "   ✓ Service Zabbix Agent 2 trouvé" -ForegroundColor Green
    Write-Host "   Status: \$(\$Service.Status)" -ForegroundColor Cyan
} else {
    Write-Host "   ✗ Service Zabbix Agent 2 non trouvé" -ForegroundColor Red
}

# Création du fichier de configuration personnalisé
Write-Host "4. Configuration personnalisée..." -ForegroundColor Yellow
\$ConfigContent = @"
# Configuration Zabbix Agent 2 - ${PREFIX}-Client-Windows
LogFile=C:\\Program Files\\Zabbix Agent 2\\zabbix_agent2.log
Server=\${ZabbixServer}
ServerActive=\${ZabbixServer}
Hostname=\${Hostname}
"@

\$ConfigContent | Out-File -FilePath "C:\\Program Files\\Zabbix Agent 2\\zabbix_agent2_louki.conf" -Encoding UTF8
Write-Host "   ✓ Fichier de configuration créé" -ForegroundColor Green

Write-Host "==========================================" -ForegroundColor Green
Write-Host "INSTALLATION TERMINÉE" -ForegroundColor Green
Write-Host "Hostname: \$Hostname" -ForegroundColor Cyan
Write-Host "Serveur Zabbix: \$ZabbixServer" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Green
EOF

# 6. CONFIGURATION agent Linux
echo "7. Création de config/zabbix_agent2_linux.conf..."
cat > $PROJECT_DIR/config/zabbix_agent2_linux.conf << EOF
# Configuration Zabbix Agent 2 - ${PREFIX}-Client-Linux
# Fichier généré automatiquement le $(date)

PidFile=/run/zabbix/zabbix_agent2.pid
LogFile=/var/log/zabbix/zabbix_agent2.log
LogFileSize=0
Server=${ZABBIX_SERVER_IP}
ServerActive=${ZABBIX_SERVER_IP}
Hostname=${PREFIX}-Client-Linux
HostMetadataItem=system.uname
Include=/etc/zabbix/zabbix_agent2.d/*.conf
ControlSocket=/tmp/agent.sock

# Métriques personnalisées (optionnelles)
UserParameter=custom.cpu.usage,top -bn1 | grep "Cpu(s)" | sed "s/.*, *\\([0-9.]*\\)%* id.*/\\1/" | awk '{print 100 - \$1}'
UserParameter=custom.memory.usage,free | grep Mem | awk '{print \$3/\$2 * 100.0}'
UserParameter=custom.disk.root,df / | tail -1 | awk '{print \$5}' | sed 's/%//'
EOF

# 7. CONFIGURATION agent Windows
echo "8. Création de config/zabbix_agent2_windows.conf..."
cat > $PROJECT_DIR/config/zabbix_agent2_windows.conf << EOF
# Configuration Zabbix Agent 2 - ${PREFIX}-Client-Windows
# Fichier généré automatiquement le $(date)

LogFile=C:\\Program Files\\Zabbix Agent 2\\zabbix_agent2.log
Server=${ZABBIX_SERVER_IP}
ServerActive=${ZABBIX_SERVER_IP}
Hostname=${PREFIX}-Client-Windows

# Performance Counters Windows
PerfCounter=ProcessorTotal,"\\Processor(_Total)\\% Processor Time",30
PerfCounter=MemoryAvailable,"\\Memory\\Available Bytes",30
PerfCounter=DiskCFree,"\\LogicalDisk(C:)\\% Free Space",60
PerfCounter=DiskDFree,"\\LogicalDisk(D:)\\% Free Space",60

# Services Windows à monitorer
# Format: service.<nom_affichage>,<nom_service>,<intervalle>
service.AdobeARMservice,AdobeARMservice,60
service.WinRM,WinRM,60
EOF

# 8. GUIDE d'installation
echo "9. Création de docs/guide_installation.md..."
cat > $PROJECT_DIR/docs/guide_installation.md << EOF
# Guide d'Installation Détaillé
## Projet : Infrastructure Cloud de Supervision Centralisée sous AWS
### Auteur : Abdel-hamid Mahamat LOUKI

## Table des Matières
1. [Prérequis](#prérequis)
2. [Architecture AWS](#architecture-aws)
3. [Configuration Réseau](#configuration-réseau)
4. [Déploiement des Instances](#déploiement-des-instances)
5. [Installation Zabbix](#installation-zabbix)
6. [Configuration des Agents](#configuration-des-agents)
7. [Monitoring dans Zabbix](#monitoring-dans-zabbix)
8. [Dépannage](#dépannage)

## Prérequis
- Compte AWS avec crédits (AWS Learner Lab recommandé)
- Client SSH (PuTTY, Terminal)
- Client RDP pour Windows
- Connaissances de base Linux/Windows

## Architecture AWS

### Topologie Réseau
\`\`\`
VPC: Zabbix-VPC (10.0.0.0/16)
└── Subnet: Public-Subnet (10.0.1.0/24)
    ├── ${PREFIX}-Zabbix-Server (10.0.1.249)
    ├── ${PREFIX}-Client-Linux (10.0.1.103)
    └── ${PREFIX}-Client-Windows (10.0.1.248)
\`\`\`

### Security Groups
**SG-Zabbix-Server :**
- Port 80/443 : 0.0.0.0/0
- Port 10051 : SG-Zabbix-Agents
- Port 22 : Votre IP

**SG-Zabbix-Agents :**
- Port 10050 : SG-Zabbix-Server
- Port 22 : SG-Zabbix-Server (Linux)
- Port 3389 : Votre IP (Windows)

## Déploiement des Instances

### 1. Serveur Zabbix
\`\`\`bash
# Connexion SSH
ssh -i louki-key.pem ubuntu@<IP_PUBLIQUE_SERVEUR>

# Installation Docker
chmod +x install_docker.sh
sudo ./install_docker.sh

# Déploiement Zabbix
cd ~/aws-zabbix-monitoring-louki
docker-compose up -d
\`\`\`

### 2. Client Linux
\`\`\`bash
# Connexion SSH
ssh -i louki-key.pem ubuntu@<IP_PUBLIQUE_CLIENT_LINUX>

# Installation agent
cd ~/aws-zabbix-monitoring-louki
chmod +x scripts/install_zabbix_agent_linux.sh
sudo ./scripts/install_zabbix_agent_linux.sh
\`\`\`

### 3. Client Windows
1. Connexion RDP avec Administrator
2. Exécuter PowerShell en tant qu'Administrateur
3. Lancer le script d'installation

## Configuration dans Zabbix Web

### 1. Ajout des hôtes
1. Accéder à http://<IP_PUBLIQUE_SERVEUR>
2. Configuration → Hosts → Create host

**${PREFIX}-Client-Linux :**
- Host name: ${PREFIX}-Client-Linux
- Groups: Linux servers
- IP: ${LINUX_CLIENT_IP}
- Port: 10050
- Template: Template OS Linux by Zabbix agent

**${PREFIX}-Client-Windows :**
- Host name: ${PREFIX}-Client-Windows
- Groups: Windows servers
- IP: ${WINDOWS_CLIENT_IP}
- Port: 10050
- Template: Template OS Windows by Zabbix agent

### 2. Vérification
- Monitoring → Hosts : Statut ZBX doit être vert
- Monitoring → Latest data : Données doivent apparaître

## Dépannage

### Problèmes courants
1. **Agents non connectés** : Vérifier les Security Groups
2. **Erreur Database** : Redémarrer les conteneurs Docker
3. **Pas de données** : Vérifier la configuration des agents

### Commandes de diagnostic
\`\`\`bash
# Sur le serveur Zabbix
docker-compose logs
docker-compose ps

# Sur les clients
sudo systemctl status zabbix-agent2  # Linux
Get-Service "Zabbix Agent 2"        # Windows
\`\`\`

## Conclusion
Ce guide couvre l'installation complète de l'infrastructure de monitoring.
Pour plus d'informations, consulter le rapport complet.
EOF

# 9. FICHIER de configuration AWS (optionnel)
echo "10. Création de config/aws_config.txt..."
cat > $PROJECT_DIR/config/aws_config.txt << EOF
# Configuration AWS - Projet Zabbix
# Auteur : Abdel-hamid Mahamat LOUKI
# Date : $(date)

=== CONFIGURATION RÉSEAU ===
VPC:
  Nom: Zabbix-VPC
  CIDR: 10.0.0.0/16
  Région: us-east-1

Subnet:
  Nom: Public-Subnet
  CIDR: 10.0.1.0/24
  AZ: us-east-1a
  Auto-assign IP: Oui

Internet Gateway:
  Nom: Zabbix-IGW
  État: Attached to Zabbix-VPC

=== INSTANCES EC2 ===
1. ${PREFIX}-Zabbix-Server:
   - Type: t3.large
   - OS: Ubuntu 22.04
   - IP Privée: ${ZABBIX_SERVER_IP}
   - Security Group: SG-Zabbix-Server

2. ${PREFIX}-Client-Linux:
   - Type: t3.medium
   - OS: Ubuntu 22.04
   - IP Privée: ${LINUX_CLIENT_IP}
   - Security Group: SG-Zabbix-Agents

3. ${PREFIX}-Client-Windows:
   - Type: t3.large
   - OS: Windows Server 2022
   - IP Privée: ${WINDOWS_CLIENT_IP}
   - Security Group: SG-Zabbix-Agents

=== PORTS OUVERTS ===
Serveur Zabbix (SG-Zabbix-Server):
  - 80 (HTTP) depuis 0.0.0.0/0
  - 443 (HTTPS) depuis 0.0.0.0/0
  - 10051 (Zabbix) depuis SG-Zabbix-Agents
  - 22 (SSH) depuis votre IP

Agents (SG-Zabbix-Agents):
  - 10050 (Zabbix) depuis SG-Zabbix-Server
  - 22 (SSH) depuis SG-Zabbix-Server
  - 3389 (RDP) depuis votre IP

=== CRÉDENTIELS ===
Zabbix Web:
  - URL: http://<IP_PUBLIQUE_SERVEUR>
  - Utilisateur: Admin
  - Mot de passe: zabbix

AWS:
  - Région: us-east-1 (N. Virginia)
  - Budget: 50$ (Learner Lab)
EOF

# 10. FICHIER pour le rapport (résumé)
echo "11. Création de docs/resume_projet.md..."
cat > $PROJECT_DIR/docs/resume_projet.md << EOF
# Résumé du Projet
## Mise en œuvre d'une infrastructure cloud de supervision centralisée sous AWS

### Informations Générales
- **Étudiant** : Abdel-hamid Mahamat LOUKI
- **Établissement** : Université Mundiapolis
- **Filière** : Cycle Ingénieur en Informatique
- **Année** : 2025/2026
- **Encadrant** : Prof. Azeddine KHIAT

### Objectifs Réalisés
1. ✅ Déploiement d'une infrastructure AWS complète
2. ✅ Installation de Zabbix en environnement conteneurisé
3. ✅ Configuration des agents sur Linux et Windows
4. ✅ Mise en place du monitoring centralisé
5. ✅ Documentation complète du projet

### Architecture Technique
\`\`\`
Infrastructure AWS:
  ├── VPC: Zabbix-VPC (10.0.0.0/16)
  ├── 3 instances EC2:
  │   ├── ${PREFIX}-Zabbix-Server (t3.large Ubuntu)
  │   ├── ${PREFIX}-Client-Linux (t3.medium Ubuntu)
  │   └── ${PREFIX}-Client-Windows (t3.large Windows)
  └── Groupes de sécurité configurés

Stack Technologique:
  ├── Monitoring: Zabbix 6.0
  ├── Conteneurisation: Docker + Docker Compose
  ├── Base de données: MySQL 8.0
  └── Web: Nginx + PHP
\`\`\`

### Résultats
- Interface Zabbix accessible via HTTP
- Agents Linux et Windows configurés
- Données de monitoring collectées
- Alertes configurées et fonctionnelles
- Dashboard de supervision opérationnel

### Compétences Développées
1. Cloud Computing (AWS EC2, VPC, Security)
2. DevOps (Docker, Conteneurisation)
3. Monitoring (Zabbix, Métriques, Alertes)
4. Administration Système (Linux, Windows)
5. Documentation Technique

### Difficultés et Solutions
1. **Connectivité réseau AWS** : Configuration détaillée des Security Groups
2. **Installation Zabbix** : Utilisation de Docker Compose pour simplification
3. **Agents Windows** : Création de template personnalisé
4. **Documentation** : Scripts automatisés et guides pas-à-pas

### Perspectives
- Ajout de la haute disponibilité
- Intégration avec d'autres services AWS
- Automatisation avec Terraform/Ansible
- Extension à d'autres systèmes d'exploitation

---
**Projet académique - Tous droits réservés**
EOF

# Rendre les scripts exécutables
echo "12. Attribution des permissions d'exécution..."
chmod +x $PROJECT_DIR/scripts/*.sh
chmod +x $PROJECT_DIR/scripts/*.ps1 2>/dev/null || true

# Créer un fichier .gitignore
echo "13. Création de .gitignore..."
cat > $PROJECT_DIR/.gitignore << 'EOF'
# Fichiers temporaires
*.tmp
*.log
*.pid

# Secrets
*.pem
*.key
*password*
*secret*

# Environnements virtuels
venv/
env/

# IDE
.vscode/
.idea/
*.swp

# Système
.DS_Store
Thumbs.db

# Docker
docker-compose.override.yml
EOF

# Créer un fichier LICENSE
echo "14. Création de LICENSE..."
cat > $PROJECT_DIR/LICENSE << 'EOF'
PROJET ACADÉMIQUE - LICENCE D'UTILISATION

Copyright (c) 2026 Abdel-hamid Mahamat LOUKI

Ce projet est soumis à la licence académique suivante :

1. DROITS D'UTILISATION
   - Ce projet peut être utilisé à des fins éducatives et d'apprentissage
   - La redistribution est autorisée avec attribution de l'auteur
   - Les modifications sont permises pour usage personnel

2. RESTRICTIONS
   - Usage commercial interdit sans autorisation
   - Aucune garantie n'est fournie
   - L'auteur n'est pas responsable des dommages

3. ATTRIBUTION
   Toute utilisation de ce projet doit inclure la mention :
   "Projet réalisé par Abdel-hamid Mahamat LOUKI - Université Mundiapolis 2026"

Pour toute question : louki.abdelhamid@etudiant.mundiapolis.ma
EOF

# Résumé final
echo "=========================================="
echo "CRÉATION TERMINÉE AVEC SUCCÈS !"
echo "=========================================="
echo "Structure créée dans : $PROJECT_DIR"
echo ""
echo "FICHIERS CRÉÉS :"
find $PROJECT_DIR -type f | sort | sed 's/^/  /'
echo ""
echo "TOTAL : $(find $PROJECT_DIR -type f | wc -l) fichiers"
echo ""
echo "PROCHAINES ÉTAPES :"
echo "1. Examiner les fichiers créés"
echo "2. Adapter les adresses IP si nécessaire"
echo "3. Créer un dépôt GitHub :"
echo "   cd $PROJECT_DIR"
echo "   git init"
echo "   git add ."
echo "   git commit -m 'Projet Zabbix AWS - ${PREFIX}'"
echo "   git remote add origin https://github.com/LoukiAbdelhamid/aws-zabbix-monitoring-louki.git"
echo "   git push -u origin main"
echo ""
echo "BON TRAVAIL !"
echo "=========================================="