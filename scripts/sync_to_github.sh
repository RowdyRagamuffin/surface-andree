#!/usr/bin/env bash
# ==============================================================================
# sync_to_github.sh: Atomic Git Sync Pipeline for surface-andree
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSTATION_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# 1. Execute local quality gate
bash "${SCRIPT_DIR}/validate.sh"

echo "=== [Sync Pipeline] Synchronizing to GitHub (surface-andree) ==="

cd "${WORKSTATION_ROOT}"

# Ensure this directory is a git repository
if [[ ! -d ".git" ]]; then
    echo "ERROR: ${WORKSTATION_ROOT} is not a git repository!" >&2
    exit 1
fi

# Verify remote configuration
if ! git remote get-url origin >/dev/null 2>&1; then
    echo "ERROR: Git remote 'origin' is not configured in ${WORKSTATION_ROOT}!" >&2
    exit 1
fi

TARGET_REMOTE_URL=$(git remote get-url origin)
echo "Target Remote: ${TARGET_REMOTE_URL}"

# Configure git user if unset
if [[ -z "$(git config user.name || true)" ]]; then
    git config user.name "Steven Andree"
fi
if [[ -z "$(git config user.email || true)" ]]; then
    git config user.email "stevenandree@outlook.com"
fi

# Stage all changes
git add -A

# Check if there are changes to commit
if git diff --cached --quiet; then
    echo "No local changes detected to commit. Staging tree is clean."
else
    COMMIT_MSG="${1:-feat(surface): integrate linux-surface kernel, iptsd calibration, and cosign signing}"
    echo "Committing staged changes: '${COMMIT_MSG}'..."
    git commit -m "${COMMIT_MSG}"
fi

# Push to target GitHub repository
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "Pushing branch '${CURRENT_BRANCH}' to origin..."
git push origin "${CURRENT_BRANCH}"

echo "=== [Sync Pipeline] Successfully synchronized to GitHub! ==="
