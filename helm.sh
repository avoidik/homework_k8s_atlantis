#!/usr/bin/env bash

CONFIG_FILE="atlantis.yaml"
NAME_SPACE="atlantis"
HELM_CHART="stable/atlantis"
HELM_VER="3.11.1"
HELM_NAME="${NAME_SPACE}"

DEPS_LIST=("helm" "aws-iam-authenticator")
for item in "${DEPS_LIST[@]}"; do
  if ! command -v "$item" &> /dev/null ; then
    echo "Error: required command '$item' was not found" >&2
    exit 1
  fi
done

if [[ ! -f "${CONFIG_FILE}" ]]; then
  echo "Error: Kubernetes configuration file was not found" >&2
  exit 1
fi

export KUBECONFIG="${CONFIG_FILE}"

while [[ "$#" -gt 0 ]]; do
  case $1 in
    -d|--destroy) DESTROY_IT="Y";;
    *) echo "Unknown parameter passed: $1" >&2; exit 1;;
  esac
  shift
done

# destroy command line
if [[ "${DESTROY_IT}" == "Y" ]]; then
  helm status "${HELM_NAME}" -n "${NAME_SPACE}" &> /dev/null && {
    helm uninstall "${HELM_NAME}" -n "${NAME_SPACE}"
  }
  exit 0
fi

# add helm repo
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo update

# chart info
helm show chart "${HELM_CHART}" || { echo "Error: chart does not exist" >&2; exit 1; }

# install helm mysql chart
helm install \
  "${HELM_NAME}" \
  "${HELM_CHART}" \
  --values values/atlantis.yaml \
  --namespace "${NAME_SPACE}" \
  --version "${HELM_VER}" \
  --atomic || {
  exit 1
}

helm list -n "${NAME_SPACE}"
