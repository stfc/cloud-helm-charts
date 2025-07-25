# Opensearch

OpenSearch is an open-source search and observability suite for storing unstructured data. 
It can be used to store and analyse logs k8s for instance. See https://opensearch.org/docs/latest/about/

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




3. Adding new security config

You can add extra config by using:

`customSecurityConfigFiles`

and specifying any config files roles.yaml, internal_users.yaml etc. directly
see - https://docs.opensearch.org/latest/security/configuration/yaml/

example files have been included for you to get an initial setup but it is not recommended to use this in production.

## Deployment 

```bash
helm repo add cloud-charts https://stfc.github.io/cloud-helm-charts/
helm repo update
helm install opensearch cloud-charts/stfc-cloud-opensearch -n opensearch-system --create-namespace -f secret-values.yaml
```

## 3. Change the admin password

By default the admin password is `admin` once you deploy opensearch be sure to change the password via the UI or making a post request to the endpoint.

You will want to change the dashboard user `kibanaserver` password, which has default password `kibanaserver` and is the way opensearch dashboards accesses the opensearch nodes

# Configuration

## Defining tenants, users, roles, role-mappings, action groups, index templates and ism policies

You can define these things using custom CRDs that opensearch-operator makes available

See - https://github.com/opensearch-project/opensearch-k8s-operator/blob/main/docs/userguide/main.md#managing-security-configurations-with-kubernetes-resources 

You can generate these CRs by adding entries under `roles`, `users`, and `usersRoleBindings` under the `values.yaml` file. See comments for examples 