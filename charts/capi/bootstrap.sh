#!/usr/bin/env bash
set -euo pipefail

# Check if correct number of arguments provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <ip-address> <clouds-yaml-filepath>"
    exit 1
fi

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

IP_ADDRESS=$1
CREDS_FILE=$2:./clouds.yaml

# Check a clouds.yaml filepath exists (by default checks if in same directory)
if [ ! -f "$CREDS_FILE" ]; then
    echo "Error: clouds.yaml file $CREDS_FILE does not exist"
    exit 1
fi

echo "Updating system to apply latest security patches..."
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -qq
# Shut apt up, since it just blows up the logs
sudo apt-get upgrade -y -qq > /dev/null

echo "Installing required tools..."
sudo apt-get install -y snapd python3-openstackclient
export PATH=$PATH:/snap/bin
sudo snap install kubectl --classic
sudo snap install helm --classic
sudo snap install yq

curl --no-progress-meter -L "https://github.com/kubernetes-sigs/cluster-api/releases/download/${CLUSTER_CTL_VERSION}/clusterctl-linux-amd64" -o clusterctl
chmod +x clusterctl
sudo mv clusterctl /usr/local/bin/clusterctl

# Check that application_credential_id existing in clouds.yaml
# This has to be done after yq is installed
if [ "$(yq -r '.clouds.openstack.auth.application_credential_id' $CREDS_FILE)" == "null" ]; then
    # Enforce the use of app creds
    echo "Error: An app cred clouds.yaml file is required in the clouds.yaml file, normal creds (i.e. those with passwords) are not supported"
    exit 1
fi

if [ "$(yq -r '.clouds.openstack.auth.project_id' $CREDS_FILE)" == "null" ]; then
    echo "Looking up project_id for clouds.yaml..."
    APP_CRED_ID=$(yq -r '.clouds.openstack.auth.application_credential_id' $CREDS_FILE)
    PROJECT_ID=$(openstack --os-cloud openstack application credential show ${APP_CRED_ID} -c project_id -f value)
    echo "Injecting project ID: '${PROJECT_ID}' into clouds.yaml..."
    injected_id=$PROJECT_ID yq e '.clouds.openstack.auth.project_id = env(injected_id)' -i $CREDS_FILE
fi

# Setup Secrets file
# Read the entire clouds section from the credentials file and combine with IP
cat > /tmp/capi/secret-values.yaml << EOF
openstack-cluster:
  apiServer: 
    floatingIP: $IP_ADDRESS
  $(yq '.clouds' "$CREDS_FILE" | sed 's/^/  /')
EOF
echo "created secrets file in /tmp/capi/secret-values.yaml"


echo "Installing and starting microk8s..."
sudo snap install microk8s --classic
sudo microk8s status --wait-ready

echo "Exporting the kubeconfig file..."
mkdir -p ~/.kube/
sudo microk8s.config  > ~/.kube/config
sudo chown $USER ~/.kube/config
sudo chmod 600 ~/.kube/config
sudo microk8s enable dns


echo "Initialising cluster-api OpenStack provider..."
echo "If this fails you may need a GITHUB_TOKEN, see https://stfc.atlassian.net/wiki/spaces/CLOUDKB/pages/211878034/Cluster+API+Setup for details"
clusterctl init --infrastructure=openstack:${CAPO_PROVIDER_VERSION}

echo "Importing required helm repos and packages"
helm repo add cloud-charts https://stfc.github.io/cloud-helm-charts/
helm repo update

echo "You are now ready to create a cluster following the remaining instructions..."
echo "https://stfc.atlassian.net/wiki/spaces/CLOUDKB/pages/211878034/Cluster+API+Setup"

