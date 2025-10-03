# Docker Registry pull-through Cache

This chart will setup a docker registry as a pull-through cache service.

Since 20/11/2020 dockerhub rate limited free users, hence we implemented a registry mirror to cache popular images for our users and SCD in general. 

Forked from: https://github.com/twuni/docker-registry.helm

This Helm chart uses official Docker Registry image: https://hub.docker.com/_/registry/

# Prerequsits

You will need: 

- url, username & password to a docker registry you want to mirror

- (optional) for S3 persistent storage: S3 quota on the project
- (optional) for other storage methods (like manila/cinder/longhorn) setup a storageclass
- Setup nginx ingress to be accessible outside the cluster and ensure cert issuers are setup and can be accessed (like letsencrypt)

# Installations

## Setup Secrets

To use this chart, you need to provide secret values.

1. Copy the template

```bash
git clone "https://github.com/stfc/cloud-helm-charts.git"
cd cloud-helm-charts/charts/stfc-cloud-docker-registry/
cp secret-values.yaml.template /tmp/secret-values.yaml
```

2. Edit secret-values.yaml with your actual secret values

Note: secret-values.yaml is git-ignored for security. Never commit actual secrets.


## Deployment

```bash
helm repo add cloud-charts https://stfc.github.io/cloud-helm-charts/
helm repo update
helm install harbor cloud-charts/stfc-cloud-docker-registry -n docker-registry --create-namespace -f values -f /tmp/secret-values.yaml
```

# Configuration
Add host to ingress for DNS name which can be used to access harbor. [Cert-manager](https://cert-manager.io/) is used for managing certificates.

```yaml
# Access to harbor service
harbor:
  externalURL: "https://dockerhub.example.com"
  expose:
    ingress:
      hosts:
        core: "dockerhub.example.com"
      annotations:
        cert-manager.io/cluster-issuer: self-signed # le-staging, le-prod for let's encrypt
```

Metrics collection will occur automatically if you enable metrics and metrics.serviceMonitor (provided you have prometheus running). 

TODO: No prometheus rules or grafana dashboards are configured be default 