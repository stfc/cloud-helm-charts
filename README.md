# cloud-helm-charts
A Repository for storing helm charts created for the STFC Cloud

**materials-galaxy:** [README](https://github.com/stfc/cloud-helm-charts/blob/main/charts/materials-galaxy/README.md)  
This Chart deploys Galaxy configured to host materials-galaxy tools and allows authentication via IRIS-IAM.

**stfc-cloud-cert-manager:** [README](https://github.com/stfc/cloud-helm-charts/blob/main/charts/stfc-cloud-cert-manager/README.md)  
Configures cert-manager (as subchart) and includes pre-configured issuers including staging and production letsencrypt - to enable you to setup verified HTTPS certs for your web-apps.

**stfc-cloud-chatops:** [README](https://github.com/stfc/cloud-helm-charts/blob/main/charts/stfc-cloud-chatops/README.md)  
A helm chart for sending Slack messages of open GitHub pull requests to a Slack workspace.

**stfc-cloud-longhorn:** [README](https://github.com/stfc/cloud-helm-charts/blob/main/charts/stfc-cloud-longhorn/README.md)  
Provides an opinionated deployment of Longhorn for the STFC Cloud. Longhorn is a Cloud Native application for presistent block storage.

**stfc-cloud-manila-csi:** [README](https://github.com/stfc/cloud-helm-charts/blob/main/charts/stfc-cloud-manila-csi/README.md)  
Provides an opinionated installation of Manila CSI for the STFC Cloud. Uses the Manila CSI Helm Chart as a dependency chart.

**stfc-cloud-opensearch:** [README](https://github.com/stfc/cloud-helm-charts/blob/main/charts/stfc-cloud-opensearch/README.md)  
This Helm chart deploys an OpenSearch cluster - it uses the opensearch-operator chart as a dependency chart. Adds some slight modifications so that we can define security config - such as users, roles, role mappings via helm. Also sets up IRIS-IAM authentication for opensearch dashboards.

**stfc-cloud-openstack-cluster:** [README](https://github.com/stfc/cloud-helm-charts/blob/main/charts/stfc-cloud-openstack-cluster/README.md)  
This chart deploys a Cluster-API (CAPI) K8s Cluster intended to be run on the STFC Cloud (Openstack).

**stfc-cloud-rabbit-consumer:** [README](https://github.com/stfc/cloud-helm-charts/blob/main/charts/stfc-cloud-rabbit-consumer/README.md)  
This Chart deploys code to monitor rabbit and automatically register machines in Aquilon.

**stfc-cloud-vm:** [README](https://github.com/stfc/cloud-helm-charts/blob/main/charts/stfc-cloud-vm/README.md)  
This chart deployes an opinionated version of the Victoria Metrics Cluster Chart. Which we use to store metrics for various services within SCD

