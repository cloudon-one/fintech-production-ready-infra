terraform {
  backend "gcs" {
    bucket = "fintech-prod-tfstate"
    prefix = "net-iam"
  }
} 