provider "google" {
  region = "europe-central2"
}

provider "kubernetes" {
  alias = "prod"
}

provider "kubernetes" {
  alias = "staging"
}

module "google_prod" {
  source = "./submodules/google-prod"
}

module "kubernetes_prod" {
  source    = "./submodules/kubernetes-prod"
  providers = { kubernetes = kubernetes.prod }
}