# STFC Cloud Harbor

This chart configures an opinionated release of the Harbor helm chart - https://github.com/goharbor/harbor-helm

Harbor is an open-source cloud registry that allows developers to securely store, distribute, and manage container images. It provides a centralised environment ensuring only trusted images are used in deployments. See https://goharbor.io/

We use this chart to set global shared values between staging and prod STFC Cloud Harbor services
   
This chart pins the version of the harbor subchart along with our values so we can easily rollback and upgrade this chart on our clusters by pointing to a different version 

This chart is deployed onto our clusters using argocd using this gitops repo - https://github.com/stfc/cloud-deployed-apps/

In this chart, we deploy the harbor service 

We also setup the following: 

1. A cronjob to backup s3 bucket we use for storing harbor image data on a monthly/weekly/daily basis

2. A set of cert-manager managed TLS certificates for each harbor pod to enable encrypted east-west traffic 
    - this is more compatible with argocd than using auto-generated one via the harbor helm chart

3. A backendTLSpolicy to rencrypt backend ingress traffic from gatewayAPI to enable fully encrypted ingress traffic 

4. A set of basic prometheus rules for alerting on service health

5. A grafana dashboard taken and modified from -  https://grafana.com/grafana/dashboards/15792-harbor/


# Configuration

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