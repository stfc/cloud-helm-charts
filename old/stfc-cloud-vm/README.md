# Victoria Metrics

Victoria Metrics is time-series database (TSDB). 
This chart deployes an opinionated version of the [Victoria Metrics Cluster Chart](https://github.com/VictoriaMetrics/helm-charts/tree/master/charts/victoria-metrics-cluster). Which we use to store metrics for various services within SCD


# Installation

```bash
helm repo add cloud-charts https://stfc.github.io/cloud-helm-charts/
helm repo update
helm install stfc-cloud-vm cloud-charts/stfc-cloud-vm -n victoria-metrics --create-namespace 
```

# Configuration

> [!NOTE] 
> Docs to configure victoria-metrics ingress and storage are a work in progress and will be added in the future