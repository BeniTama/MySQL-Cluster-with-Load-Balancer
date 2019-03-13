# Download ProxySQL
cd /tmp
sudo curl -OL https://github.com/sysown/proxysql/releases/download/v1.4.4/proxysql_1.4.4-ubuntu16_amd64.deb

# Instalasi ProxySQL
sudo dpkg -i proxysql_*
sudo rm proxysql_*

# Install MySQL Client
sudo apt-get update
sudo apt-get install mysql-client

# Allow Port ProxySQL
sudo ufw allow 33061
sudo ufw allow 3306

# Allow Firewall
sudo ufw allow from 192.168.33.12
sudo ufw allow from 192.168.33.13
sudo ufw allow from 192.168.33.14

# Start ProxySQL
sudo systemctl enable proxysql
sudo systemctl start proxysql

