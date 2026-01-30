# 🚲 Velib Insights – Local Kubernetes Deployment

Ce projet permet de déployer l’application **Velib Insights** localement sur une machine Linux / WSL2 à l’aide de **k3s**, **Ansible** et **Terraform**, avec un **NGINX Ingress Controller** pour l’exposition HTTP.

L’objectif est qu’un utilisateur puisse lancer **un seul script (`deploy.sh`)** et obtenir :
- un cluster Kubernetes local fonctionnel,
- les workloads déployés,
- une URL directement ouvrable dans le navigateur.

---

## 📁 Structure du projet

```text

.
├── client/                     # Frontend application (React / UI)             
├── server/                     # Backend application (API)
├── infra/                      # Infrastructure & deployment
│   ├── ansible/
│   │   ├── inventory.ini
│   │   ├── playbook.yaml
│   │   └── roles/
│   │       ├── common/          # Base system setup (packages, tools)
│   │       ├── k3s/             # K3s installation & configuration
│   │       ├── ingress-nginx/   # NGINX Ingress Controller installation
│   │       └── terraform/       # Terraform installation
│   │
│   ├── terraform/
│   │   └── k8s/                # Kubernetes resources managed by Terraform
│   │       ├── provider.tf
│   │       ├── namespace.tf
│   │       ├── backend.tf
│   │       ├── frontend.tf
│   │       └── ingress.tf
│   │
│   ├── local-dev-k8s/           # Kubernetes manifests for local development
│   │   ├── backend.yaml
│   │   ├── frontend.yaml
│   │   ├── service.yaml
│   │   └── ingress.yaml
│   │
│   ├── skaffold.yaml            # Skaffold config for local dev
├── scripts/                  
│     └── deploy.sh              # deploy application on local
└── README.md    
```

---

## 🧰 Prérequis

### Système
- Linux **ou** WSL2 (Ubuntu recommandé)
- Accès `sudo`
- Accès internet

### Logiciels
- `bash`
- `sudo`
- `curl`

> ⚠️ **Ansible, kubectl, k3s et Terraform sont installés automatiquement** par le script.

---

## 🚀 Lancer l’application

À la racine du projet :

```bash
cd scripts
chmod +x deploy.sh
./deploy.sh
```

Le script va :
1. Demander le mot de passe `sudo`
2. Initialiser un ticket sudo
3. Installer Ansible (si nécessaire)
4. Déployer l’infrastructure avec **Ansible**
5. Déployer l’application avec **Terraform**
6. Résoudre dynamiquement l’URL
7. Ouvrir automatiquement le navigateur

---

## 🌐 Accès à l’application

L’application est exposée via **NGINX Ingress Controller** en **NodePort**.

L’URL finale est construite dynamiquement :

```
http://<IP_WSL>:<NODE_PORT>
```

Exemple :
```
http://172.21.87.251:32759
```

ℹ️ Ce n’est **pas `localhost:80`**, car :
- Kubernetes tourne dans un réseau virtualisé (WSL / VM)
- Le service Ingress est exposé via un **NodePort**
- L’IP utilisée est celle de l’interface réseau (`eth0`)

---

## 🧠 Choix techniques (Local vs Production)

### 🧪 Choix faits pour le **déploiement local**

- **k3s**
  - Léger
  - Installation simple
  - Parfait pour du local / WSL / VM unique

- **Ingress NGINX en NodePort**
  - Fonctionne sans LoadBalancer
  - Compatible bare-metal / WSL
  - Accès direct via IP + port

- **Terraform pour les workloads**
  - Versionnement clair
  - Idempotence
  - Séparation infra / applicatif

- **Ansible avec `become`**
  - Installation système (k3s, paquets)
  - Automatisation complète from scratch

- **Mot de passe sudo via variable**
  - Pas de fichier sensible versionné
  - Pas de dépendance à Ansible Vault

---

### 🏭 Ce qui serait différent en **production**

