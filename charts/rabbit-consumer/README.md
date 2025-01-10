# Rabbit Consumers

This Chart deploys code to monitor rabbit and automatically register machines in aquilon - a configuration management tool

See rabbit-consumer container and source code here - https://github.com/stfc/cloud-docker-images/

# Prerequisites

## Storage
This application does not require persistent storage and is completely standalone.

## Setup Secrets

- Install secret from an existing krb5.keytab, this should match the principle used in the values.yaml file:

`kubectl create secret generic rabbit-consumer-keytab --from-file krb5.keytab -n rabbit-consumers`

- Install secrets for the Rabbit and Openstack credentials
  based on the following .yaml template:

```yaml
kind: Namespace
apiVersion: v1
metadata:
  name: rabbit-consumer
  labels:
    name: rabbit-consumer
---
apiVersion: v1
kind: Secret
metadata:
  # This should match the values.yaml values
  name: openstack-credentials
  namespace: rabbit-consumers
type: Opaque
stringData:
  OPENSTACK_USERNAME:
  OPENSTACK_PASSWORD:
---
apiVersion: v1
kind: Secret
metadata:
  name: rabbit-credentials
  namespace: rabbit-consumers
type: Opaque
stringData:
  RABBIT_USERNAME:
  RABBIT_PASSWORD:
```

## Choose Environment Values File

Multiple values files are provided to target various environments:

- `values.yaml`: Attributes common to all environments (e.g. Aquilon URL). If you are using the repo this can be omitted.
- `dev-values.yaml`: Attributes for the dev Openstack environment. This assumes the PR is merged as it points to the `qa` tag.
- `prod-values.yaml`: Attributes for production. This does not include the tag, instead relying on the app version in Chart.yaml
- `staging-values.yaml`: Targets the dev Openstack environment, but pulls the latest build from the most recent PR. (Typically used to test before merging)

# Installation

The correct template needs to be selected from above, where `<template.yaml>` is the placeholder:

```bash
helm repo add cloud-charts https://stfc.github.io/cloud-helm-charts
helm upgrade --install rabbit-consumer cloud-charts/rabbit-consumer-chart -f values.yaml -f <template.yaml>
```

# Upgrades

Upgrades are similarly handled:

```bash
helm upgrade rabbit-consumer cloud-charts/rabbit-consumer-chart  -f values.yaml -f <template.yaml>
```

If required a version can be specified:

```bash
helm upgrade rabbit-consumer cloud-charts/rabbit-consumer-chart  -f values.yaml -f <template.yaml> --version <version>
```

# Startup

The pod may fail 1-3 times whilst the sidecar spins up, authenticates and caches the krb5 credentials. During this time the consumer will start, check for the credentials and terminate if they are not ready yet.

The logs can be found by doing
`kubectl logs deploy/rabbit-consumers -n rabbit-consumers -c <container>`

Where `<container>` is either `kerberos` or `consumer` for the sidecar / main consumers respectively. 


# Updating This Chart

If you have made changes to the rabbit consumer source-code/dockerfiles - see https://github.com/stfc/cloud-docker-images/openstack-rabbit-consumer. Make sure the new docker image is uploaded to harbor.stfc.ac.uk - should be done automatically

Then, you will need to update the version of the docker image used in this chart accordingly.

If you have updated the chart itself, you will need to update the version of the chart. But you can skip updating the image if appropriate.

Once a new image is available, the version in the helm chart needs to be updated. This is done by editing the `Chart.yaml` file and updating the `appVersion` field.

Update the chart version to reflect the changes. Minor changes (such as the image version) should increment the patch version. Changes to this chart should increment the major/minor/patch according to SemVer guidance.

# Testing Locally

## Initial setup

- Spin up minikube locally
- Install the secrets, as per the instructions above
- Make docker use the minikube docker daemon in your current shell:
`eval $(minikube docker-env)`

## Testing

- Build the docker image locally:
```bash
git clone https://github.com/stfc/cloud-docker-images.git
cd cloud-docker-images/rabbit-consumer
docker build -t rabbit-consumer:local .
```

- cd to the chart directory:
`cd ~/cloud-helm-charts/charts/rabbit-consumer`

- Install/Upgrade the chart with your changes:
`helm install rabbit-consumer . -f values.yaml -f dev-values.yaml -n rabbit-consumer`

- To deploy a new image, rebuild and delete the existing pod:
`docker build -t rabbit-consumer:local . && kubectl delete pod -l app=rabbit-consumer -n rabbit-consumer`

- Logs can be found with:
`kubectl logs deploy/rabbit-consumer -n rabbit-consumer`
