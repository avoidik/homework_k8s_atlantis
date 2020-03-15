data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "admin_role_trust" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.arn]
    }
  }
}

resource "aws_iam_role" "admin_role" {
  name                  = local.eks_admin_user
  assume_role_policy    = data.aws_iam_policy_document.admin_role_trust.json
}

data "aws_iam_policy_document" "viewer_role_trust" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.arn]
    }
  }
}

resource "aws_iam_role" "reader_role" {
  name                  = local.eks_read_only_user
  assume_role_policy    = data.aws_iam_policy_document.viewer_role_trust.json
}
