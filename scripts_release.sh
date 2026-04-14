#!/bin/sh
set -eu

APP_NAME="LinkLight"
CONFIGURATION="release"
BUILD_DIR=".build/apple/Products/${CONFIGURATION}"
ARCHIVE_DIR="dist"

mkdir -p "$ARCHIVE_DIR"
swift build -c release
cp ".build/release/${APP_NAME}" "${ARCHIVE_DIR}/${APP_NAME}"

echo "Release artifact copied to ${ARCHIVE_DIR}/${APP_NAME}"
