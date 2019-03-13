# Copy APT repositories
sudo cp '/vagrant/config/sources.list' '/etc/apt/sources.list'

# Update repositories
sudo apt-get update -y

# Download and Install MySQL Cluster
cd ~
wget https://dev.mysql.com/get/Downloads/MySQL-Cluster-7.6/mysql-cluster-community-management-server_7.6.6-1ubuntu18.04_amd64.deb
sudo dpkg -i mysql-cluster-community-management-server_7.6.6-1ubuntu18.04_amd64.deb

# Create Folder MySQL Cluster
sudo mkdir /var/lib/mysql-cluster

# Copy Edited Configuration Files
sudo cp '/vagrant/config/clusterdb1/config.ini' '/var/lib/mysql-cluster/config.ini'

# Start Manager
sudo ndb_mgmd -f /var/lib/mysql-cluster/config.ini

# Kill Running Server
sudo pkill -f ndb_mgmd

# Copy edited Systemd unit file
sudo cp '/vagrant/config/clusterdb1/ndb_mgmd.service' '/etc/systemd/system/ndb_mgmd.service'

# Reload systemd's manager configuration
sudo systemctl daemon-reload

# Enable Service
sudo systemctl enable ndb_mgmd

# Start Service
sudo systemctl start ndb_mgmd

# Allow Local Incoming Connections
sudo ufw allow from 192.168.33.12
sudo ufw allow from 192.168.33.13
