#!/bin/bash
# AIC8800 Kernel 6.18+ Patches Application Script
# This script applies all patches to the driver source tree

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATCHES_DIR="$SCRIPT_DIR/patches"

# Check if source directory was provided
if [ -z "$1" ]; then
    echo "Usage: $0 <driver-source-directory>"
    echo "Example: $0 ~/aic8800dc-linux-patched"
    exit 1
fi

SOURCE_DIR="$1"

# Verify source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "❌ Error: Source directory '$SOURCE_DIR' not found"
    exit 1
fi

# Verify it's the correct driver
if [ ! -d "$SOURCE_DIR/drivers/aic8800" ]; then
    echo "❌ Error: '$SOURCE_DIR' does not appear to be AIC8800 driver source"
    exit 1
fi

echo "🔧 Applying patches to: $SOURCE_DIR"
echo ""

# Apply patches in order
PATCH_COUNT=0
for patch_file in "$PATCHES_DIR"/*.patch; do
    if [ -f "$patch_file" ]; then
        PATCH_COUNT=$((PATCH_COUNT + 1))
        echo "📝 Applying: $(basename "$patch_file")"
        
        # Try to apply patch
        if patch -p1 -d "$SOURCE_DIR" < "$patch_file"; then
            echo "   ✅ Success"
        else
            echo "   ⚠️  Patch may already be applied or failed"
            read -p "   Continue anyway? (y/n) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        fi
        echo ""
    fi
done

if [ $PATCH_COUNT -eq 0 ]; then
    echo "❌ No patches found in $PATCHES_DIR"
    exit 1
fi

echo "✅ Applied $PATCH_COUNT patches successfully!"
echo ""
echo "Next steps:"
echo "1. cd $SOURCE_DIR"
echo "2. ./build.sh"
echo "3. sudo ./install.sh"
