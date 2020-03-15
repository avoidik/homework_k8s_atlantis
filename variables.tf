variable "region" {
  type = string
}

variable "profile" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "kubernetes_cluster_name" {
  type = string
}

variable "kubernetes_tags" {
  type = map(string)
}

variable "worker_flavor" {
  type = string
}

variable "kubernetes_namespace" {
  type = string
}

variable "kubernetes_config" {
  type = string
}
