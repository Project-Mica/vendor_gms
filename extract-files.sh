#!/bin/bash
#
# SPDX-FileCopyrightText: 2016 The CyanogenMod Project
# SPDX-FileCopyrightText: 2017-2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=common
VENDOR=gms

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        -n | --no-cleanup)
            CLEAN_VENDOR=false
            ;;
        -k | --kang)
            KANG="--kang"
            ;;
        -s | --section)
            SECTION="${2}"
            shift
            CLEAN_VENDOR=false
            ;;
        *)
            SRC="${1}"
            ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function overlay_magic() {
    "${MY_DIR}/rro-utils/overlayMagic.sh" "$1" "$2" &
}

FWK_INSTALLED=0

overlay_install_fwk() {
    if [ "$FWK_INSTALLED" -eq 0 ]; then
        apktool if "${SRC}/system/framework/framework-res.apk"
        FWK_INSTALLED=1
    fi
}

function beautify_rro() {
    local overlay_dir="${MY_DIR}/common/proprietary/product/overlay"

    find "$overlay_dir" -mindepth 1 -maxdepth 1 -type d | xargs -P"$(nproc)" -I {} "${MY_DIR}/rro-utils/beautify_rro.sh" "{}" > /dev/null 2>&1

    find "$overlay_dir" -type d \( -name "values*" -o -name "mipmap*" -o -name "drawable*" -o -name "raw*" \) | while read -r sub_dir; do
        if [ -z "$(ls -A "$sub_dir")" ]; then
            rm -r "$sub_dir"
        fi
    done
}

function blob_fixup() {
    case "${1}" in
       product/overlay/*apk)
            [ "$2" = "" ] && return 0
            overlay_install_fwk
            overlay_magic "$1" "$2"
            ;;
        system/priv-app/GoogleExtServices/GoogleExtServices.apk)
            [ "$2" = "" ] && return 0
            touch "${2}"
            ;;
        *)
            return 1
            ;;
    esac

    return 0
}

function blob_fixup_dry() {
    blob_fixup "$1" ""
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"
extract "${MY_DIR}/proprietary-files_cellular.txt" "${SRC}" "${KANG}" --section "${SECTION}"

source_product_name=$(cat "${SRC}"/product/etc/build.prop | grep ro.product.product.name | sed 's|=| |' | awk '{print $2}')
source_build_id=$(cat "${SRC}"/product/etc/build.prop | grep ro.product.build.id | sed 's|=| |' | awk '{print $2}')
sed -i "s|# All unpinned files are extracted from.*|# All unpinned files are extracted from ${source_product_name} ${source_build_id}|" "${MY_DIR}/proprietary-files.txt"
sed -i "s|# All unpinned files are extracted from.*|# All unpinned files are extracted from ${source_product_name} ${source_build_id}|" "${MY_DIR}/proprietary-files_cellular.txt"

# Update google extension services
source "${MY_DIR}/extract-GoogleExtServices.sh"

"${MY_DIR}/setup-makefiles.sh"

echo "Waiting for extraction"
wait
echo "Beautifying rro's"
beautify_rro
echo "All done"

