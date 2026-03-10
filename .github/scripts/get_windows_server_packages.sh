#!/bin/bash
set -e

VERSION="${VERSION}"
BUILD="${BUILD}"
BASE_URL="${PACKAGE_URL}/server/win/inno"

echo "Checking Windows Server packages for version ${VERSION}.${BUILD}..."

EDITIONS=()

# Check Community Edition (no suffix)
CE_URL="${BASE_URL}/ONLYOFFICE-DocumentServer-${VERSION}.${BUILD}-x64.exe"
if curl --output /dev/null --silent --head --fail "${CE_URL}"; then
    echo "✓ Community Edition found: ${CE_URL}"
    EDITIONS+=("community")
else
    echo "✗ Community Edition not found: ${CE_URL}"
fi

# Check Developer Edition (-DE suffix)
DE_URL="${BASE_URL}/ONLYOFFICE-DocumentServer-DE-${VERSION}.${BUILD}-x64.exe"
if curl --output /dev/null --silent --head --fail "${DE_URL}"; then
    echo "✓ Developer Edition found: ${DE_URL}"
    EDITIONS+=("developer")
else
    echo "✗ Developer Edition not found: ${DE_URL}"
fi

# Check Enterprise Edition (-EE suffix)
EE_URL="${BASE_URL}/ONLYOFFICE-DocumentServer-EE-${VERSION}.${BUILD}-x64.exe"
if curl --output /dev/null --silent --head --fail "${EE_URL}"; then
    echo "✓ Enterprise Edition found: ${EE_URL}"
    EDITIONS+=("enterprise")
else
    echo "✗ Enterprise Edition not found: ${EE_URL}"
fi

if [ ${#EDITIONS[@]} -eq 0 ]; then
    echo "ERROR: No Windows Server packages found!"
    echo "windows-server-packages=" >> $GITHUB_OUTPUT
else
    echo "Found ${#EDITIONS[@]} edition(s): ${EDITIONS[*]}"
    MATRIX_JSON=$(jq -n -c --arg s "${EDITIONS[*]}" '($s|split(" "))')
    echo "windows-server-packages=${MATRIX_JSON}" >> $GITHUB_OUTPUT
    echo "Matrix: ${MATRIX_JSON}"
fi
