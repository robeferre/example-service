variable "access_key" {
  type        = string
  description = "AWS access key loaded from env variable"
}

variable "secret_key" {
  type        = string
  description = "AWS secret key loaded from env variable"
}

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region for deployment"
}

variable "cluster-name" {
  type    = string
  default = "k8s"
}
