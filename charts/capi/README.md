# STFC Cloud CAPI Chart

This chart deploys a Cluster-API (CAPI) K8s Cluster intended to be run on the STFC Cloud. 

# Requirements 

- An openstack project on the STFC Cloud with enough quota.
- A dedicated floating IP on the project
- An ubuntu VM 

1. Setup an application credential and download clouds.yaml 

2. SSH into your ubuntu VM

3. Run Bootstrap script
```bash
# in repo root
./scripts/bootstrap-capi-cluster.sh --floating-ip 130.x.x.x --app-cred-fp /path/to/clouds.yaml
``` 
This will create a `/tmp/capi/secret-values.yaml` file with your cluster secrets 

4. Install the chart

```bash
export CLUSTER_NAME="demo-cluster"  # or your cluster name
helm upgrade $CLUSTER_NAME cloud-charts/openstack-cluster --install -f values.yaml -f user-values.yaml -f flavors.yaml -f /tmp/capi/secret-values -n clusters 
```
5. Perform move to self-managed cluster 

see https://stfc.atlassian.net/wiki/spaces/CLOUDKB/pages/211878034/Cluster+API+Setup#Deploying-Cluster