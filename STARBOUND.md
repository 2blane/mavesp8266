# Building Bootloader and Firmware
1. Build the files
platformio run -e esp32-wroom
2. Merge the bootloader, partitions, and firmware together
`esptool.py --chip esp32 merge_bin -o combined-firmware.bin --flash_mode dio --flash_freq 40m --flash_size 4MB 0x1000 .pio/build/espwroom32/bootloader.bin 0x8000 .pio/build/espwroom32/partitions.bin 0x10000 .pio/build/espwroom32/mavesp-esp32dev-1.2.3.bin`

# Uploading Bootloader and Firmware
1. Get the usb connected port name
`python3 -m serial.tools.list_ports`
2. Upload the firmware using esptool.py at 0x0 - change the port
`esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 921600 write_flash 0x0 combined-firmware.bin`