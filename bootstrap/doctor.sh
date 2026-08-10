#!/usr/bin/env bash

# DEPRECATED: bootstrap/doctor.sh is preserved for backwards compatibility.
# Use 'devcompass doctor' instead.

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "⚠ DEPRECATION NOTICE: bootstrap/doctor.sh is deprecated."
echo "ℹ Redirecting to 'devcompass doctor'..."
echo

exec "${REPO_ROOT}/apps/cli/bin/devcompass" doctor "$@"