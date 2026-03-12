# Building Bootloader and Firmware
1. Build the files
platformio run -e espwroom32
2. Merge the bootloader, partitions, and firmware together
`platformio run -e espwroom32 ; esptool.py --chip esp32 merge_bin -o combined-firmware.bin --flash_mode dio --flash_freq 40m --flash_size 4MB 0x1000 .pio/build/espwroom32/bootloader.bin 0x8000 .pio/build/espwroom32/partitions.bin 0x10000 .pio/build/espwroom32/mavesp-esp32dev-1.2.3.bin`

3. Building for the ESP32-S3 (ESP32-S3-MINI-1/1U) should include `boot_app0.bin` and use bootloader offset `0x0`:
`platformio run -e esp32-s3 ; esptool.py --chip esp32s3 merge_bin -o combined-firmware.bin --flash_mode dio --flash_freq 40m --flash_size 4MB 0x0 .pio/build/esp32-s3/bootloader.bin 0x8000 .pio/build/esp32-s3/partitions.bin 0xe000 ~/.platformio/packages/framework-arduinoespressif32/tools/partitions/boot_app0.bin 0x10000 .pio/build/esp32-s3/mavesp-esp32-s3-devkitc-1-1.2.3.bin`

Alternatively, use:
`./build_s3_combined.sh`

# Uploading Bootloader and Firmware
1. Get the usb connected port name
`python3 -m serial.tools.list_ports`
2. Upload the firmware using esptool.py at 0x0 - change the port
`esptool.py --chip esp32 --port /dev/cu.usbserial-2130 --baud 921600 write_flash 0x0 combined-firmware.bin`

# Uploading the firmware to the cloud for auto update.
1. Run the following command
darwincli firmware upload 3 combined-firmware.bin "Updated firmware including the bootloader"