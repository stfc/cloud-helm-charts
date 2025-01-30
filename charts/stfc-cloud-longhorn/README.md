# Longhorn Chart

This chart provides an opinionated deployment of Longhorn for the STFC Cloud
Longhorn is a Cloud Native application for presistent block storage.  See [Longhorn docs](https://longhorn.io/docs/latest/). It utilises the local storage available on worker nodes, creating and managing replicas of container volumes to keep data persistent 

To deploy Longhorn we utilise the longhorn helm chart as a subchart. See [Chart Repo](https://github.com/longhorn/longhorn/tree/master/chart).

# Installation

```bash
helm repo add cloud-charts https://stfc.github.io/cloud-helm-charts/
helm repo update
helm install longhorn cloud-charts/stfc-cloud-longhorn -n longhorn-system --create-namespace 
```

# Configuration

## 1. **(Optional)** Label nodes to run longhorn on

Make sure you have labelled your nodes so that longhorn can use them as storage nodes. 

If you're using our `stfc-cloud-openstack-cluster` chart - these are set for you by default so you don't need to do anything.  

If not, you want to label your worker nodes, the default label is - `longhorn.store.nodeselect/longhorn-storage-node: "true"`. Run the following on all your worker nodes:

```bash
kubectl label node my-worker-node longhorn.store.nodeselect/longhorn-storage-node="true" -n clusters
```

If you want to change the label you can change this in the cluster-specific values like so. Not recommended unless you know what you are doing. If you're using stfc-cloud-openstack-cluster chart - you must also change the worker node labels. 

```yaml
longhorn:	
  longhornManager:	
    nodeSelector: 	
      # change this to whatever label you want	
      longhorn.store.nodeselect/longhorn-storage-node: true	
```

## 2. **(Optional)** Set proper ingress domain name 

To access the Longhorn UI - the chart is setup to use ingress by default - change the domain away from the default.

```yaml
longhorn:
  ingress:
    host: longhorn.example.com # change this
```

If you prefer to use a loadbalancer rather than ingress - you can set it like so

```yaml
longhorn:
  ingress:
    enabled: false
  service:
    ui:
        # -- Service type for Longhorn UI. (Options: "ClusterIP", "NodePort", "LoadBalancer", "Rancher-Proxy")
        type: Loadbalancer
        loadBalancerIP: 130.246.x.x
```