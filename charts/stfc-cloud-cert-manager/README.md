# STFC Cloud Cert Manager

This chart configures cert-manager (as subchart) and trust-manager (as subchart) and includes pre-configured issuers - which can be self-signed, or signed by staging/production letsencrypt using HTTP01 challenge via gateway API. 

It also configures a ClusterIssuer for manageing internal (east-west) traffic TLS certs. Trust-manager is used to create a pre-configured "Bundle" resource that gateway API BackendTLSPolicy resources can use to verify internal TLS certs  

cert-manager: https://github.com/cert-manager/cert-manager/tree/master/deploy/charts/cert-manager
trust-manager: https://github.com/cert-manager/trust-manager/tree/main/deploy/charts/trust-manager

This chart pins the version of the envoy subchart along with our values so we can easily rollback and upgrade this chart on our clusters by pointing to a different version

This chart is deployed onto our clusters using argocd using this gitops repo - https://github.com/stfc/cloud-deployed-apps/

In this chart, we deploy cert-manager and trust-manager along with their CRDs 

We also setup the following: 

1. ability to create clusterIssuers for each gatewayAPI gateway - either signed by letsencrypt or self-signed - intended for creating TLS certs for ingress traffic

2. setup an internal clusterIssuer for internal TLS certs - encrypt traffic between pods (east-west) traffic
- This can either be self-signed (by default) or use an pre-configured existing secret  

3. setup a "Bundle" resource (managed by trust-manager) which creates a set of trusted root-certificates (with internal clusterIssuer CA bundled in) to be used by gatwayAPI backendTLSPolicy resources to connect to and verify internal HTTPS services - enabling full ingress encryption for httproutes
 
## Troubleshooting

if you're having issues installing this chart, it may be because cert-manager is already installed onto the cluster (and is not helm managed) you can force helm to take ownership of existing cert-manager resources by passing `--take-ownwership` flag when running `helm install`