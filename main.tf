terraform {
  backend "s3" {
    bucket  = "terraform-state-bucket"
    key     = "state"
    region  = "eu-north-1"
    profile = "sentinel"
  }
}


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.2"
    }
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

locals {
  cluster_name    = "midas-cluster"
  cluster_version = "1.26"
  region          = "eu-north-1"
}

provider "aws" {
  region  = local.region
  profile = var.profile
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

data "aws_availability_zones" "available" {}

# data "aws_subnet_ids" "subnets" {
#   #name = module.eks.cluster_id
#   vpc_id = module.vpc.vpc_id
# }