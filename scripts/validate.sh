#!/usr/bin/env bash
# ==============================================================================
# validate.sh: BlueBuild Recipe and Surface Pro 9 Staging Local Quality Gate
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSTATION_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "=== [Quality Gate] Validating Universal Blue Surface Pro 9 Staging Environment ==="
echo "Target Root: ${WORKSTATION_ROOT}"

# 1. Structural Verification
echo "--> Checking directory and recipe layout..."
if [[ ! -f "${WORKSTATION_ROOT}/recipes/recipe.yml" ]]; then
    echo "ERROR: Missing recipes/recipe.yml in ${WORKSTATION_ROOT}" >&2
    exit 1
fi

if [[ ! -f "${WORKSTATION_ROOT}/.github/workflows/build.yml" ]]; then
    echo "ERROR: Missing .github/workflows/build.yml in ${WORKSTATION_ROOT}" >&2
    exit 1
fi

if [[ ! -f "${WORKSTATION_ROOT}/cosign.pub" ]]; then
    echo "ERROR: Missing cosign.pub verification key in ${WORKSTATION_ROOT}" >&2
    exit 1
fi
echo "[OK] Required repository structure and cosign.pub present."

# 2. Secret Scanning (Zero-Leak Policy)
echo "--> Scanning for exposed credentials and private keys..."
FOUND_SECRETS=0
SECRET_PATTERN="---""--BEGIN"
if grep -rnEI --exclude="*.sh" "(${SECRET_PATTERN} (RSA|OPENSSH|EC|PGP|ENCRYPTED|PRIVATE) KEY-----|ghp_[A-Za-z0-9]{36}|AGE-SECRET-KEY-)" "${WORKSTATION_ROOT}" 2>/dev/null; then
    echo "ERROR: Potential unencrypted private key or secret token detected!" >&2
    FOUND_SECRETS=1
fi

if [[ ${FOUND_SECRETS} -ne 0 ]]; then
    echo "Validation failed: Aborting before git push." >&2
    exit 1
fi
echo "[OK] Secret scan clean. No sensitive credentials found."

# 3. Recipe Integrity & Deprecation Checks
echo "--> Validating recipe specifications..."
RECIPE_FILE="${WORKSTATION_ROOT}/recipes/recipe.yml"

# Check for obsolete or invalid module types
if grep -q "type:[[:space:]]*yum-repo" "${RECIPE_FILE}"; then
    echo "ERROR: 'type: yum-repo' is not a valid BlueBuild module! Use 'type: dnf' with 'repos.files'." >&2
    exit 1
fi

# Check for raw directory URLs in repo lists instead of .repo files
if grep -E "https?://[^ ]+/$" "${RECIPE_FILE}" | grep -q "location\|surfacelinux\|mullvad"; then
    echo "ERROR: Repository URL appears to point to an HTML index rather than a .repo file!" >&2
    exit 1
fi

IMAGE_NAME=$(grep -E "^name:" "${RECIPE_FILE}" | head -n1 | awk '{print $2}')
BASE_IMAGE=$(grep -E "^base-image:" "${RECIPE_FILE}" | head -n1 | awk '{print $2}')
IMAGE_VER=$(grep -E "^image-version:" "${RECIPE_FILE}" | head -n1 | awk '{print $2}')

echo "  - Target Image Name: ${IMAGE_NAME}"
echo "  - Base Image:        ${BASE_IMAGE}"
echo "  - Image Version:     ${IMAGE_VER}"

# 4. Surface Hardware Checklist (Surface Pro 9 Intel)
echo "--> Verifying Surface Pro 9 hardware integration assets..."
CALIB_FILE="${WORKSTATION_ROOT}/files/system/etc/iptsd.d/90-calibration.conf"
if [[ -f "${CALIB_FILE}" ]]; then
    echo "  - Found iptsd touch/stylus calibration file: ${CALIB_FILE}"
else
    echo "  - [Warning] Custom iptsd calibration not found in files/system/etc/iptsd.d/."
fi

# Verify kernel swap and services in recipe
if grep -q "kernel-surface" "${RECIPE_FILE}" && grep -q "iptsd" "${RECIPE_FILE}"; then
    echo "  - Surface kernel (kernel-surface) and digitizer daemon (iptsd) declared."
else
    echo "ERROR: Missing essential Surface hardware packages (kernel-surface / iptsd) in recipe.yml!" >&2
    exit 1
fi

echo "=== [Quality Gate Passed] Image recipe is verified and ready for CI/CD staging. ==="
