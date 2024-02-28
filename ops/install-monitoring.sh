#!/bin/bash

# Add the Prometheus Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Install Prometheus
helm install prometheus prometheus-community/prometheus

# Add the Grafana Helm repository
helm repo add grafana https://grafana.github.io/helm-charts

# Install Grafana
helm install grafana grafana/grafana

# Upgrade Grafana install with value.yaml file
helm upgrade grafana grafana/grafana -f grafana/values.yml