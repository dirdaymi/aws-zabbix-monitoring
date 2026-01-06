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
```
VPC: Zabbix-VPC (10.0.0.0/16)
└── Subnet: Public-Subnet (10.0.1.0/24)
    ├── Louki-Zabbix-Server (10.0.1.249)
    ├── Louki-Client-Linux (10.0.1.103)
    └── Louki-Client-Windows (10.0.1.248)
```

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
```bash
# Connexion SSH
ssh -i louki-key.pem ubuntu@<IP_PUBLIQUE_SERVEUR>

# Installation Docker
chmod +x install_docker.sh
sudo ./install_docker.sh

# Déploiement Zabbix
cd ~/aws-zabbix-monitoring-louki
docker-compose up -d
```

### 2. Client Linux
```bash
# Connexion SSH
ssh -i louki-key.pem ubuntu@<IP_PUBLIQUE_CLIENT_LINUX>

# Installation agent
cd ~/aws-zabbix-monitoring-louki
chmod +x scripts/install_zabbix_agent_linux.sh
sudo ./scripts/install_zabbix_agent_linux.sh
```

### 3. Client Windows
1. Connexion RDP avec Administrator
2. Exécuter PowerShell en tant qu'Administrateur
3. Lancer le script d'installation

## Configuration dans Zabbix Web

### 1. Ajout des hôtes
1. Accéder à http://<IP_PUBLIQUE_SERVEUR>
2. Configuration → Hosts → Create host

**Louki-Client-Linux :**
- Host name: Louki-Client-Linux
- Groups: Linux servers
- IP: 10.0.1.103
- Port: 10050
- Template: Template OS Linux by Zabbix agent

**Louki-Client-Windows :**
- Host name: Louki-Client-Windows
- Groups: Windows servers
- IP: 10.0.1.248
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
```bash
# Sur le serveur Zabbix
docker-compose logs
docker-compose ps

# Sur les clients
sudo systemctl status zabbix-agent2  # Linux
Get-Service "Zabbix Agent 2"        # Windows
```

## Conclusion
Ce guide couvre l'installation complète de l'infrastructure de monitoring.
Pour plus d'informations, consulter le rapport complet.
