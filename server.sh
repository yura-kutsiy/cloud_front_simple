#!/bin/bash
echo "---------------START---------------"
sudo -- sh -c "apt update && apt upgrade"
sudo apt-get install -y nginx
echo "<html><body bgcolor=#006994><center><h2><p><font color=#C0C0C0>Build by Terraform!</h2></center></body></html>"  >  /var/www/html/index.html
sudo systemctl enable nginx
sudo systemctl start nginx
echo "---------------FINISH---------------"
