provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
    load_config_file       = false
  }
}

data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "atlantis" {
  name       = "atlantis"
  chart      = "stable/atlantis"
  repository = data.helm_repository.stable.metadata.0.name
  version    = "3.11.1"
  namespace  = kubernetes_namespace.atlantis.id
  atomic     = true
  values     = [file("${path.root}/values/atlantis.yaml")]
  depends_on = [kubernetes_namespace.atlantis]
}
