#!/usr/bin/env bash
# ==============================================================================
# install-python-libraries.sh: Base System Python Tooling for Health Automations
# ==============================================================================
set -oue pipefail

echo "=== [Python Libraries] Installing Health Automation Stack into Base Image ==="

# At this stage, python3-pip, gcc, python3-devel, and uv are installed via DNF.
# We install packages not provided as native RPMs (curl-cffi, garminconnect, python-docx)
# directly into /usr so they are sealed into the immutable ostree base image.

if command -v uv &>/dev/null; then
    echo "--> Installing system-wide packages using uv..."
    uv pip install --system \
        curl-cffi \
        garminconnect \
        python-docx
else
    echo "--> Installing system-wide packages using pip..."
    pip install --no-cache-dir --break-system-packages --prefix=/usr \
        curl-cffi \
        garminconnect \
        python-docx
fi

echo "--> Verifying base system imports..."
python3 -c "import docx, curl_cffi, garminconnect; print('[OK] All target Python libraries successfully verified in base system!')"

echo "=== [Python Libraries] Base System Installation Complete ==="
