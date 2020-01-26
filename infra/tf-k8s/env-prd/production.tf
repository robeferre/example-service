# --------------------------------------------------------------------------
# Terraform provisioning script Test
#
# Author: Roberto Ferreira Junior
# Email: robeferre@gmail.com
# --------------------------------------------------------------------------

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

# --------------------------------------------------------------------------
# My remote state file is stored in a S3 bucket to avoid local state files.
# Also, i'm using one state file per environment for security propose
# --------------------------------------------------------------------------
terraform {
  backend "s3" {
    bucket  = "tf-eks-state-dubai"
    key     = "eks-prd.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

module "eks-cluster" {
  source  = "lablabs/eks-cluster/aws//examples/complete"
  version = "0.13.0"
  # insert the 6 required variables here
  associate_public_ip_address            = true
  autoscaling_policies_enabled           = true
  availability_zones                     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  cpu_utilization_high_threshold_percent = 80
  cpu_utilization_low_threshold_percent  = 20
  health_check_type                      = "ELB"
  instance_type                          = "t2.medium"
  kubeconfig_path                        = "~/.kube/config"
  max_size                               = 2
  min_size                               = 1
  name                                   = "${var.cluster-name}"
  namespace                              = "emirates"
  region                                 = "${var.region}"
  stage                                  = "${var.env}"
  wait_for_capacity_timeout              = "30m"
  kubectl_version                        = "1.14"
  kubernetes_version                     = "1.14"
}
