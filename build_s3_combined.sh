#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

ENV_NAME="esp32-s3"
BUILD_DIR=".pio/build/${ENV_NAME}"
OUT_FILE="combined-firmware.bin"
BOOT_APP0="${HOME}/.platformio/packages/framework-arduinoespressif32/tools/partitions/boot_app0.bin"

echo "Building PlatformIO env: ${ENV_NAME}"
platformio run -e "${ENV_NAME}"

if [[ ! -f "${BUILD_DIR}/bootloader.bin" ]]; then
  echo "Missing ${BUILD_DIR}/bootloader.bin" >&2
  exit 1
fi

if [[ ! -f "${BUILD_DIR}/partitions.bin" ]]; then
  echo "Missing ${BUILD_DIR}/partitions.bin" >&2
  exit 1
fi

if [[ ! -f "${BOOT_APP0}" ]]; then
  echo "Missing boot_app0.bin at ${BOOT_APP0}" >&2
  exit 1
fi

APP_BIN="$(ls -1 "${BUILD_DIR}"/mavesp-esp32-s3-*.bin | head -n 1)"
if [[ -z "${APP_BIN}" || ! -f "${APP_BIN}" ]]; then
  echo "Could not find app binary under ${BUILD_DIR}" >&2
  exit 1
fi

echo "Merging compact ESP32-S3 image to ${OUT_FILE}"
esptool.py --chip esp32s3 merge_bin \
  --flash_mode dio --flash_freq 40m --flash_size 8MB \
  -o "${OUT_FILE}" \
  0x0 "${BUILD_DIR}/bootloader.bin" \
  0x8000 "${BUILD_DIR}/partitions.bin" \
  0xe000 "${BOOT_APP0}" \
  0x10000 "${APP_BIN}"

ls -lh "${OUT_FILE}" "${APP_BIN}"
echo "Done. Flash ${OUT_FILE} at offset 0x0."
