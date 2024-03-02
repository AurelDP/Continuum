#!/bin/bash

# Creating continuum-monitoring namespace
kubectl create namespace continuum-monitoring

# Add the Prometheus & Grafana Helm repositories
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install Prometheus & Grafana
helm upgrade --install prometheus prometheus-community/prometheus --namespace=continuum-monitoring
helm upgrade --install --values grafana/values.yml grafana grafana/grafana --namespace=continuum-monitoring