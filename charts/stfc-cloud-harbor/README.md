# Harbor

This is an alpha version of this chart

Harbor is an open-source cloud registry that allows developers to securely store, distribute, and manage container images.
It provides a centralised environment ensuring only trusted images are used in deployments. See https://goharbor.io/

This Helm chart deploys a Harbor cluster - it uses the [Harbor chart](https://github.com/goharbor/harbor-helm) with custom configuration.

# Prerequisites
You will need S3 Quota allocated to your project.

## Storage
Harbor use S3 as storage backend, and an external database for users and logging.

## Ingress
It uses nginx ingress to be accessible outside the cluster - make sure it is enabled.

# Installation

## Setup Secrets

To use this chart, you need to provide secret values. Follow these steps:

1. Copy the template file:

```bash
git clone https://github.com/stfc/cloud-helm-charts.git
cd cloud-helm-charts/charts/stfc-cloud-harbor/
cp secret-values.yaml.template /tmp/secret-values.yaml
```

2. Edit secret-values.yaml with your actual secret values

Note: secret-values.yaml is git-ignored for security. Never commit actual secrets.

## Deployment

```bash
helm repo add cloud-charts https://stfc.github.io/cloud-helm-charts/
helm repo update
helm install harbor cloud-charts/stfc-cloud-harbor -n harbor --create-namespace -f values -f /tmp/secret-values.yaml
```

# Configuration
Add host to ingress for DNS name which can be used to access harbor. [Cert-manager](https://cert-manager.io/) is used for managing certificates.

```yaml
# Access to harbor service
harbor:
  externalURL: "https://harbor.example.com"
  expose:
    ingress:
      hosts:
        core: "harbor.example.com"
      annotations:
        cert-manager.io/cluster-issuer: self-signed # le-staging, le-prod for let's encrypt
```

```yaml
# Add An external postresql database host
database:
  type: external
  external:
    host: "host.example.com"
    port: "5432"
    coreDatabase: "harbor_registry"
    username: "registry_user"
    # if using existing secret, the key must be "password"
    password: "password"
```

```yaml
# Add source and backup bucket
backup:
  enable: true
  sourceBucket: "s3://harbor-source-bucket"
  destination:
    daily: "s3://harbor-destination-backup/daily"
    weekly: "s3://harbor-destination-backup/weekly"
    monthly: "s3://harbor-destination-backup/monthly"
  endpoint: "https://s3.example.com"
```