# Harbor

Harbor is an open-source cloud registry that allows developers to securely store, distribute, and manage container images.
It provides a centralised environment ensuring only trusted images are used in deployments. See https://goharbor.io/

This Helm chart deploys a Harbor cluster - it uses the [Harbor chart](https://github.com/goharbor/harbor-helm).

# Prerequisites

## Storage
Harbor will use S3 for image storage, and an external database for users and logging.

## Ingress
It uses nginx ingress - make sure it is enabled and assign a floating ip to the loadbalancerIP.
```
...
addons:
  ingress:
    enabled: true
    nginx:
      release:
        values:
          controller:
            service:
              # create a floatingip for ingress on your project and put it here
              loadBalancerIP: "x.x.x.x"
```

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

## Deployment

```bash
helm repo add cloud-charts https://stfc.github.io/cloud-helm-charts/
helm repo update
helm install harbor cloud-charts/stfc-cloud-harbor -n harbor --create-namespace -f secret-values.yaml
```

# Configuration
Add host to ingress for DNS name which can be used to access harbor. [Cert-manager](https://cert-manager.io/) is used for managing certificates.

```
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
```
# Add database host
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