| Local | Production |
|------|------------|
| k3s | Kubernetes managé (EKS, GKE, AKS) |
| NodePort | LoadBalancer / Ingress Cloud |
| IP locale | Nom de domaine + DNS |
| HTTP | HTTPS + certificats (cert-manager) |
| 1 nœud | Cluster multi-nœuds |
| Images `latest` | Images versionnées |
| Secrets en clair | Secrets Manager / Vault |
| Déploiement manuel | CI/CD (GitHub Actions, GitLab CI) |

---

## 🛠 Debug utile

```bash
kubectl get pods -n velib-insights
kubectl logs -n velib-insights <pod>
kubectl get ingress -n velib-insights
kubectl describe ingress velib-ingress -n velib-insights
kubectl logs -n ingress-nginx deploy/ingress-nginx-controller
```

---

## ✅ Résumé

- Un **script unique**
- Aucune installation manuelle
- Déploiement reproductible
- Conçu pour le **local**, mais avec une **logique proche de la prod**

---

🧠 *Ce projet met l’accent sur la compréhension réelle de Kubernetes, Ingress, réseau et automatisation, pas uniquement sur “faire marcher”.*

---

## ⚠️ Note importante sur l'utilisation de Terraform avec Kubernetes

Dans un contexte **réel (production)**, Terraform **n'est généralement pas utilisé pour déployer des workloads Kubernetes**
(pods, deployments, services, ingress).

En pratique :
- Terraform sert surtout à **provisionner l'infrastructure** (VM, réseaux, clusters Kubernetes, load balancers, etc.)
- Le déploiement applicatif est plutôt géré par :
  - **Helm**
  - **kubectl + manifests YAML**
  - **GitOps (ArgoCD, Flux)**

👉 **Dans ce projet, Terraform est volontairement utilisé pour déployer des ressources Kubernetes à but pédagogique** :
- apprendre la syntaxe Terraform
- comprendre le provider Kubernetes
- illustrer les différences entre *infra provisioning* et *app deployment*

Ce choix est donc **didactique**, et non une recommandation pour un environnement de production.

---



## 🚧 Mode développement local (Local Dev Kubernetes)

Pour le développement de l'application, un mode **local simplifié** est proposé, distinct du déploiement automatisé via Ansible/Terraform.

### 📁 Structure dédiée

Un dossier supplémentaire est présent dans le projet :

```
local-dev-k8s/
├── backend-deployment.yaml
├── backend-service.yaml
├── frontend-deployment.yaml
├── frontend-service.yaml
├── ingress.yaml
```

Ce dossier contient des manifestes Kubernetes **classiques (YAML)** destinés uniquement au développement local.

### 🧰 Prérequis pour le mode dev

- Docker Desktop
- Kubernetes activé dans Docker Desktop
- Skaffold

### ▶️ Démarrer l'application en local avec Skaffold

Le projet contient un fichier `skaffold.yaml` à la racine.  
Skaffold s'appuie sur les fichiers présents dans `local-dev-k8s/` pour :

- builder les images Docker
- les déployer automatiquement sur le cluster Kubernetes local
- recharger l'application en cas de modification du code

Une fois lancé, l'application sera accessible sur :

```
http://localhost:80
```

### 💡 Astuce : utilisation avec IntelliJ

Un moyen très simple d'utiliser Skaffold est d’installer le plugin **Google Cloud Code** dans IntelliJ.

- À l’ouverture du projet, le plugin détecte automatiquement le fichier `skaffold.yaml`
- Il propose de configurer et lancer Skaffold en un clic
- Le workflow de développement devient très fluide (build, deploy, logs intégrés)

### 🎯 Pourquoi ce mode ?

- Cycle de développement rapide
- Aucune dépendance à Ansible ou Terraform
- Approche standard et proche des pratiques réelles en développement Kubernetes

Ce mode est **recommandé pour développer et tester l'application**, tandis que le script `deploy.sh` est plutôt destiné à l'apprentissage et à la démonstration d'un déploiement automatisé complet.
