# STFC Cloud Logging Chart

This is an alpha version of this chart
> [!NOTE]
> This chart is in active development, and may not yet be useful to most users beyond for setting up fluentbit to output to opensearch without having to create a secret resource.
> Future development will aim to setup log filtering via custom filter resources, to programatically generate and manage opensearch credentials, to integrate trivy for security compliance, and to work on some method for secure log aggregation for all user clusters.

This chart configures automatic log collection using [fluent-operator](https://github.com/fluent/fluent-operator/tree/master/charts/fluent-operator) (which implements fluent-bit). It collects cluster logs from all services running under kubernetes and send them to a configurable set of outputs. By default, this is only to Loki, running under the Loki-Stack component of our [Openstack Cluster chart](https://github.com/stfc/cloud-helm-charts/tree/main/charts/stfc-cloud-openstack-cluster)

# Installation

## Configure openstack cluster

If you intend to use Fluent-Operator to output to the Loki-Stack component of our capi openstack cluster chart, you must first enable Loki-Stack and disable its promtail component, which is deprecated and can be replaced by FluentBit.

In the `values.yaml`, under the Addons section, enable LokiStack but disable Promtail:
```yaml
addons:
  monitoring:
    enabled: true
    lokiStack:
      enabled: true
      release:
        values:
          promtail:
          enabled: false
```

You must then run a Helm Upgrade on the cluster, passing these new values, in order to re-enable Loki-Stack.

> Note if outputting to Loki that by default, Grafana is only available from within the cluster and must be accessed using
[port forwarding](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/):
```sh
kubectl -n monitoring-system port-forward svc/kube-prometheus-stack-grafana 3000:80
```
> If desired, an ingress can be configured for it. But this must be properly secured i.e. using Oauth2, or using network restriction and basic-auth.


If you don't intend to output to Loki-Stack, comment out the configuration block in `values.yaml`.

## Configure OpenSearch

FluentBit can output to multiple destinations, see the fluentbit-output-* templates [here](https://github.com/fluent/fluent-operator/tree/master/charts/fluent-operator/templates)

One of those destinations is OpenSearch.

You'll need to configure the credentials, and the connection details.

Under the `opensearch` block in `values.yaml`, configure values as desired.
   
See `secret-values.yaml.template` to set the credentials.
Copy the template file to a temporary directory outside of the repo - like `/tmp` and edit it

```bash
git clone https://github.com/stfc/cloud-helm-charts.git
cd cloud-helm-charts/charts/stfc-cloud-logging
cp secret-values.yaml.template /tmp/secret-values.yaml
chmod 600 /tmp/secret-values.yaml
``` 

If you instead don't wish to output to opensearch, the configuration block can be commented out.

## Install the chart

Install the chart using Helm. If setting up output to OpenSearch, pass in the created `secret-values.yaml`.
If you have instead disabled the opensearch output, remove the `secret-values.yaml` argument from the below install command.

```bash
helm repo add cloud-charts https://stfc.github.io/cloud-helm-charts/
helm repo update
helm install fluent-operator cloud-charts/stfc-cloud-fluent-operator -n monitoring-system --create-namespace -f values.yaml -f /tmp/secret-values.yaml
```
