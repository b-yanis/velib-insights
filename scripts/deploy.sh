#!/usr/bin/env bash
set -e

echo "▶ Mot de passe sudo requis"
read -s -p "Mot de passe sudo: " SUDO_PWD
echo

# Initialise le ticket sudo
echo "$SUDO_PWD" | sudo -S -v

# Vérifier si Ansible est installé, sinon l'installer
if ! command -v ansible &> /dev/null; then
    echo "Ansible n'est pas installé. Installation en cours..."
    sudo apt update
    sudo apt install -y ansible
fi

echo "Ansible est prêt."


echo "▶ Running Ansible..."
cd ../infra/ansible
ansible-playbook -i inventory.ini playbook.yaml --extra-vars "ansible_sudo_pass=$SUDO_PWD"

#clean sudo password
unset SUDO_PWD

echo "▶ Running Terraform..."
cd ../terraform/k8s
terraform init
terraform apply -auto-approve
cd ..

echo "▶ Resolving application URL..."

NODE_IP=$(ip route get 1 | awk '{print $7}')
NODE_PORT=$(kubectl get svc ingress-nginx-controller \
  -n ingress-nginx \
  -o jsonpath='{.spec.ports[?(@.port==80)].nodePort}')

APP_URL="http://${NODE_IP}:${NODE_PORT}"

echo "✅ Application is available at:"
echo "   $APP_URL"

# Ouvrir le navigateur seulement si interactif
if [ -t 1 ]; then
  if grep -qi microsoft /proc/version; then
    powershell.exe -NoProfile -NonInteractive Start-Process "$APP_URL"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    open "$APP_URL"
  else
    xdg-open "$APP_URL"
  fi
fi
