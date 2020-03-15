# K8s

## Run Atlantis

In this exercise we will install Atlantis on a AWS EKS cluster. Demo PRs available at https://github.com/avoidik/demo_atlantis/

## Prerequisites

Software

- [Terraform](https://www.terraform.io/)
- [Helm](https://github.com/helm/helm/releases)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [aws-iam-authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)
- [awscli](https://aws.amazon.com/cli/)

Additionally

- Access to an AWS account
- Privileged AWS IAM user to create new resources & configured AWS named profile (`personal` by default)
- Prepared configuration

## Prepare configuration

1. Change `terraform.tfvars` according to your needs (e.g. definitely worth to check AWS named profile)

1. Copy `values/atlantis.yaml.sample` into `values/atlantis.yaml` and set required variables

    - `github.user` - github user which will be monitoring your repository
    - `github.token` - github user developer's token
    - `github.secret` - random string to link webhook client and server
    - `orgWhitelist` - github organization or user space to monitor

    ```python
    import random
    import string
    secret = ''.join(random.choice(string.ascii_uppercase + string.ascii_lowercase + string.digits) for _ in range(32))
    print(secret)
    ```

## Deployment

The deployment process consist of two stages:

1. Provision an EKS cluster
1. Provision an Helm chart

Having configuration prepared execute `terraform.sh` to provision an EKS cluster, followed by `helm.sh` to provision an Atlantis.

```bash
./terraform.sh -a
./helm.sh
```

## Post-deployment

Configure Atlantis Webhook and Github Repostiory integration, please refer to official documentation at https://www.runatlantis.io/docs/configuring-webhooks.html

Use `webhook.sh` script to view Webhook URL

## Check RBAC permissions

To view permissions available to a default user, first export configuration

```bash
$ export KUBECONFIG="atlantis.yaml"
```

View available permissions

```bash
$ kubectl auth can-i --list -n atlantis
```

In basic scenario you may test RBAC capabilities without assuming AWS IAM roles

With `eks-admin` user

```bash
$ kubectl auth can-i list pods -n atlantis --as eks-admin --as-group system:masters
yes
$ kubectl auth can-i list pods -n atlantis --as eks-read-only
yes
```

With `eks-read-only` user

```bash
$ kubectl auth can-i create pods -n atlantis --as eks-admin --as-group system:masters
yes
$ kubectl auth can-i create pods -n atlantis --as eks-read-only
no
```

To test RBAC with AWS IAM roles changes to your `~/.aws/config` file to look like this (don't forget to change the account number)

```
[profile personal]
region = eu-west-1
output = json

[profile eks-admin]
region = eu-west-1
role_arn = arn:aws:iam::123456789012:role/eks-admin
source_profile = personal

[profile eks-viewer]
region = eu-west-1
role_arn = arn:aws:iam::123456789012:role/eks-read-only
source_profile = personal
```

Then set AWS named profile `AWS_PROFILE` in `atlantis.yaml` file to one of the roles from above (either `eks-admin` or `eks-viewer`), and check permissions with

With `AWS_PROFILE` set to `eks-admin`

```bash
$ kubectl auth can-i list pods -n atlantis
yes
$ kubectl auth can-i create pods -n atlantis
yes
```

With `AWS_PROFILE` set to `eks-viewer`

```bash
$ kubectl auth can-i list pods -n atlantis
yes
$ kubectl auth can-i create pods -n atlantis
no
```

All authentication attempts will be logged into a respective control-plane CloudWatch log group with `authenticator` prefix, for example

```
time="2020-03-15T12:13:55Z" level=info msg="access granted" arn="arn:aws:iam::123456789012:role/eks-admin" client="127.0.0.1:42414" groups="[system:masters]" method=POST path=/authenticate uid="heptio-authenticator-aws:123456789012:AROAREDHM2QBPS24RCTU5" username=eks-admin
time="2020-03-15T12:14:06Z" level=info msg="access granted" arn="arn:aws:iam::123456789012:role/eks-read-only" client="127.0.0.1:42414" groups="[viewer-role]" method=POST path=/authenticate uid="heptio-authenticator-aws:123456789012:AROAREDHM2QBKABYQOWNQ" username=eks-read-only
```

## Tear-down

To clean everything up run scripts in reverse order

```bash
./helm.sh -d
./terraform.sh -d -a
```

Also do not forget to remove configuration from `~/.aws/config` file

## References

https://github.com/terraform-aws-modules/terraform-aws-eks

## Copyright

You may use my work or its parts as you wish, but only with the proper credits to me like this:

Viacheslav - avoidik@gmail.com