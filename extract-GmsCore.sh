#!/bin/bash
set -e  # Exit on errors

# Source directory (root of your product/priv-app tree)
SRC_DIR="$1"
DST_DIR="GmsCore"

if [ -z "$SRC_DIR" ]; then
    echo "Usage: $0 <source_directory>"
    exit 1
fi

# List of APKs relative to the source directory
FILES=(
"product/priv-app/PrebuiltGmsCore/app_chimera/m/PrebuiltGmsCoreVic_AdsDynamite/PrebuiltGmsCoreVic_AdsDynamite.apk"
"product/priv-app/PrebuiltGmsCore/app_chimera/m/PrebuiltGmsCoreVic_CronetDynamite/PrebuiltGmsCoreVic_CronetDynamite.apk"
"product/priv-app/PrebuiltGmsCore/app_chimera/m/PrebuiltGmsCoreVic_DynamiteLoader/PrebuiltGmsCoreVic_DynamiteLoader.apk"
"product/priv-app/PrebuiltGmsCore/app_chimera/m/PrebuiltGmsCoreVic_DynamiteModulesA/PrebuiltGmsCoreVic_DynamiteModulesA.apk"
"product/priv-app/PrebuiltGmsCore/app_chimera/m/PrebuiltGmsCoreVic_DynamiteModulesC/PrebuiltGmsCoreVic_DynamiteModulesC.apk"
"product/priv-app/PrebuiltGmsCore/app_chimera/m/PrebuiltGmsCoreVic_GoogleCertificates/PrebuiltGmsCoreVic_GoogleCertificates.apk"
"product/priv-app/PrebuiltGmsCore/app_chimera/m/PrebuiltGmsCoreVic_MapsDynamite/PrebuiltGmsCoreVic_MapsDynamite.apk"
"product/priv-app/PrebuiltGmsCore/app_chimera/m/PrebuiltGmsCoreVic_MeasurementDynamite/PrebuiltGmsCoreVic_MeasurementDynamite.apk"
"product/priv-app/PrebuiltGmsCore/m/independent/AndroidPlatformServices/AndroidPlatformServices.apk"
"product/priv-app/PrebuiltGmsCore/m/optional/MlkitBarcodeUIPrebuilt/MlkitBarcodeUIPrebuilt.apk"
"product/priv-app/PrebuiltGmsCore/m/optional/TfliteDynamitePrebuilt/TfliteDynamitePrebuilt.apk"
"product/priv-app/PrebuiltGmsCore/m/optional/VisionBarcodePrebuilt/VisionBarcodePrebuilt.apk"
"product/priv-app/PrebuiltGmsCoreVic/PrebuiltGmsCoreVic.apk"
)

for FILE in "${FILES[@]}"; do
    SRC_FILE="$SRC_DIR/$FILE"

    if [[ ! -f "$SRC_FILE" ]]; then
        echo "Warning: $SRC_FILE not found, skipping."
        continue
    fi

    # Determine relative path for destination
    if [[ "$FILE" == *"PrebuiltGmsCore/"* ]]; then
        REL_PATH=$(echo "$FILE" | sed 's|.*PrebuiltGmsCore/||')
    else
        # Standalone APKs go directly under DST_DIR
        REL_PATH=$(basename "$FILE")
    fi

    # Create destination directory
    mkdir -p "$DST_DIR/$(dirname "$REL_PATH")"

    # Copy
    cp "$SRC_FILE" "$DST_DIR/$REL_PATH"
    echo "Copied $SRC_FILE -> $DST_DIR/$REL_PATH"
done
