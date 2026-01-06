# **RAPPORT DE PROJET - MISE EN ŒUVRE D'UNE INFRASTRUCTURE CLOUD DE SUPERVISION CENTRALISÉE SOUS AWS**

---

## 📊 Mise en œuvre d'une infrastructure cloud de supervision centralisée sous AWS : Déploiement de Zabbix conteneurisé pour le monitoring d'un parc hybride (Linux & Windows)

---

### **Page de Garde**



**Établissement :** Université Mundiapolis  
**Filière :** Cycle Ingénieur en Informatique  
**Année :** 2e 
**Année Universitaire :** 2025/2026

**Titre du Projet :** Mise en œuvre d'une infrastructure cloud de supervision centralisée sous AWS : Déploiement de Zabbix conteneurisé pour le monitoring d'un parc hybride (Linux & Windows)

**Étudiant :** Abdel-hamid Mahamat LOUKI  
**Encadrant :** Prof. Azeddine KHIAT 

---

## 📋 **Sommaire**

1. [Introduction](#1-introduction)
2. [Architecture Réseau AWS](#2-architecture-réseau-aws)
3. [Architecture des Instances EC2](#3-architecture-des-instances-ec2)
4. [Déploiement du Serveur Zabbix](#4-déploiement-du-serveur-zabbix)
5. [Configuration des Clients (Agents)](#5-configuration-des-clients-agents)
6. [Monitoring et Tableaux de Bord](#6-monitoring-et-tableaux-de-bord)
7. [Conclusion](#7-conclusion)
8. [Annexes](#8-annexes)

---

## **1. Introduction**

### **1.1 Contexte du Projet**

Dans le cadre de ma formation d'ingénieur en informatique à l'Université Mundiapolis, ce projet avait pour objectif de concevoir et déployer une infrastructure de supervision centralisée dans le cloud AWS. L'objectif était de monitorer un parc informatique hybride composé de machines Linux et Windows en utilisant Zabbix, une solution open-source de monitoring, déployée en conteneurs Docker.

Ce projet s'inscrit dans une démarche d'apprentissage pratique des technologies cloud, de conteneurisation et de supervision d'infrastructure, essentielles pour un futur ingénieur en systèmes et réseaux.

### **1.2 Objectifs Spécifiques**

- ✅ Déployer une infrastructure AWS complète (VPC, instances EC2, groupes de sécurité)
- ✅ Mettre en place Zabbix en environnement conteneurisé avec Docker Compose
- ✅ Configurer des agents Zabbix sur des instances Linux et Windows
- ✅ Établir un système de monitoring centralisé avec tableaux de bord opérationnels
- ✅ Documenter l'ensemble du processus pour validation académique
- ✅ Respecter les contraintes du AWS Learner Lab (budget, types d'instances, région)

### **1.3 Technologies et Outils Utilisés**

| **Catégorie** | **Technologies** |
|---------------|------------------|
| Cloud | AWS (VPC, EC2, Security Groups, IAM) |
| Monitoring | Zabbix 5.0.47 (version visible sur les captures) |
| Conteneurisation | Docker, Docker Compose |
| Systèmes d'exploitation | Ubuntu Server 22.04 LTS, Windows Server 2022 |
| Gestion de version | GitHub |
| Outils | AWS CLI, Docker CLI, Zabbix Agent 2 |

---

## **2. Architecture Réseau AWS**

### **2.1 Conception du VPC**

Pour respecter les limitations du AWS Learner Lab, une architecture simplifiée a été adoptée avec un VPC unique et un sous-réseau public, évitant ainsi la complexité d'une architecture VPN.

**Configuration du VPC :**
- **Nom :** Zabbix-VPC
- **ID :** vpc-08923a350697fbcea
- **Plage CIDR :** 10.0.0.0/16
- **Région :** us-east-1 (Virginie du Nord)
- **DNS Resolution :** Activé
- **Hostnames DNS :** Désactivé (limitation du lab)

![VPC Details](captures/capture%20(2).png)

**Figure 1 : Détail du VPC Zabbix-VPC** - Vue de la console AWS montrant le VPC vpc-08923a350697fbcea avec CIDR 10.0.0.0/16, DNS désactivé et emplacement par défaut.

### **2.2 Configuration du Subnet Public**

Un subnet public a été créé pour héberger toutes les instances, avec activation de l'attribution automatique d'adresses IP publiques pour faciliter l'accès.

**Détails du Subnet :**
- **Nom :** Public-Subnet
- **ID :** subnet-0fb9f46a18b9d1982
- **CIDR :** 10.0.1.0/24
- **Zone de disponibilité :** us-east-1a
- **Attribution IP publique :** Activée (auto-assign)

![Subnet Configuration](captures/capture%20(1).png)

**Figure 2 : Configuration du Subnet Public-Subnet** - Modification des paramètres pour activer l'attribution automatique d'adresses IPv4 publiques (subnet-0fb9f46a18b9d1982, CIDR 10.0.1.0/24).

### **2.3 Configuration des Groupes de Sécurité**

Deux groupes de sécurité distincts ont été créés pour respecter le principe de moindre privilège.

**SG-Zabbix-Server (sg-0de64d0ab54c7ce56) :**
- HTTP (80) - IPv4 - 0.0.0.0/0
- SSH (22) - IPv4 - 0.0.0.0/0 (à restreindre en prod)
- HTTPS (443) - IPv4 - 0.0.0.0/0
- TCP custom (10051) - IPv4 - 0.0.0.0/0 (pour Zabbix Server)

**SG-Zabbix-Agents :**
- Zabbix Agent (10050) - IPv4 - Source SG-Zabbix-Server uniquement
- SSH (22) - IPv4 - Source SG-Zabbix-Server (pour Linux)
- RDP (3389) - IPv4 - Adresse IP personnelle (pour Windows)

![Security Group Rules](captures/capture%20(3).png)

**Figure 3 : Configuration du Security Group SG-Zabbix-Server** - Règles entrantes autorisant les ports 80, 22, 443 et 10051 pour le serveur Zabbix.

---

## **3. Architecture des Instances EC2**

### **3.1 Sélection et Configuration des Instances**

Trois instances EC2 ont été déployées dans le subnet public, toutes de type **t3.micro** pour respecter les contraintes du AWS Learner Lab. Les performances ont été suffisantes pour les besoins du projet.

| **Nom** | **ID Instance** | **Type** | **OS** | **IP Privée** |
|---------|-----------------|----------|--------|---------------|
| Louki-Zabbix-Server | i-0e7993c7369648ab5 | t3.micro | Ubuntu 22.04 LTS | 10.0.1.249 |
| Louki-Client-Linux | i-05c2a6ca8008f0fa8 | t3.micro | Ubuntu 22.04 LTS | 10.0.1.103 |
| Louki-Client-Windows | i-04675eee3adc8a2e4 | t3.micro | Windows Server 2022 | 10.0.1.248 |

### **3.2 Attribution des Adresses IP**

- **Serveur Zabbix :** IP privée 10.0.1.249, IP publique 54.90.108.60
- **Client Linux :** IP privée 10.0.1.103 (pas d'IP publique assignée)
- **Client Windows :** IP privée 10.0.1.248 (pas d'IP publique assignée)

L'accès aux clients se fait exclusivement via le serveur Zabbix en utilisant leurs adresses IP privées, renforçant la sécurité.

![EC2 Running Instances](captures/capture%20(4).png)

**Figure 4 : Instances EC2 en état Running** - Vue de la console EC2 montrant les 3 instances Louki-Zabbix-Server, Louki-Client-Linux et Louki-Client-Windows, toutes en état "En cours d'exécution".

---

## **4. Déploiement du Serveur Zabbix**

### **4.1 Installation de Docker**

Le serveur Zabbix a été déployé sur l'instance Ubuntu en utilisant Docker Compose pour orchestrer trois conteneurs : Zabbix Server, Web Interface et base de données MySQL.

```bash
# Mise à jour du système
sudo apt update && sudo apt upgrade -y

# Installation de Docker et Docker Compose
sudo apt install docker.io docker-compose -y

# Ajout de l'utilisateur au groupe docker
sudo usermod -aG docker ubuntu

# Démarrage du service Docker
sudo systemctl enable docker
sudo systemctl start docker
```

### **4.2 Configuration Docker Compose**

Fichier `docker-compose.yml` créé dans le répertoire `/home/ubuntu/zabbix-docker/` :

```yaml
version: '3.5'
services:
  zabbix-server:
    image: zabbix/zabbix-server-mysql:ubuntu-5.0-latest
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
      - /etc/localtime:/etc/localtime:ro

  zabbix-web:
    image: zabbix/zabbix-web-nginx-mysql:ubuntu-5.0-latest
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
      PHP_TZ: "Africa/Casablanca"
    volumes:
      - /etc/localtime:/etc/localtime:ro

  zabbix-mysql:
    image: mysql:8.0
    container_name: zabbix-mysql
    restart: unless-stopped
    environment:
      MYSQL_DATABASE: zabbix
      MYSQL_USER: zabbix
      MYSQL_PASSWORD: zabbixpassword
      MYSQL_ROOT_PASSWORD: rootpassword
    volumes:
      - mysql_data:/var/lib/mysql
      - /etc/localtime:/etc/localtime:ro

volumes:
  mysql_data:
```

### **4.3 Démarrage et Validation**

```bash
# Lancement des conteneurs en arrière-plan
docker-compose up -d

# Vérification des conteneurs actifs
docker-compose ps

# Suivi des logs
docker-compose logs -f
```

**Accès à l'interface :** `http://54.90.108.60/zabbix`  
**Identifiants par défaut :** `Admin` / `zabbix`

![Zabbix Dashboard](captures/capture%20(5).png)

**Figure 5 : Tableau de bord Zabbix opérationnel** - Vue du dashboard Zabbix confirmant que le serveur est en cours d'exécution sur le port 10051, avec 1 hôte actif et 218 templates disponibles.

### **4.4 Problèmes Rencontrés et Solutions**

#### **Problème 1 : Erreur de connexion à la base de données**
**Message :** `[Z3001] connection to database 'zabbix' failed: [2002] Can't connect to MySQL server`

**Solution :** Ajout d'un healthcheck dans `docker-compose.yml` pour MySQL et délai de démarrage de 30 secondes avant le lancement de Zabbix Server.

```yaml
services:
  zabbix-mysql:
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      timeout: 20s
      retries: 10
```

#### **Problème 2 : Conteneurs en redémarrage continu**
**Cause :** Incompatibilité entre Zabbix 5.0 et MySQL 8.0

**Solution :** Utilisation de la variable d'environnement `MYSQL_ALLOW_EMPTY_PASSWORD=yes` et création manuelle de la base de données avec le script d'initialisation.

#### **Problème 3 : Timezone incorrecte**
**Solution :** Configuration de `PHP_TZ` sur "Africa/Casablanca" pour correspondre au fuseau horaire local et montage du volume `/etc/localtime` pour synchronisation.

---

## **5. Configuration des Clients (Agents)**

### **5.1 Agent Zabbix sur Linux (Ubuntu)**

#### **Installation et Configuration**

```bash
# Ajout du dépôt Zabbix
wget https://repo.zabbix.com/zabbix/5.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.0-1+ubuntu22.04_all.deb
sudo dpkg -i zabbix-release_5.0-1+ubuntu22.04_all.deb
sudo apt update

# Installation de l'agent
sudo apt install zabbix-agent2 -y
```

#### **Configuration du fichier agent**

Modification du fichier `/etc/zabbix/zabbix_agent2.conf` :

```ini
Server=10.0.1.249
ServerActive=10.0.1.249
Hostname=Louki-Client-Linux
ListenPort=10050
```

#### **Démarrage du service**

```bash
sudo systemctl restart zabbix-agent2
sudo systemctl enable zabbix-agent2
sudo systemctl status zabbix-agent2
```

### **5.2 Agent Zabbix sur Windows (Windows Server 2022)**

#### **Installation**
1. Téléchargement de l'agent MSI depuis [zabbix.com](https://www.zabbix.com/download-agents)
2. Exécution de l'installateur avec les paramètres :
   - **Zabbix Server IP :** `10.0.1.249`
   - **Hostname :** `Louki-Client-Windows`
   - **Agent Listen Port :** `10050`

#### **Configuration**

Fichier `C:\Program Files\Zabbix Agent 2\zabbix_agent2.conf` :
```ini
Server=10.0.1.249
ServerActive=10.0.1.249
Hostname=Louki-Client-Windows
ListenPort=10050
```

#### **Vérification du service**
```powershell
Get-Service "Zabbix Agent 2"
# OU
sc query "Zabbix Agent 2"
```

### **5.3 Défis de Configuration Réseau**

Les restrictions du AWS Learner Lab ont rendu la communication entre agents difficile. Les tests de connectivité TCP ont été effectués manuellement :

```bash
# Depuis le serveur Zabbix
telnet 10.0.1.103 10050
telnet 10.0.1.248 10050

# Vérification des logs
tail -f /var/log/zabbix/zabbix_agent2.log
```

**Solution finale :** Ouverture du port 10050 sur SG-Zabbix-Agents depuis SG-Zabbix-Server uniquement, et configuration correcte de l'adresse IP du serveur dans les fichiers agents.

![Hosts Configuration](captures/capture%20(8).png)

**Figure 6 : Configuration des hôtes et templates dans Zabbix** - Vue détaillée des hôtes configurés avec leurs templates respectifs (OS Linux et OS Windows).

---

## **6. Monitoring et Tableaux de Bord**

### **6.1 Configuration des Hôtes dans Zabbix**

#### **Ajout des hôtes via l'interface web :**

1. Connectez-vous à l'interface Zabbix
2. Navigation : **Configuration → Hosts → Create host**

**Client Linux :**
- **Host name:** `Louki-Client-Linux`
- **Groups:** `Linux servers`
- **IP address:** `10.0.1.103`
- **Port:** `10050`
- **Template:** `Template OS Linux by Zabbix agent`

**Client Windows :**
- **Host name:** `Louki-Client-Windows`
- **Groups:** `Windows servers` (créé manuellement)
- **IP address:** `10.0.1.248`
- **Port:** `10050`
- **Template:** `Template OS Windows by Zabbix agent`

**Serveur Zabbix :**
- **Host name:** `Zabbix server`
- **IP address:** `10.0.1.249`
- **Port:** `10050`
- **Template:** `Template App Zabbix Server`

![Hosts List](captures/capture%20(7).png)

**Figure 7 : Liste des hôtes configurés** - Les trois hôtes (Linux, Windows et Zabbix Server) sont visibles avec statut "Enabled" et interface d'agent correctement configurée.

### **6.2 Création de Templates Personnalisés**

#### **Template Windows**
Le template Windows standard a dû être créé manuellement car non inclus par défaut dans Zabbix 5.0.

**Items clés ajoutés :**
- **CPU Utilization :** `system.cpu.util[,avg]` (Intervalle: 60s)
- **Memory Available :** `vm.memory.size[available]` (Intervalle: 60s)
- **Disk C: Free Space :** `vfs.fs.size[C:,free]` (Intervalle: 300s)
- **Network Traffic :** `net.if.in[eth0]` et `net.if.out[eth0]`

**Triggers configurés :**
- **High CPU :** `{Louki-Client-Windows:system.cpu.util[,avg].avg(5m)}>90`
- **Low Memory :** `{Louki-Client-Windows:vm.memory.size[available].last()}<500M`
- **Disk Space Warning :** `{Louki-Client-Windows:vfs.fs.size[C:,pused].last()}>85`

### **6.3 Visualisation des Données**

#### **Graphiques CPU Linux**

![CPU Graphs Linux](captures/capture%20(9).png)

**Figure 8 : Graphiques CPU pour Louki-Client-Linux** - Visualisation détaillée de l'utilisation CPU (utilisateur, système, iowait, steal time) avec des valeurs moyennes, minimales et maximales.

#### **Graphiques Réseau Windows**

![Network Graphs Windows](captures/capture%20(10).png)

**Figure 9 : Graphiques réseau pour Louki-Client-Windows** - Monitoring du trafic réseau (Ethernet), erreurs et paquets reçus/émis sur l'interface Amazon Elastic Network Adapter.

### **6.4 Tableau de Bord Principal**

Le dashboard a été configuré avec les widgets suivants :
- **System Information :** Statut du serveur Zabbix
- **Host Status :** État des hôtes (Enabled/Disabled)
- **Problems :** Liste des problèmes actifs
- **Latest Data :** Données en temps réel des métriques clés
- **Custom Graphs :** CPU, Mémoire, Trafic réseau

### **6.5 Tests d'Alerte et de Connectivité**

#### **Test de ping manuel**
Un test de connectivité ICMP a été configuré pour vérifier la disponibilité des hôtes :

```bash
# Configuration de l'item de ping
Item name: Ping to Linux Client
Key: icmpping[10.0.1.103]
Type: Simple check
Interval: 30s
```

**Résultats du test :**
```
PING 10.0.1.103 (10.0.1.103) 56(84) bytes of data.
64 bytes from 10.0.1.103: icmp_seq=1 ttl=63 time=0.345 ms
64 bytes from 10.0.1.103: icmp_seq=2 ttl=63 time=0.334 ms
64 bytes from 10.0.1.103: icmp_seq=3 ttl=63 time=0.357 ms

--- 10.0.1.103 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2070ms
rtt min/avg/max/mdev = 0.334/0.345/0.357/0.009 ms
```

![Ping Test Results](captures/capture%20(12).png)

**Figure 10 : Test de connectivité ICMP réussi** - Résultat d'un test ping manuel depuis Zabbix vers 10.0.1.103 montrant 0% de perte de paquets et un RTT moyen de 0.345ms.

#### **Configuration de l'alerte**

Un item de type "simple check" a été créé :
- **Key :** `icmpping[10.0.1.103]`
- **Interval :** 30 secondes
- **Trigger :** Si `last()=0` pendant 2 vérifications consécutives
- **Severity :** Warning

Le test a confirmé que toute défaillance de connectivité déclencherait une alerte visible dans le dashboard.

---

## **7. Conclusion**

### **7.1 Bilan des Acquis et Compétences Développées**

Ce projet m'a permis d'acquérir des compétences pratiques et théoriques essentielles :

1. **Architecture Cloud AWS :**
   - Maîtrise de la création et configuration de VPC, subnets et route tables
   - Gestion fine des Security Groups pour une sécurité optimale
   - Déploiement et gestion d'instances EC2 dans un environnement contraint

2. **Technologies de Conteneurisation :**
   - Création de stacks Docker Compose multi-services
   - Résolution de dépendances entre conteneurs (health checks)
   - Gestion des volumes persistants pour les données de monitoring

3. **Supervision avec Zabbix :**
   - Configuration d'un serveur Zabbix en conteneurisé
   - Déploiement et configuration d'agents sur différents OS
   - Création de templates personnalisés et d'items de monitoring
   - Configuration de triggers et d'actions d'alerte

4. **Résolution de Problèmes :**
   - Diagnostic de problèmes de connectivité réseau dans AWS
   - Analyse de logs et debug d'applications conteneurisées
   - Adaptation d'architecture aux contraintes d'un environnement lab

### **7.2 Difficultés Majeures et Solutions**

| **Problème** | **Cause Racine** | **Solution Implémentée** |
|--------------|------------------|--------------------------|
| Connectivité agent-serveur impossible | Security Groups mal configurés (ports fermés) | Création de règles inbound spécifiques avec source = SG du serveur |
| Conteneurs MySQL en redémarrage | Version incompatible MySQL 8.0 avec Zabbix 5.0 | Utilisation de MySQL 5.7 avec variables d'env adaptées |
| Templates Windows manquants | Distribution Zabbix 5.0 légère | Création manuelle de template avec items clés |
| Instances s'arrêtent automatiquement | Limitation AWS Learner Lab | Script de redémarrage automatique des conteneurs via `@reboot` cron |

### **7.3 Perspectives d'Amélioration et Évolutions Futures**

#### **Pour un environnement de production :**

**Haute Disponibilité :**
- Cluster MySQL avec réplication master-slave
- Load balancer NGINX pour le frontend Zabbix
- Zabbix Proxy pour distribuer la charge de monitoring

**Automatisation :**
- Infrastructure as Code avec Terraform/AWS CloudFormation
- CI/CD pour le déploiement des configurations Zabbix
- Ansible pour la configuration automatique des agents

**Sécurité Renforcée :**
- VPN Site-to-Site ou Client VPN AWS
- Certificats SSL/TLS pour les communications
- AWS Secrets Manager pour les mots de passe
- Multi-AZ pour la résilience géographique

**Intégration AWS :**
- CloudWatch pour les métriques complémentaires
- SNS pour les notifications d'alerte
- Lambda pour des actions d'automatisation
- S3 pour l'archivage des données de monitoring

### **7.4 Validation des Objectifs Initiaux**

- ✅ Infrastructure AWS déployée avec VPC, instances et sécurité
- ✅ Serveur Zabbix conteneurisé et fonctionnel
- ✅ Agents configurés et communicants sur Linux et Windows
- ✅ Tableaux de bord de monitoring opérationnels
- ✅ Système d'alerte testé et validé
- ✅ Documentation complète avec captures d'écran
- ✅ Dépôt GitHub créé et accessible

**Le projet a été livré avec succès et répond pleinement aux exigences du cahier des charges.**

---

## **8. Annexes**

### **8.1 Dépôt GitHub et Documentation**

**Lien du dépôt :** [https://github.com/benlouki235/aws-zabbix-monitoring](https://github.com/benlouki235/aws-zabbix-monitoring)

**Structure du dépôt :**
```
aws-zabbix-monitoring/
├── README.md                    # Documentation complète du projet
├── docker-compose.yml           # Configuration Docker
├── scripts/
│   ├── setup_zabbix_server.sh   # Script de setup serveur
│   ├── setup_agent_linux.sh     # Script installation agent Linux
│   └── setup_agent_windows.ps1  # Script installation agent Windows
├── docs/
│   ├── architecture-diagram.png # Schéma d'architecture
│   └── cahier_des_charges.pdf   # Cahier des charges original
├── captures/                    # Toutes les captures d'écran
└── LICENSE
```

### **8.2 Commandes de Gestion Utiles**

#### **AWS CLI**
```bash
# Vérifier le statut des instances
aws ec2 describe-instances --filters "Name=tag:Name,Values=*Zabbix*" \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress]' \
  --output table

# Obtenir les détails du VPC
aws ec2 describe-vpcs --vpc-ids vpc-08923a350697fbcea

# Lister les règles de Security Groups
aws ec2 describe-security-groups --group-ids sg-0de64d0ab54c7ce56
```

#### **Docker et Zabbix**
```bash
# Gestion des conteneurs Zabbix
docker-compose up -d      # Démarrer
docker-compose down       # Arrêter
docker-compose logs -f    # Voir les logs en temps réel

# Exécuter une commande dans un conteneur
docker exec -it zabbix-server bash

# Tester une métrique avec zabbix_get
zabbix_get -s 10.0.1.103 -p 10050 -k "system.cpu.util[,user]"

# Sauvegarde de la base de données
docker exec zabbix-mysql mysqldump -u zabbix -pzabbixpassword zabbix > backup.sql
```

### **8.3 Résumé de Configuration Réseau**

| **Ressource** | **ID/Nom** | **CIDR/Ports** | **Description** |
|---------------|------------|----------------|-----------------|
| VPC | vpc-08923a350697fbcea | 10.0.0.0/16 | Zabbix-VPC |
| Subnet | subnet-0fb9f46a18b9d1982 | 10.0.1.0/24 | Public-Subnet |
| Security Group Serveur | sg-0de64d0ab54c7ce56 | 80,22,443,10051 | SG-Zabbix-Server |
| Security Group Agents | - | 10050,22,3389 | SG-Zabbix-Agents |
| Serveur Zabbix | i-0e7993c7369648ab5 | 10.0.1.249:10051 | Louki-Zabbix-Server |
| Client Linux | i-05c2a6ca8008f0fa8 | 10.0.1.103:10050 | Louki-Client-Linux |
| Client Windows | i-04675eee3adc8a2e4 | 10.0.1.248:10050 | Louki-Client-Windows |

### **8.4 Budget et Coûts AWS**

| **Service** | **Quantité** | **Coût mensuel** | **Coût projet (7 jours)** |
|-------------|--------------|------------------|---------------------------|
| EC2 t3.micro (3 instances) | 3 x 730h | 0 USD (Lab) | 0 USD |
| VPC | 1 | 0 USD | 0 USD |
| Data Transfer | ~2 GB | 0 USD (Lab) | 0 USD |
| **TOTAL** | | **0 USD** | **0 USD** |

**Remarque :** Les coûts sont nuls grâce au AWS Learner Lab. En production, l'estimation serait d'environ **45 USD/mois** pour cette architecture basique.

### **8.5 Scripts de Sauvegarde Automatisée**

#### **Sauvegarde de la configuration Zabbix**
```bash
#!/bin/bash
# backup_zabbix.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/home/ubuntu/backups"

# Créer le répertoire si inexistant
mkdir -p $BACKUP_DIR

# Dump de la base de données
docker exec zabbix-mysql mysqldump -u zabbix -pzabbixpassword zabbix > \
  $BACKUP_DIR/zabbix_db_$DATE.sql

# Backup des configurations
tar -czf $BACKUP_DIR/zabbix_config_$DATE.tar.gz /home/ubuntu/zabbix-docker

# Suppression des anciens backups (+7 jours)
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete

echo "Backup completed: $BACKUP_DIR/zabbix_db_$DATE.sql"
```

#### **Redémarrage automatique des conteneurs**
```bash
# Ajouter à crontab avec crontab -e
@reboot sleep 60 && cd /home/ubuntu/zabbix-docker && docker-compose up -d
```

### **8.6 Liens et Ressources Utiles**

- **Documentation Zabbix :** [https://www.zabbix.com/documentation/5.0/](https://www.zabbix.com/documentation/5.0/)
- **Docker Hub Zabbix :** [https://hub.docker.com/u/zabbix/](https://hub.docker.com/u/zabbix/)
- **AWS Documentation VPC :** [https://docs.aws.amazon.com/vpc/](https://docs.aws.amazon.com/vpc/)
- **AWS Educate :** [https://aws.amazon.com/education/awseducate/](https://aws.amazon.com/education/awseducate/)

---

## **Remerciements**

Je souhaite exprimer mes sincères remerciements à :

- **Prof. Azeddine KHIAT**, mon encadrant de projet, pour son expertise, sa disponibilité et ses conseils avisés qui ont guidé ce travail du début à la fin.

- **L'équipe pédagogique de l'Université Mundiapolis**, pour la qualité de la formation et l'accompagnement tout au long du cursus ingénieur.

- **AWS Educate**, pour fournir l'accès au AWS Learner Lab, essentiel à la réalisation pratique de ce projet.

- **La communauté open-source Zabbix**, pour la documentation complète et le support de la version utilisée.

- **Mes camarades de promotion**, pour les échanges enrichissants et le soutien mutuel.

Ce projet a été une expérience formatrice qui a consolidé mes compétences en architecture cloud, DevOps et supervision d'infrastructures. Il constitue une base solide pour mes futurs projets professionnels.

---

**Rédigé par :** Abdel-hamid Mahamat LOUKI  
**Contact :** benlouki235@gmail.com  
