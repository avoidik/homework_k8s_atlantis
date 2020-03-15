terraform {
  required_version = ">= 0.12.0"

  required_providers {
    aws        = "~> 2.50"
    random     = "~> 2.2"
    local      = "~> 1.4"
    null       = "~> 2.1"
    template   = "~> 2.1"
    kubernetes = "~> 1.11"
    http       = "~> 1.1"
  }
}

provider "aws" {
  region  = var.region
  profile = var.profile
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}
