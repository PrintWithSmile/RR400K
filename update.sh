#!/bin/bash

FILE_PATH="/var/lib/pws/mountflash"

FILE_PATH2="/etc/udev/rules.d/10-flash.rules"

OLD_SCRIPT="#!/bin/bash
if [ -b "/dev/usbmemorystick" ]
then
        mkdir /media/gcodes
        chmod 777 /media/gcodes
        chown pi /media/gcodes
        mount -o uid=pi /dev/usbmemorystick /media/gcodes
		mv /home/pi/printer_data/gcodes /home/pi/printer_data/gcodes2
		ln -s /media/gcodes /home/pi/printer_data/gcodes
			
fi"

OLD_SCRIPT2="KERNEL=="sda1", SUBSYSTEMS=="usb", ACTION=="add", RUN+="/var/lib/pws/mountflash", SYMLINK+="usbmemorystick"
KERNEL=="sda1", SUBSYSTEMS=="usb", ACTION=="remove", RUN+="/var/lib/pws/unmountflash""

NEW_SCRIPT="#!/bin/bash

FLASH_DISK=\"/media/wifi\"
INI_FILE=\"\$FLASH_DISK/prusa_printer_settings.ini\"
INI_FILE_2=\"\$FLASH_DISK/wifi-OK.ini\"
INI_FILE_3=\"\$FLASH_DISK/wifi-NOK.ini\"

function cleanup {
    umount \"\$FLASH_DISK\"
    rm -r \"\$FLASH_DISK\"
}

function wifi_success {
    echo WIFI_OK > /home/pi/printer_data/comms/klippy.serial
}

function wifi_failure {
    echo WIFI_NOK > /home/pi/printer_data/comms/klippy.serial
    cleanup
    exit 1
}

