#!/bin/bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

MONITORING_NAMESPACE="monitoring"
GRAFANA_USERNAME="admin"
GRAFANA_PASSWORD="password"

if [[ $(kubectl get namespace "${MONITORING_NAMESPACE}") == "" ]]; then
    kubectl create namespace "${MONITORING_NAMESPACE}"
fi

# create secret or update secret grafana-admin
kubectl create secret generic grafana-admin \
    --namespace "${MONITORING_NAMESPACE}" \
    --from-literal="admin-user=${GRAFANA_USERNAME}" \
    --from-literal="admin-password=${GRAFANA_PASSWORD}" \
    --dry-run=client -o yaml | kubectl apply -f -

helm upgrade \
    --install monitoring prometheus-community/kube-prometheus-stack \
    --namespace "${MONITORING_NAMESPACE}" \
    --create-namespace \
    --atomic \
    --timeout 10m \
    --wait \
    --set grafana.adminUser="${GRAFANA_USERNAME}" \
    --set grafana.adminPassword="${GRAFANA_PASSWORD}" \
    --values values.yaml

# kubectl apply -f app-1 --recursive