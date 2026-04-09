#! /bin/bash
sudo apt-get update
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enabled apache2
echo "<h1>Ejecutando apache2</h1>" | sudo tee /var/www/html/index.html