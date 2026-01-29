#!/usr/bin/env bash
set -e

echo "▶ Enter sudo pwd to execute Ansible..."
read -s -p "Mot de passe sudo: " SUDO_PWD
echo


echo "▶ Running Ansible..."
cd ../ansible
ansible-playbook -i inventory.ini playbook.yaml --extra-vars "ansible_sudo_pass=$SUDO_PWD"

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
