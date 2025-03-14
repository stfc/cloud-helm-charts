#!/usr/bin/env bash
set -euo pipefail

# Function to convert dependencies to a valid environment variables
sanitize_var_name() {
    echo "$1" | tr '-' '_' | tr '[:lower:]' '[:upper:]'
}

# Read in dependencies.json file
set_env_vars() {
    local json_file="$1"
    
    # Check if jq is installed
    if ! command -v jq &> /dev/null; then
        echo "Error: jq is not installed. Please install jq to parse JSON."
        exit 1
    fi
    
    # Read each key-value pair from the JSON file
    while IFS='=' read -r key value; do
        # Sanitize the key to create a valid environment variable name
        env_var=$(sanitize_var_name "$key")

        # Set the environment variable
        export "$env_var"="$value"
        echo "Set $env_var=$value"
    done < <(jq -r 'to_entries[] | .key + "=" + .value' "$json_file")
}

# Set environment variables from dependencies.json
set_env_vars "dependencies.json"

echo "Updating system to apply latest security patches..."
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -qq
# Shut apt up, since it just blows up the logs
sudo apt-get upgrade -y -qq > /dev/null

echo "Installing required tools..."
sudo apt-get install -y snapd
export PATH=$PATH:/snap/bin
sudo snap install kubectl --classic
sudo snap install helm --classic

curl --no-progress-meter -L "https://github.com/kubernetes-sigs/cluster-api/releases/download/${CLUSTER_CTL_VERSION}/clusterctl-linux-amd64" -o clusterctl
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
clusterctl init --infrastructure=openstack:"${CAPO_PROVIDER_VERSION}"

echo "Importing required helm repos and packages"
helm repo add cloud-charts https://stfc.github.io/cloud-helm-charts/
helm repo add capi-addons https://azimuth-cloud.github.io/cluster-api-addon-provider
helm repo update
helm upgrade cluster-api-addon-provider capi-addons/cluster-api-addon-provider --create-namespace --install --wait -n clusters --version "${AZIMUTH_CAPO_ADDON_VERSION}"


echo "You are now ready to create a cluster - see README.md"