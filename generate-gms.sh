#!/usr/bin/env bash
set -e

FILE_URL="https://dl.aswinaskurup.xyz/0:/Pixel-Dumps/mustang-BP4A.251205.006-dump.7z"

echo "[*] Downloading latest pixel Dump"
curl -L "$FILE_URL" -o "dump.7z"

echo "[*] Extracting..."
7z x "dump.7z" -o"pixel-dump" >/dev/null

echo "[*] Running extract-utils"
bash extract-files.sh "pixel-dump"

echo "[*] Cleaning up..."
rm "dump.7z"
rm -rf "pixel-dump"
# run git reset to ensure overlays arent modified
git reset --hard

echo "[+] Done Generating GMS you can build now"
