# STFC Cloud Openstack Cluster Chart

This chart deploys a Cluster-API (CAPI) K8s Cluster intended to be run on the STFC Cloud (Openstack). 

# Requirements 

- An openstack project on the STFC Cloud with enough quota.
- A dedicated floating IP on the project - to access your cluster with
- An ubuntu VM 
- An application credential on your target project and download clouds.yaml
  - Documentation on obtaining an app cred can be found [here](https://stfc.atlassian.net/wiki/spaces/SC/pages/357564539/Application+credentials) 

# Configuration

To configure your CAPI cluster, we make available 2 files containing various values you're likely to want to change.
You can copy and edit the file locally and use it as another source of helm values when installing via `helm install`

`nodes.yaml` - This file contains values that setup your cluster's worker and control plane nodes.
- e.g. To add/edit new group of worker nodes - modify entries under `openstack-cluster.nodeGroups` 

`addons.yaml` - This file contains values setup addon services including: 
  - Monitoring - using [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/values.yaml)
  - Logging - using [loki-stack](https://github.com/grafana/helm-charts/blob/main/charts/loki-stack/values.yaml)
  - [Nginx ingress controller](https://github.com/kubernetes/ingress-nginx/blob/main/charts/ingress-nginx/values.yaml)


# Installation

1. For a fresh install, clone the repo, modify `nodes.yaml` and `addons.yaml` files locally - see "Configuration" above

2. Run `cloud-helm-charts/charts/stfc-cloud-openstack-cluster/scripts/set-project-id.sh </path/to/clouds.yaml>`
- This modifies your clouds.yaml to add the corresponding `project_id` to the appplication credential

> [!NOTE] 
> Step 2 is mandatory, but only needs to be run once per new clouds.yaml


2. Run `cloud-helm-charts/charts/stfc-cloud-openstack-cluster/scripts/bootstrap.sh`

> [!NOTE]
> This script will setup a microk8s cluster which will be used to spin up your cluster 

> [!NOTE]
> This step is OPTIONAL if you 
>   - have a bootstrap cluster already setup
>   - you're spinning up a child cluster

3. Install the chart, `openstack-cluster.apiServer.floatingIP` needs to be set to the floating IP you setup to access your cluster - see Requirements

```bash
export CLUSTER_NAME="demo-cluster"  # or your cluster name
helm upgrade $CLUSTER_NAME cloud-charts/stfc-cloud-openstack-cluster --install -f values.yaml -f addons.yaml -f nodes.yaml -f /path/to/clouds.yaml --set openstack-cluster.apiServer.floatingIP=130.246.xxx.xxx --set openstack-cluster.cloudCredentialsSecretName=${CLUSTER_NAME}-cloud-credentials -n ${CLUSTER_NAME}
```

4. Check the cluster status

When the deployment is complete clusterctl will report the cluster as Ready: True

```bash
clusterctl describe cluster $CLUSTER_NAME -n ${CLUSTER_NAME}
```

Progress can be monitored with the following command in a separate terminal:

```bash
kubectl logs deploy/capo-controller-manager -n capo-system -f
```

Once this is deployed you can get the kubeconfig like so:

```bash
clusterctl get kubeconfig $CLUSTER_NAME -n ${CLUSTER_NAME} > $CLUSTER_NAME.kubeconfig
```

you should be able to run commands on your cluster like this:
```bash
KUBECONFIG=$CLUSTER_NAME.kubeconfig kubectl get nodes
```

5. (Optional) Perform move to self-managed cluster

> [!NOTE]
> Ignore this if you are deploying a child cluster

Install clusterctl into the new cluster and move the control plane
```bash
clusterctl init --infrastructure=openstack:v0.10.5 --kubeconfig=$CLUSTER_NAME.kubeconfig
clusterctl move --to-kubeconfig $CLUSTER_NAME.kubeconfig -n ${CLUSTER_NAME}
```
 
Ensure the control plane is now running on the new cluster:

```bash
kubectl get kubeadmcontrolplane --kubeconfig=$CLUSTER_NAME.kubeconfig -n ${CLUSTER_NAME}
```

Using the new control plane by default, 
you can optionally replace the existing kubeconfig with the new cluster’s kubeconfig to make things easier

```bash
cp -v $CLUSTER_NAME.kubeconfig ~/.kube/config
# Ensure kubectl now uses the new kubeconfig displayed the correct nodes:
```

Ensure that this command does not say either minikube or microk8s (i.e. your local machine)
```bash
kubectl get nodes
```

Run the install step again on the new cluster - to self manage the cluster
```bash
# Update the cluster to ensure everything lines up with your helm chart
helm upgrade --create-namespace cluster-api-addon-provider capi-addons/cluster-api-addon-provider --install --wait --version 0.7.0 -n capi-addon-system
helm upgrade $CLUSTER_NAME cloud-charts/stfc-cloud-openstack-cluster --install -f values.yaml -f addons.yaml -f nodes.yaml -f /path/to/clouds.yaml --set openstack-cluster.apiServer.floatingIP=130.246.xxx.xxx --set openstack-cluster.cloudCredentialsSecretName=${CLUSTER_NAME}-cloud-credentials -n ${CLUSTER_NAME}3
```