if [ -d \"\$FLASH_DISK\" ]; then
    echo \"Unmounting and deleting existing \$FLASH_DISK...\"

    if mountpoint -q \"\$FLASH_DISK\"; then
        umount \"\$FLASH_DISK\"
    fi

    rm -r \"\$FLASH_DISK\"
fi

if [ -b \"/dev/usbflash\" ]; then
    mkdir -p \"\$FLASH_DISK\"
    chown pi \"\$FLASH_DISK\"
    chmod 777 \"\$FLASH_DISK\"
    mount -o uid=pi /dev/usbflash \"\$FLASH_DISK\"

    if [ -f \"\$INI_FILE\" ]; then
        echo M300 S200 P50 > /home/pi/printer_data/comms/klippy.serial
        SSID=\$(awk -F= '/^\[wifi\]/{flag=1; next} /^\[/{flag=0} flag && /ssid/{print \$2}' \"\$INI_FILE\" | tr -d '[:space:]')
        PSK=\$(awk -F= '/^\[wifi\]/{flag=1; next} /^\[/{flag=0} flag && /psk/{print \$2}' \"\$INI_FILE\" | tr -d '[:space:]')

        if [ -z \"\$SSID\" ] || [ -z \"\$PSK\" ]; then
            echo \"Error: SSID or PSK not found in \$INI_FILE.\"
            cleanup
            exit 1
        fi

        wifi_list=\$(nmcli -t -f SSID,FREQ dev wifi list)

        count=\$(echo \"\$wifi_list\" | grep -c \"^\$SSID\")

        if [ \"\$count\" -gt 1 ]; then
            echo \"Multiple networks with SSID \$SSID found. Choosing 2.4 GHz network.\"

            nmcli dev wifi connect \"\$SSID\" password \"\$PSK\"

            iw dev wlan0 set freq 2412
        else
            nmcli dev wifi connect \"\$SSID\" password \"\$PSK\"
        fi

        sleep 5

        active_connections=\$(nmcli connection show --active)

        if echo \"\$active_connections\" | grep -q \"\$SSID\"; then
            echo \"Successfully connected to \$SSID.\"
            mv \"\$INI_FILE\" \"\$INI_FILE_2\"
            wifi_success
        else
            echo \"Failed to connect to \$SSID.\"
            mv \"\$INI_FILE\" \"\$INI_FILE_3\"
            wifi_failure
        fi
    else
        echo \"Error: Configuration file \$INI_FILE not found.\"
        cleanup
        exit 1
    fi
else
    echo \"Error: USB flash drive not detected.\"
    cleanup
    exit 1
fi

cleanup
echo \"Script completed successfully.\"
"

NEW_SCRIPT2='KERNEL=="sda1", SUBSYSTEMS=="usb", ACTION=="add", RUN+="/var/lib/pws/mountflash", SYMLINK+="usbflash"'

if ! command -v zip &> /dev/null; then
    sudo apt-get update
    sudo apt-get install zip -y

    if [ $? -eq 0 ]; then
        echo "ZIP utility installed successfully."
    else
        echo "Failed to install ZIP utility."
        exit 1
    fi
fi


slozka="/home/pi/Klipper_IP"

if [ ! -d "$slozka" ]; then
    git clone https://github.com/PrintWithSmile/Klipper_IP.git
	cd Klipper_IP
	chmod +x install.sh
	./install.sh
fi

if [ -e "$FILE_PATH" ]; then
    if [ "$(cat "$FILE_PATH")" = "$OLD_SCRIPT" ]; then
		echo -e "orangepi1234\n$NEW_SCRIPT" | sudo -S tee "$FILE_PATH" > /dev/null
        echo -e "orangepi1234\n" | sudo -S chmod 755 "$FILE_PATH"
        echo "Content replaced successfully."
    else
		echo -e "orangepi1234\n$NEW_SCRIPT" | sudo -S tee "$FILE_PATH" > /dev/null
        echo -e "orangepi1234\n" | sudo -S chmod 755 "$FILE_PATH"
        echo "Content replaced successfully."
    fi
fi
 
if [ -e "$FILE_PATH2" ]; then
    if [ "$(cat "$FILE_PATH2")" = "$OLD_SCRIPT2" ]; then
        echo -e "orangepi1234\n" | sudo -S sh -c 'echo -n > "$FILE_PATH2"'
		echo -e "orangepi1234" | sudo -S sh -c "echo '$NEW_SCRIPT2' > '$FILE_PATH2'"
		echo -e "orangepi1234\n" | sudo -S rm /var/lib/pws/unmountflash
		echo -e "orangepi1234\n" | sudo -S systemctl daemon-reload
		echo -e "orangepi1234\n" | sudo -S systemctl restart systemd-udevd
    else
		echo -e "orangepi1234\n" | sudo -S sh -c 'echo -n > "$FILE_PATH2"'
		echo -e "orangepi1234" | sudo -S sh -c "echo '$NEW_SCRIPT2' > '$FILE_PATH2'"
		echo -e "orangepi1234\n" | sudo -S rm /var/lib/pws/unmountflash
		echo -e "orangepi1234\n" | sudo -S systemctl daemon-reload
		echo -e "orangepi1234\n" | sudo -S systemctl restart systemd-udevd
    fi
fi

if ! command -v zip &> /dev/null; then
    sudo apt-get update
    sudo apt-get install zip -y

    if [ $? -eq 0 ]; then
        echo "ZIP utility installed successfully."
    else
        echo "Failed to install ZIP utility."
        exit 1
    fi
fi

slozka="/home/pi/Klipper_IP"

if [ ! -d "$slozka" ]; then
    git clone https://github.com/PrintWithSmile/Klipper_IP.git
	cd Klipper_IP
	chmod +x install.sh
	./install.sh
fi

echo "Zálohuji předchozí konfigurace"

cd /home/pi/printer_data/config

zip -r "zaloha_$(date +"%d-%m-%Y").zip" /home/pi/printer_data/config/* -x "/home/pi/printer_data/config/Archive/*" -x "/home/pi/printer_data/config/Archive"

mv "zaloha_$(date +"%d-%m-%Y").zip" /home/pi/printer_data/config/Archive

cp -f /home/pi/RR400K/Konfigurace/* /home/pi/printer_data/config/RR_config/

echo "Restartuji klipper pro načtení nových konfigurací"

service klipper restart

echo "Update hotový"
