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
```
Infrastructure AWS:
  ├── VPC: Zabbix-VPC (10.0.0.0/16)
  ├── 3 instances EC2:
  │   ├── Louki-Zabbix-Server (t3.large Ubuntu)
  │   ├── Louki-Client-Linux (t3.medium Ubuntu)
  │   └── Louki-Client-Windows (t3.large Windows)
  └── Groupes de sécurité configurés

Stack Technologique:
  ├── Monitoring: Zabbix 6.0
  ├── Conteneurisation: Docker + Docker Compose
  ├── Base de données: MySQL 8.0
  └── Web: Nginx + PHP
```

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
