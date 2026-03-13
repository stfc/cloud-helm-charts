# STFC Cloud Opensearch

This chart sets up an opinionated release of Opensearch that we use for storing K8s cluster logs

OpenSearch is an open-source search and observability suite for storing unstructured data. 
It can be used to store and analyse logs k8s for instance. See https://opensearch.org/docs/latest/about/

This Helm chart deploys:
  - opensearch operator chart - which installs various CRDs - [opensearch-operator chart](https://github.com/opensearch-project/opensearch-k8s-operator/tree/main/charts/opensearch-operator)

  - opensearch cluster chart - which sets up an opensearch cluster - [opensearch-cluster chart](https://github.com/opensearch-project/opensearch-k8s-operator/tree/main/charts/opensearch-cluster)


We deploy opensearch onto each worker cluster (prod and staging) to store cluster logs 

This chart pins the version of the opensearch subcharts along with our values so we can easily rollback and upgrade this chart on our clusters by pointing to a different version

This chart is deployed onto our clusters using argocd using this gitops repo - https://github.com/stfc/cloud-deployed-apps/

In this chart, we deploy opensearch-operator along with CRDs and setup an opensearch cluster using opensearch-cluster chart 

We also setup the following: 

1. A set of opensearch config files under include/ folder - to be loaded into a secret 
- this allows us to setup roles, rolemappings etc. using infrastructure as code

2. setup gateway API httproutes to expose the opensearch and opensearch-dashboards via gateway API, and backendTLSPolicy for opensearch and opensearch-dashboards to enable full ingress encryption. 
   
3. IRIS-IAM oidc config and RBAC for opensearch dashboards 

4. setup internal certificates using internal cluster issuer - see our cert-manager chart. Works better than generating the certs via opensearch `generate:true` - as is more compatible with argocd 


# Prerequisites

## Storage
We've tested OpenSearch using `longhorn` and `cinder` as default storage - for quick install, ensure `cinder-csi` is deployed and available to use - should be enabled by default on our CAPI clusters. Make sure you also have quota for setting up cinder volumes on your openstack project. Other storage classes are available and should work - but these haven't been tested

# Configuration 
## 1. Adding new security config

You can add extra config by using:

`customSecurityConfigFiles`

and specifying any config files roles.yaml, internal_users.yaml etc. directly
see - https://docs.opensearch.org/latest/security/configuration/yaml/

example files have been included for you to get an initial setup but it is not recommended to use this in production.

## 2. Change the admin password

By default the admin password is `admin` once you deploy opensearch be sure to change the password via the UI or making a post request to the endpoint.

You will want to change the dashboard user `kibanaserver` password, which has default password `kibanaserver` and is the way opensearch dashboards accesses the opensearch nodes


## 3 Defining index templates and ism policies

You can define these things using custom CRDs that opensearch-operator makes available

See - https://github.com/opensearch-project/opensearch-k8s-operator/blob/main/docs/userguide/main.md#managing-security-configurations-with-kubernetes-resources 

