# Manila

This chart provides an opinionated installation of Manila CSI for the STFC Cloud. Using the [Manila CSI Helm Chart](https://github.com/kubernetes/cloud-provider-openstack/blob/master/docs/manila-csi-plugin/using-manila-csi-plugin.md) as a dependency chart.

Manila is a service that provides shared filesystem for services. Manila CSI enables kubernetes services to provision and manage Manila shares. 

See our Docs on [using Manila on Kubernetes](https://stfc.atlassian.net/wiki/spaces/SC/pages/117375031/Manila+on+Kubernetes) 


# Pre-requisites

Make sure that the project your cluster is built on is permitted to create shares and has spare share instances and share storage capacity - if not, raise a ticket to cloud-support@stfc.ac.uk 

Create an application credential on your project for Manila-CSI to access openstack

# Installation

Make sure you have downloaded `clouds.yaml` file containing your application credential.

```bash
helm repo add cloud-charts https://stfc.github.io/cloud-helm-charts/
helm repo update
helm install manila-csi cloud-charts/stfc-cloud-manila-csi -n manila-csi --create-namespace -f path/to/clouds.yaml
```