# ChatOps

A helm chart for sending Slack messages of open GitHub pull requests to a Slack workspace.
 
# Installation

## populate secrets

see `secret-values.yaml.template` for values that this chart requires that must be a treated as a secret.
copy the template file to a temporary directory outside of the repo - like `/tmp` and edit it

```bash
git clone https://github.com/stfc/cloud-helm-charts.git
cd cloud-helm-charts/charts/chatops
cp secret-values.yaml.template /tmp/secret-values.yaml
```

Once you've filled in the secrets you can install the chart

```bash
helm repo add cloud-charts https://stfc.github.io/cloud-helm-charts/
helm repo update
helm install chatops cloud-charts/chatops -n chatops --create-namespace -f /tmp/secret-values.yaml
```

# Configuration

TODO