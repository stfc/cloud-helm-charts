# STFC Cloud Logging Chart

> [!CAUTION]
> This is currently under development and should not be used in production!

This chart is required for compliance with STFC Cloud policy on running K8s clusters (currently being developed). 

This chart configures automatic log collection using fluent-operator, it deploys a set of preconfigured fluent-operator CRDs to collect cluster logs from all running services and send them to a central opensearch service.   

# Installation

## Configure secrets

You'll need to configure the following secrets:
1. API Server floating IP and project ID for the cluster 
2. Opensearch hostname, username and password
   
See `secret-values.yaml.template` for how to set these values 
Copy the template file to a temporary directory outside of the repo - like `/tmp` and edit it

```bash
git clone https://github.com/stfc/cloud-helm-charts.git
cd cloud-helm-charts/charts/stfc-cloud-logging
cp secret-values.yaml.template /tmp/secret-values.yaml
``` 

```bash
helm dependency update .
helm install stfc-cloud-logging . -n cert-manager --create-namespace -f /tmp/secret-values.yaml
```

## Developer Notes

We want to make this chart a dependency of stfc-cloud-openstack-cluster
To do this, we must consider:

1. How do we make new K8s clusters authenticate themselves and send logs to OpenSearch
   - we'll need to specify write only credentials via chart
   - should we generate credentials for each cluster?
   - or have a shared one - how do we prevent password leaks?

   - users will have to register their clusters somewhere - so we can setup and provide them opensearch credentials 
   - can we get the chart to generate a request for opensearch info automatically - is it even a good idea?
  
2. How do we ensure that the logs are coming from the correct K8s cluster?
    - 2-way verification - need to create valid tls certs as part of setup 
    - How do we register the certificate on the opensearch side?

3. How do we advertise opensearch endpoint via the chart without making it susceptible to DDOS attacks?
    - every user cluster needs to send logs there, so the endpoint and credentials to access would be made available to everyone

4. How do we prevent users leaking/modifying secrets in the config after setup 
    - setup a inaccessible namespace on the cluster for setting up logging config and logging secrets?
    - setup short-lived opensearch credentials that need renewing?




