terraform {
  required_version = ">= 1.5"
  required_providers {
    google = { source = "hashicorp/google", version = "~> 5.0" }
    random = { source = "hashicorp/random", version = "~> 3.5" }
  }
  backend "gcs" {
    bucket = "sinapsek-fin-tfstate"
    prefix = "prod"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "networking" {
  source      = "./modules/networking"
  environment = var.environment
}

module "iam" {
  source      = "./modules/iam"
  project_id  = var.project_id
  region      = var.region
  environment = var.environment
}

module "cloud_sql" {
  source        = "./modules/cloud_sql"
  project_id    = var.project_id
  region        = var.region
  environment   = var.environment
  vpc_id        = module.networking.vpc_id
  db_depends_on = module.networking.private_network_connection_id
}

module "storage" {
  source       = "./modules/storage"
  project_id   = var.project_id
  region       = var.region
  environment  = var.environment
  api_sa_email = module.iam.api_sa_email
}

module "cloud_run" {
  source        = "./modules/cloud_run"
  project_id    = var.project_id
  region        = var.region
  environment   = var.environment
  api_image_url = var.api_image_url
  db_connection = module.cloud_sql.connection_name
  db_password   = module.cloud_sql.db_password
  api_sa_email  = module.iam.api_sa_email
  custom_domain = var.environment == "prod" ? "api.sinapsek-fin.migueldev11.com" : "api.demo.sinapsek-fin.migueldev11.com"
}
# Trigger deployment
