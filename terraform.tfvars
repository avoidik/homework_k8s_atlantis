region = "eu-west-1"
profile = "personal"
vpc_cidr = "10.0.0.0/16"
vpc_name = "test-vpc"
kubernetes_version = "1.15"
kubernetes_cluster_name = "test-eks"
kubernetes_tags = {
    Environment = "test"
    Workload    = "test"
}
worker_flavor = "t2.small"
kubernetes_namespace = "atlantis"
kubernetes_config = "atlantis.yaml"