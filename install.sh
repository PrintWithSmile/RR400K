sudo apt update && sudo apt install zip
_________________________________________________________________________________________________

cd /home/pi/
_________________________________________________________________________________________________

sudo git clone https://github.com/PrintWithSmile/RR400K.git
_________________________________________________________________________________________________

sudo nano /home/pi/RR400K/.git/hooks/post-merge

vložit

#!/bin/sh
rm /home/pi/update_conf.sh
cp -f /home/pi/RR400K/update.sh /home/pi/update_conf.sh
cd /home/pi/
chmod +x update_conf.sh 
./update_conf.sh
_________________________________________________________________________________________________
sudo chmod +x /home/pi/RR400K/.git/hooks/post-merge
_________________________________________________________________________________________________
sudo nano /home/pi/update_conf.sh

vložit

#update script ...
_________________________________________________________________________________________________
sudo chmod +x /home/pi/update_conf.sh
_________________________________________________________________________________________________
cd /home/pi/printer_data/config/
sudo mkdir /home/pi/printer_data/config/RR_config
sudo mkdir /home/pi/printer_data/config/Archive

sudo rm moonraker.conf
sudo rm crowsnest.conf
sudo rm printer.cfg

sudo cp /home/pi/RR400K/printer.cfg /home/pi/printer_data/config/
sudo cp /home/pi/RR400K/crowsnest.conf /home/pi/printer_data/config/
sudo cp /home/pi/RR400K/moonraker.conf /home/pi/printer_data/config/
sudo cp /home/pi/RR400K/Konfigurace/* /home/pi/printer_data/config/RR_config/

sudo chown -R pi:pi /home/pi/
sudo chown -R pi:pi /home/pi/printer_data/config
sudo service klipper restart
sudo service moonraker restart
_________________________________________________________________________________________________
