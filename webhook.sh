#!/usr/bin/env bash

CONFIG_FILE="atlantis.yaml"
NAME_SPACE="atlantis"
HELM_NAME="${NAME_SPACE}"

DEPS_LIST=("kubectl" "aws-iam-authenticator")
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

if kubectl wait --for=condition=Ready pods -l app="${HELM_NAME}" -n "${NAME_SPACE}" --timeout=5m ; then
  echo "Webhook URL is:"
  kubectl get svc -n "${NAME_SPACE}" "${HELM_NAME}" -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
  echo
fi
