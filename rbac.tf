resource "kubernetes_role" "read_only" {
  metadata {
    name        = local.eks_read_only_role
    namespace   = var.kubernetes_namespace
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["get", "list", "watch"]
  }

  depends_on = [kubernetes_namespace.atlantis]
}

resource "kubernetes_role_binding" "read_only_binding" {
  metadata {
    name        = "${local.eks_read_only_role}-binding"
    namespace   = var.kubernetes_namespace
  }

  subject {
    kind      = "User"
    name      = local.eks_read_only_user
    api_group = "rbac.authorization.k8s.io"
  }

  role_ref {
    kind      = "Role"
    name      = kubernetes_role.read_only.metadata.0.name
    api_group = "rbac.authorization.k8s.io"
  }

  depends_on = [kubernetes_namespace.atlantis]
}
