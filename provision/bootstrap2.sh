# Copy APT repositories
sudo cp '/vagrant/config/sources.list' '/etc/apt/sources.list'

# Update repositories
sudo apt-get update -y

# Install Perl Dependency
sudo apt install libclass-methodmaker-perl

# Download Deb File
cd ~
wget https://dev.mysql.com/get/Downloads/MySQL-Cluster-7.6/mysql-cluster-community-data-node_7.6.6-1ubuntu18.04_amd64.deb

# Install Data Node Binary
sudo dpkg -i mysql-cluster-community-data-node_7.6.6-1ubuntu18.04_amd64.deb

# Copy edited onfiguration files
sudo cp '/vagrant/config/clusterdb2/my.cnf' '/etc/my.cnf'

# Create data directory
sudo mkdir -p /usr/local/mysql/data

# Start data node
sudo ndbd

# Allow incoming connections from cluster manager
sudo ufw allow from 192.168.33.11
sudo ufw allow from 192.168.33.13
sudo ufw allow from 192.168.33.14

# Kill the running ndbd process
sudo pkill -f ndbd

# Copy edited systemd unit files
sudo cp '/vagrant/config/clusterdb2/ndbd.service' '/etc/systemd/system/ndbd.service'

# Reload systemd's manager configuration
sudo systemctl daemon-reload

# Enable the service
sudo systemctl enable ndbd

# Start the service
sudo systemctl start ndbd

# Download mysql cluster files
cd ~
sudo curl -OL https://dev.mysql.com/get/Downloads/MySQL-Cluster-7.6/mysql-cluster_7.6.9-1ubuntu18.04_amd64.deb-bundle.tar

# Extract into an install directory
sudo mkdir install
sudo tar -xvf mysql-cluster_7.6.9-1ubuntu18.04_amd64.deb-bundle.tar -C install/
cd install

# Install MySQL Server Dependencies
sudo apt update
sudo apt install libaio1 libmecab2
sudo dpkg -i '/home/vagrant/install/mysql-common_7.6.9-1ubuntu18.04_amd64.deb'
sudo dpkg -i '/home/vagrant/install/mysql-cluster-community-client_7.6.9-1ubuntu18.04_amd64.deb'
sudo dpkg -i '/home/vagrant/install/mysql-client_7.6.9-1ubuntu18.04_amd64.deb'
