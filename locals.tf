locals {
  cluster_name       = "${var.kubernetes_cluster_name}-${random_string.suffix.result}"
  eks_read_only_user = "eks-read-only"
  eks_admin_user     = "eks-admin"
  eks_read_only_role = "viewer-role"
}
