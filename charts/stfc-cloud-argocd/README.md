# STFC Cloud ArgoCD

This chart configures an opinionated release of argo-cd helm chart - https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd

We use this chart to set shared values for the STFC K8s platforms which we use to run multiple services

We deploy argocd onto each cluster and that manages all the services for that cluster
  
This chart pins the version of the envoy subchart along with our values so we can easily rollback and upgrade this chart on our clusters by pointing to a different version

This chart is deployed onto our clusters using argocd using this gitops repo - https://github.com/stfc/cloud-deployed-apps/

In this chart, we deploy argo-cd along with CRDs 

We also setup the following: 

1. configure argoCD to work with SOPS encrypted helm secrets
    - we don't use a secrets manager service, instead we store secrets in helm files and encrypt our secrets at rest using SOPS in cloud-deployed-apps - argocd will decrypt and use them
    - this doc explains how to configure argocd to use sops - https://github.com/jkroepke/helm-secrets/wiki/ArgoCD-Integration

2. setup internal TLS to encrypt east-west traffic on cluster - requires our cert-manager chart to be installed - see charts/stfc-cloud-cert-manager

3. setup IRIS-IAM oidc login
- client ID and secret provided via 

```yaml
  argo-cd:
    configs:
        secret:
            extra:
                oidc.irisiam.clientID: foo
                oidc.irisiam.clientSecret: bar

```

4. setup httproute for gateway api ingress, and setup backendtlspolicy to enable rencryption to backend https service for full encrypted ingress traffic   

