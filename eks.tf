data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

data "aws_iam_policy" "cloudwatch" {
  arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "10.0.0"

  cluster_name           = local.cluster_name
  cluster_version        = var.kubernetes_version
  cluster_create_timeout = "30m"
  cluster_delete_timeout = "30m"
  subnets                = module.vpc.private_subnets
  vpc_id                 = module.vpc.vpc_id
  tags                   = var.kubernetes_tags
  write_kubeconfig       = true
  config_output_path     = var.kubernetes_config
  kubeconfig_name        = "default"

  worker_groups = [
    {
      name                 = "worker-group-default"
      instance_type        = var.worker_flavor
      asg_max_size         = 2
      asg_min_size         = 1
      asg_desired_capacity = 1
    }
  ]

  map_roles = [
    {
      rolearn  = aws_iam_role.admin_role.arn
      username = local.eks_admin_user
      groups   = ["system:masters"]
    },
    {
      rolearn  = aws_iam_role.reader_role.arn
      username = local.eks_read_only_user
      groups   = [local.eks_read_only_role]
    },
  ]

  workers_additional_policies                = [data.aws_iam_policy.cloudwatch.arn]
  kubeconfig_aws_authenticator_env_variables = { AWS_PROFILE = var.profile }
  cluster_enabled_log_types                  = ["api", "authenticator", "controllerManager"]
  cluster_endpoint_private_access            = true
  cluster_endpoint_public_access             = true
  cluster_endpoint_public_access_cidrs       = ["${chomp(data.http.myip.body)}/32"]

  # windows workaround
  # wait_for_cluster_interpreter = ["c:/Tools/git/bin/sh.exe", "-c"]
  wait_for_cluster_cmd         = "until curl -sk $ENDPOINT >/dev/null; do sleep 10; done; sleep 5"
}

resource "kubernetes_namespace" "atlantis" {
  metadata {
    name = var.kubernetes_namespace
  }

  depends_on = [module.eks.cluster_id]
}
