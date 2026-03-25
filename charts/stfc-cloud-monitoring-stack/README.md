# STFC Cloud Monitoring Stack 

This chart sets up an opinionated release of kube-prometheus-stack helm chart - https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/Chart.yaml - with some extra dashboards and features tailored for STFC Cloud clusters

We use this chart to set shared values for the STFC K8s platforms which we use to run multiple services

We deploy monitoring-stack onto each cluster and that manages all the services for that cluster
  
This chart pins the version of the kube-prometheus-stack subchart along with our values so we can easily rollback and upgrade this chart on our clusters by pointing to a different version

We use this chart instead of capi-helm-charts monitoring addon because it is easier to configure and manage

This chart is deployed onto our clusters using argocd using this gitops repo - https://github.com/stfc/cloud-deployed-apps/

In this chart, we deploy kube-prometheus-stack along with CRDs 

We also setup the following: 

1. IRIS IAM OIDC setup for IRIS-IAM

2. gateway API ingress for prometheus, alertmanager and grafana, and SecurityPolicies to setup basicAuth for the prometheus and alertmanager service (grafana has it's own internal login page so we don't setup one for it)

3. some dashboards from - https://github.com/azimuth-cloud/capi-helm-charts/tree/main/charts/cluster-addons/grafana-dashboards - so we don't lose them from moving away from using CAPI addons monitoring

4. an alertmanager config for our K8s platforms to send alerts to our opsgenie 
