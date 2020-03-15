#!/usr/bin/env bash

CONFIG_FILE="atlantis.yaml"

DEPS_LIST=("terraform" "kubectl" "aws-iam-authenticator")
for item in "${DEPS_LIST[@]}"; do
  if ! command -v "$item" &> /dev/null ; then
    echo "Error: required command '$item' was not found" >&2
    exit 1
  fi
done

AUTO_APPROVE="-refresh=true"

while [[ "$#" -gt 0 ]]; do
  case $1 in
    -g|--get) ONLY_GET="Y";;
    -i|--init) ONLY_INIT="Y";;
    -d|--destroy) DESTROY_IT="Y";;
    -a|--auto) AUTO_APPROVE="-auto-approve -refresh=true";;
    *) echo "Unknown parameter passed: $1" >&2; exit 1;;
  esac
  shift
done

# get command line
if [[ "${ONLY_GET}" == "Y" ]]; then
  terraform get -update .
  exit 0
fi

if ! terraform init -input=false . ; then
  echo "Error: Terraform init failed" >&2
  exit 1
fi

# init command line
if [[ "${ONLY_INIT}" == "Y" ]]; then
  exit 0
fi

# destroy command line
if [[ "${DESTROY_IT}" == "Y" ]]; then
  export TF_WARN_OUTPUT_ERRORS=1
  terraform destroy ${AUTO_APPROVE} .
  exit 0
fi

if ! terraform apply -input=false ${AUTO_APPROVE} . ; then
  echo "Error: Terraform apply failed" >&2
  exit 1
fi

if [[ ! -f "${CONFIG_FILE}" ]]; then
  echo "Error: Kubernetes configuration file was not found" >&2
  exit 1
fi

export KUBECONFIG="${CONFIG_FILE}"

if ! kubectl wait --for=condition=Ready nodes --all --timeout=5m ; then
  echo "Error: Kubernetes nodes were not provisioned in a timely manner" >&2
  exit 1
fi
