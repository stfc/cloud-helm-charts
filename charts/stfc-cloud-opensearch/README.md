# Opensearch

OpenSearch is an open-source search and observability suite for storing unstructured data. 
It can be used to store and analyse logs k8s for instance. See https://opensearch.org/docs/latest/about/

This Helm chart deploys an OpenSearch cluster - it uses the [opensearch-operator chart](https://github.com/opensearch-project/opensearch-k8s-operator/tree/main/opensearch-operator) as a dependency chart. 

This chart adds some slight modifications so that we can define security config - such as users, roles, role mappings via helm

We also setup IRIS-IAM authentication for opensearch dashboards.

# Prerequisites

## Storage
We've tested OpenSearch using `longhorn` as default storage - for quick install, ensure longhorn is deployed and available to use. Other storage classes are available and should work - but these haven't been tested

## Ingress
For Opensearch and Opensearch Dashboards to be accessible outside the cluster - we recommend using nginx ingress. Make sure its enabled on your cluster


# Installation


## Setup Secrets

To use this chart, you need to provide secret values. Follow these steps:

1. Copy the template file:
   ```bash
   cp secret-values.yaml.template /tmp/secret-values.yaml
  chmod 600 /tmp/secret-values.yaml
   ```

2. Edit secret-values.yaml with your actual secret values

Note: secret-values.yaml is git-ignored for security. Never commit actual secrets.

## 2. (Optional) Setup IRIS IAM

If you are using IRIS IAM authentication (`openid.enabled=true`)
You'll need to configure an IRIS-IAM application and set the secret/id in your `secret-values.yaml` 

## Deployment 

```bash
helm repo add cloud-charts https://stfc.github.io/cloud-helm-charts/
helm repo update
helm install chatops cloud-charts/stfc-cloud-opensearch -n opensearch-system --create-namespace -f secret-values.yaml
```


# Configuration

## Defining action_groups, tenants, users, roles and role-mappings

You can setup action_groups, tenants, users, roles and role-mappings using this helm chart. This chart automatically builds the YAML configuration files that OpenSearch security plugin uses. See chart values.yaml for examples

## DNS + cert

To configure DNS name for OpenSearch + OpenSearch Dashboards you can add cluster-specific ingress specification. See below for example

We utilise [cert-manager](https://cert-manager.io/) for managing certs

```yaml
# for access to opensearch dashboards
dashboards:
  ingress:
    annotations:
      cert-manager.io/cluster-issuer: self-signed # le-staging, le-prod for let's encrypt
    hosts:
      - host: dashboards.dev.nubes.stfc.ac.uk
        paths:
          - path: /
            pathType: ImplementationSpecific
    tls:
      - secretName: opensearch-tls
        hosts:
          - dashboards.dev.nubes.stfc.ac.uk


# for access to opensearch nodes
ingress:
  annotations:
    cert-manager.io/cluster-issuer: self-signed # le-staging, le-prod for let's encrypt
  hosts:
    - host: nodes.dev.nubes.stfc.ac.uk
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls:
    - secretName: opensearch-tls
      hosts:
        - nodes.dev.nubes.stfc.ac.uk
```