# Opensearch

OpenSearch is an open-source search and observability suite for storing unstructured data. 
It can be used to store and analyse logs k8s for instance. See https://opensearch.org/docs/latest/about/

This Helm chart sets up an opensearch chart with some opinionated values so that it can work on the STFC Cloud - such as setting up IRIS-IAM authentication for opensearch dashboards.

This Helm chart deploys:
  - opensearch operator chart - which installs various CRDs - [opensearch-operator chart](https://github.com/opensearch-project/opensearch-k8s-operator/tree/main/charts/opensearch-operator)

  - opensearch cluster chart - which sets up an opensearch cluster - [opensearch-cluster chart](https://github.com/opensearch-project/opensearch-k8s-operator/tree/main/charts/opensearch-cluster)


# Prerequisites

## Storage
We've tested OpenSearch using `longhorn` and `cinder` as default storage - for quick install, ensure `cinder-csi` is deployed and available to use - should be enabled by default on our CAPI clusters. Make sure you also have quota for setting up cinder volumes on your openstack project. Other storage classes are available and should work - but these haven't been tested

## Ingress
For Opensearch and Opensearch Dashboards to be accessible outside the cluster - we recommend using nginx ingress (used by default). Make sure its enabled on your cluster


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

You'll want to setup proper admin credentials for your opensearch cluster here

## 2. (Optional) Setup IRIS IAM

If you want to enable IRIS IAM 
1. uncomment config in `values.yaml` under `opensearch-cluster.cluster.dashboards.additionalConfig`
2. configure an IRIS-IAM application
3. set the application secret + id in `secret-values.yaml` 

## Deployment 

```bash
helm repo add cloud-charts https://stfc.github.io/cloud-helm-charts/
helm repo update
helm install opensearch cloud-charts/stfc-cloud-opensearch -n opensearch-system --create-namespace -f secret-values.yaml
```


# Configuration

## Defining tenants, users, roles, role-mappings, action groups, index templates and ism policies

You can define these things using custom CRDs that opensearch-operator makes available

See - https://github.com/opensearch-project/opensearch-k8s-operator/blob/main/docs/userguide/main.md#managing-security-configurations-with-kubernetes-resources 

You can generate these CRs by adding entries under `roles`, `users`, and `usersRoleBindings` under the `values.yaml` file. See comments for examples 