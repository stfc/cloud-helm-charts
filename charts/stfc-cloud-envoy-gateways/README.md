# STFC Cloud Envoy Gateway

This chart sets up gateway APIs using Envoy and some other networking features for the STFC Cloud K8s platforms

We use the envoy subchart for deploying envoy gateway api and CRDs - gateway.envoyproxy.io/docs/install/gateway-helm-api/

We use this chart to set shared values for the STFC K8s platforms which we use to run multiple Cloud services

We deploy envoy-proxy onto each cluster to expose our traffic to internal (within the STFC Cloud network) and external (publicly facing) traffic
   
This chart pins the version of the envoy subchart along with our values so we can easily rollback and upgrade this chart on our clusters by pointing to a different version 

This chart is deployed onto our clusters using argocd using this gitops repo - https://github.com/stfc/cloud-deployed-apps/

In this chart, we deploy envoy gateway and CRDs

We also setup the following: 

1. A gateway, gatewayclass and envoyproxy to accept internal traffic
- the LoadbalancerIP and listeners are configured separately per cluster in https://github.com/stfc/cloud-deployed-apps/

2. An optional gateway, gatewayclass and envoyproxy to accept external traffic - for our worker clusters
- the LoadbalancerIP and listeners are configured separately per cluster in https://github.com/stfc/cloud-deployed-apps/

3. A httproute that sets up a simple http -> https redirect rule for all traffic on internal gateway and (if configured) on the external gateway