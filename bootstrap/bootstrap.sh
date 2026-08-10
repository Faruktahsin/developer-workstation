#!/usr/bin/env bash

# DEPRECATED: bootstrap.sh is preserved for backwards compatibility.
# Use 'devcompass init' instead.

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "⚠ DEPRECATION NOTICE: bootstrap/bootstrap.sh is deprecated."
echo "ℹ Redirecting to 'devcompass init'..."
echo

exec "${REPO_ROOT}/apps/cli/bin/devcompass" init "$@"