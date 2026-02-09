#!/usr/bin/env bash
set -euo pipefail

echo ""
echo "=============================================================================="
echo "Downloading latest scripts from cloud-capi-values: https://github.com/stfc/cloud-capi-values.git" 
echo "=============================================================================="


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd $SCRIPT_DIR

SOURCE_URL="https://raw.githubusercontent.com/stfc/cloud-capi-values/refs/heads/master"

# Download from cloud-capi-values
curl -o "${SCRIPT_DIR}/dependencies.yaml" "${SOURCE_URL}/dependencies.yaml"
curl -o "${SCRIPT_DIR}/set-env.sh" "${SOURCE_URL}/set-env.sh"
curl -o "${SCRIPT_DIR}/bootstrap.sh" "${SOURCE_URL}/bootstrap.sh"

echo ""
echo "=============================================================================="
echo "You are now ready to create a cluster following the instructions..."
echo "See README.md - https://github.com/stfc/cloud-helm-charts/tree/main/charts/stfc-cloud-openstack-cluster/README.md"
echo "=============================================================================="
