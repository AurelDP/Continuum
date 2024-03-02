#!/bin/bash

# Recover the name of the Prometheus pod
POD_NAME_PROM=$(kubectl get pods --namespace continuum-monitoring -l "app.kubernetes.io/name=prometheus,app.kubernetes.io/instance=prometheus" -o jsonpath="{.items[0].metadata.name}")

# Launch port forward to access Prometheus
kubectl --namespace continuum-monitoring port-forward $POD_NAME_PROM 9090:9090 &

# Recovering the name of the Grafana pod
POD_NAME_GRAF=$(kubectl get pods --namespace continuum-monitoring -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=grafana" -o jsonpath="{.items[0].metadata.name}")

# Launch port forward to access Grafana
kubectl --namespace continuum-monitoring port-forward $POD_NAME_GRAF 3000:3000 &

# Recovering and displaying admin password for Grafana
GRAFANA_PASSWORD=$(kubectl get secret --namespace continuum-monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode)
echo "Prometheus is now available at http://localhost:9090"
echo "Grafana is now available at http://localhost:3000"
echo "Grafana admin password: $GRAFANA_PASSWORD"