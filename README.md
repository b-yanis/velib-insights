## diff avec la prod
- en production, nous aurions creer un dockerfile client avec un nginx en 2eme partie du dockerfile afin de servir les fichers, car par de npm start
- en local on a creer une clé ssh avec terraform, on utilise cette meme clé pour se connecter à la vm via terrafom et y deposer cette meme clé pour qu'on puisse l'utiliser par la suite pour se connecter à la vm via ansible
ceci se rapproche le plus d'un cas de prod ou on creer la clé avec terraform mais inutil de la deployer sur la vm à la main car les providers de vm tel que aws ou google permettent de le faire lors de declaration de la vm de maniere plus clean (c'est aussi le cas chez certains modules crée en interne chez les banques comme à la sg)

## prerequis
- Ansible installé

- le projet doit etre lancé sur le systeme de fichier wsl

## choix:
ks3 :k3s est une distribution Kubernetes légère et certifiée CNCF. Elle est particulièrement adaptée aux environnements locaux, de test ou edge computing. Dans ce cas d’usage, k3s permet de disposer d’un cluster Kubernetes fonctionnel avec une installation simple et des ressources limitées, tout en conservant une compatibilité totale avec Kubernetes standard.

Dans un objectif de se rapprocher d’un environnement de production, ce cas d’usage utilise ingress-nginx comme Ingress Controller. Les règles de réécriture permettent d’exposer l’API sous le chemin /api tout en conservant une application backend indépendante de toute logique de proxy ou de routage.

## workflox infra : 

Terraform (VM / infra)
│
▼
Ansible (k3s + nginx + config)
│
▼
Terraform (Deployments + Services + Ingress)