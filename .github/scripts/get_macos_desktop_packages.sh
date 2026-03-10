#!/bin/bash
set -e

VERSION="${VERSION}"
BUILD="${BUILD}"
BASE_URL="${PACKAGE_URL}/desktop/mac"

echo "Checking macOS Desktop packages for version ${VERSION}/${BUILD}..."

MATRIX_ITEMS=()

# Function to check if package exists
check_package() {
    local url=$1
    if curl --output /dev/null --silent --head --fail "${url}"; then
        return 0
    else
        return 1
    fi
}

# Function to check architecture type
check_architecture() {
    local arch=$1
    local path=$2
    
    echo "Checking ${arch} packages..."
    
    local editions=()
    
    # Community (no prefix)
    local ce_file="ONLYOFFICE-${arch}-${VERSION}-${BUILD}.dmg"
    local ce_url="${BASE_URL}/${path}/${ce_file}"
    
    if check_package "${ce_url}"; then
        editions+=("community")
        echo "  ✓ Community edition found: ${ce_url}"
    else
        echo "  ✗ Community edition not found: ${ce_url}"
    fi
    
    # Enterprise (Enterprise- prefix)
    local ee_file="ONLYOFFICE-Enterprise-${arch}-${VERSION}-${BUILD}.dmg"
    local ee_url="${BASE_URL}/${path}/${ee_file}"
    
    if check_package "${ee_url}"; then
        editions+=("enterprise")
        echo "  ✓ Enterprise edition found: ${ee_url}"
    else
        echo "  ✗ Enterprise edition not found: ${ee_url}"
    fi
    
    # If editions found, add each combination to matrix
    if [ ${#editions[@]} -gt 0 ]; then
        for edition in "${editions[@]}"; do
            local matrix_entry="{\"architecture\":\"${arch}\",\"edition\":\"${edition}\"}"
            MATRIX_ITEMS+=("${matrix_entry}")
            echo "  Matrix entry: ${matrix_entry}"
        done
    else
        echo "  ✗ No editions found for ${arch}"
    fi
}

# Check ARM architecture
check_architecture "arm" "arm/${VERSION}/${BUILD}"

# Check x86_64 architecture
check_architecture "x86_64" "x86_64/${VERSION}/${BUILD}"

# Check v8 (special case - only community, different naming)
echo "Checking v8 packages..."
V8_FILE="ONLYOFFICE-v8-${VERSION}-${BUILD}.dmg"
V8_URL="${BASE_URL}/v8/${VERSION}/${BUILD}/${V8_FILE}"

if check_package "${V8_URL}"; then
    echo "  ✓ V8 edition found: ${V8_URL}"
    v8_entry='{"architecture":"v8","edition":"community"}'
    MATRIX_ITEMS+=("${v8_entry}")
    echo "  Matrix entry: ${v8_entry}"
else
    echo "  ✗ V8 edition not found: ${V8_URL}"
fi

# Build final matrix JSON
if [ ${#MATRIX_ITEMS[@]} -eq 0 ]; then
    echo "ERROR: No macOS Desktop packages found!"
    echo "macos-desktop-packages=" >> $GITHUB_OUTPUT
else
    echo "Found ${#MATRIX_ITEMS[@]} architecture(s)"
    MATRIX_JSON=$(printf '%s\n' "${MATRIX_ITEMS[@]}" | jq -s -c .)
    echo "macos-desktop-packages=${MATRIX_JSON}" >> $GITHUB_OUTPUT
    echo "Final Matrix: ${MATRIX_JSON}"
fi
