# STFC Cloud Openstack Cluster Chart

This chart deploys a Cluster-API (CAPI) K8s Cluster intended to be run on the STFC Cloud (Openstack). 

# Requirements 

- An openstack project on the STFC Cloud with enough quota.
- A dedicated floating IP on the project
- An ubuntu VM 

1. Setup an application credential and download clouds.yaml - place it in this folder 
- make sure it's named "clouds.yaml" otherwise it won't work

2. SSH into your ubuntu VM

3. Run bootstrap script. Specify the floating-ip created. It will used for accessing the cluster's kube API and needs to be manually allocated. 
Documentation on obtaining an app cred can be found [here](https://openstack.stfc.ac.uk/project/floating_ips/) 
```bash
# in repo root
./scripts/bootstrap-capi-cluster.sh 130.x.x.x 
``` 
This will create a `/tmp/capi/secret-values.yaml` file with your cluster secrets 

4. Install the chart

```bash
export CLUSTER_NAME="demo-cluster"  # or your cluster name
helm upgrade $CLUSTER_NAME cloud-charts/stfc-cloud-openstack-cluster --install -f values.yaml -f nodes.yaml -f addons.yaml -f /tmp/capi/secret-values -n clusters 
```
5. Perform move to self-managed cluster 

see https://stfc.atlassian.net/wiki/spaces/CLOUDKB/pages/211878034/Cluster+API+Setup#Deploying-Cluster