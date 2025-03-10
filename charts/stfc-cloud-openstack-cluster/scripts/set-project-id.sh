#!/usr/bin/env bash
set -euo pipefail

# Check if file path is provided as an argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <path_to_clouds.yaml>"
    exit 1
fi

CLOUDS_FILE="$1"

# Check if the file exists
if [ ! -f "$CLOUDS_FILE" ]; then
    echo "Error: File '$CLOUDS_FILE' not found"
    exit 1
fi

echo "Installing required tools..."
sudo apt-get install -y python3-openstackclient

# install yq
# snap installed yq cannot be used on files outside "scripts" directory - making it not as useful
if [ ! -f "/usr/bin/yq" ]; then
    sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq && sudo chmod +x /usr/bin/yq
fi

# Check that application_credential_id exists in clouds.yaml
# This has to be done after yq is installed
if [ "$(yq -r '.clouds.openstack.auth.application_credential_id' "$CLOUDS_FILE")" == "null" ]; then
    # Enforce the use of app creds
    echo "Error: An app cred clouds.yaml file is required in the $CLOUDS_FILE file, normal creds (i.e. those with passwords) are not supported"
    exit 1
fi

if [ "$(yq -r '.clouds.openstack.auth.project_id' "$CLOUDS_FILE")" == "null" ]; then
    echo "Looking up project_id for $CLOUDS_FILE..."
    APP_CRED_ID=$(yq -r '.clouds.openstack.auth.application_credential_id' "$CLOUDS_FILE")
    APP_CRED_SECRET=$(yq -r '.clouds.openstack.auth.application_credential_secret' "$CLOUDS_FILE")
    APP_CRED_AUTH_URL=$(yq -r '.clouds.openstack.auth.auth_url' "$CLOUDS_FILE")


    echo "${APP_CRED_ID}, ${APP_CRED_SECRET}"

    # specifying all this allows clouds.yaml to be outside scripts directory
    PROJECT_ID=$(openstack \
        --os-auth-url "${APP_CRED_AUTH_URL}" \
        --os-application-credential-id "${APP_CRED_ID}" \
        --os-application-credential-secret "${APP_CRED_SECRET}" \
        --os-auth-type v3applicationcredential\
         application credential show "${APP_CRED_ID}" -c project_id -f value
    )

    echo "Injecting project ID: '${PROJECT_ID}' into $CLOUDS_FILE..."
    injected_id=$PROJECT_ID yq e '.clouds.openstack.auth.project_id = env(injected_id)' -i "$CLOUDS_FILE"
fi