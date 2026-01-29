terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.18.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}