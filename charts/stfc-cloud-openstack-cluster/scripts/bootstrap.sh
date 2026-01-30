#!/usr/bin/env bash
set -euo pipefail

echo "Installing required tools..."
sudo apt-get install -y snapd python3-openstackclient yq

export PATH=$PATH:/snap/bin
sudo snap install kubectl --classic
sudo snap install helm --classic

echo "Updating system to apply latest security patches..."
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -qq
# Shut apt up, since it just blows up the logs
# On dialogues about config file updates, keep current config file and use default choices
sudo apt-get -o Dpkg::Options::="--force-confold" \
             -o Dpkg::Options::="--force-confdef" \
             -y -qq upgrade > /dev/null


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALUES_DIR=$(dirname $SCRIPT_DIR)

# Check a clouds.yaml file exists in the same directory as the script
if [ ! -f "$VALUES_DIR/clouds.yaml" ]; then
    echo "A clouds.yaml file is required in stfc-cloud-openstack-cluster"
    exit 1
fi

# adding project-id to clouds.yaml
source "$SCRIPT_DIR"/set-project-id.sh "$VALUES_DIR"/clouds.yaml

echo "Installing clusterctl..."
curl --progress-bar -L "https://github.com/kubernetes-sigs/cluster-api/releases/download/${CLUSTER_API}/clusterctl-linux-amd64" -o clusterctl
chmod +x clusterctl
sudo mv clusterctl /usr/local/bin/clusterctl

echo "Installing and starting microk8s..."
sudo snap install microk8s --classic
sudo microk8s status --wait-ready

echo "Exporting the kubeconfig file..."
mkdir -p ~/.kube/
echo "Backing up existing kubeconfig if it exists..."
if [ -f "$HOME/.kube/config" ]; then 
    mv -v "$HOME/.kube/config" "$HOME/.kube/config.bak"
fi

sudo microk8s.config | tee ~/.kube/config > /dev/null
sudo chown "$USER" ~/.kube/config
sudo chmod 600 ~/.kube/config
sudo microk8s enable dns

echo "Initialising cluster-api OpenStack provider..."
echo "If this fails you may need a GITHUB_TOKEN, see https://stfc.atlassian.net/wiki/spaces/CLOUDKB/pages/211878034/Cluster+API+Setup for details"
clusterctl init --infrastructure=openstack:"${CLUSTER_API_PROVIDER_OPENSTACK}"

echo "Importing required helm repos and packages"
helm repo add cloud-charts https://stfc.github.io/cloud-helm-charts/
helm repo add capi-addons https://azimuth-cloud.github.io/cluster-api-addon-provider
helm repo update
helm upgrade cluster-api-addon-provider capi-addons/cluster-api-addon-provider --create-namespace --install --wait -n capi-addon-system --version "${ADDON_PROVIDER}"

export ADDON_VERSION=$ADDON_PROVIDER
export CAPO_PROVIDER_VERSION=$CLUSTER_API_PROVIDER_OPENSTACK

echo ""
echo "=============================================================================="
echo "You are now ready to create a cluster following the remaining instructions..."
echo "See README.md - https://github.com/stfc/cloud-helm-charts/tree/main/charts/stfc-cloud-openstack-cluster/README.md"
echo "=============================================================================="
