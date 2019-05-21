# Implementasi MySQL Cluster

## Daftar Isi
1. [Model Arsitektur](#1-model-arsitektur)
2. [Konfigurasi Vagrantfile](#2-konfigurasi-vagrantfile)
3. [Instalasi](#3-instalasi)

## 1. Model Arsitektur
Pada tugas implementasi ini, akan digunakan 4 buah server node. Satu server node akan menjadi node balancer. Informasi detil mengenai server node yang digunakan akan dijelaskan pada tabel dibawah:

| No | Alamat | Nama Node | Peran |
| --- | --- | --- | --- |
| 1 | 192.168.33.11 | clusterdb1 | Node Manager |
| 2 | 192.168.33.12 | clusterdb2 | Server 1 dan Node 1 |
| 3 | 192.168.33.13 | clusterdb3 | Server 2 dan Node 2 |
| 4 | 192.168.33.14 | clusterdb4 | Load Balancer (ProxySQL) |

## 2. Konfigurasi Vagrantfile
Berikut adalah isi dari vagrantfile:
```
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

(1..4).each do |i|
  config.vm.define "clusterdb#{i}" do |node|
    node.vm.box = "bento/ubuntu-18.04"
    node.vm.hostname = "clusterdb#{i}"
    node.vm.network "private_network", ip: "192.168.33.1#{i}"

    node.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.name = "clusterdb#{i}"
      vb.memory = "1024"
    end
	
    node.vm.provision "shell", path: "provision/dbcluster#{i}.sh", privileged: false
    end
  end
end
```

Kemudian berikut isi dari masing-masing file provision:

Provision clusterdb1:
```
# Update repositories
sudo apt-get update

# Copy MySQL Cluster Manager
sudo cp '/vagrant/install/mysql-cluster-community-management-server_7.6.9-1ubuntu18.04_amd64.deb' '/home/vagrant/mysql-cluster-community-management-server_7.6.9-1ubuntu18.04_amd64.deb'

# Install MySQL Cluster
sudo dpkg -i mysql-cluster-community-management-server_7.6.9-1ubuntu18.04_amd64.deb

# Create Folder MySQL Cluster
sudo mkdir /var/lib/mysql-cluster

# Copy Config MySQL Cluster
sudo cp '/vagrant/files/clusterdb1/config.ini' '/var/lib/mysql-cluster/config.ini'

# Starting Manager
sudo ndb_mgmd -f /var/lib/mysql-cluster/config.ini

# Kill Service
sudo pkill -f ndb_mgmd

# Copy Service Configuration
sudo cp '/vagrant/files/clusterdb1/ndb_mgmd.service' '/etc/systemd/system/ndb_mgmd.service'

# Reload Service
sudo systemctl daemon-reload

# Enable Startup Manager
sudo systemctl enable ndb_mgmd

# Starting Service
sudo systemctl start ndb_mgmd

# Allow Firewall
sudo ufw allow from 192.168.33.12

sudo ufw allow from 192.168.33.13
```

Provision clusterdb2:
```
# Update repositories
sudo apt-get update

# Install Libraries Perl
sudo apt-get install libclass-methodmaker-perl libaio1 libmecab2

# Copy MySQL Data Node
sudo cp '/vagrant/install/mysql-cluster-community-data-node_7.6.9-1ubuntu18.04_amd64.deb' '/home/vagrant/mysql-cluster-community-data-node_7.6.9-1ubuntu18.04_amd64.deb'

# Install MySQL Data Node
sudo dpkg -i '/home/vagrant/mysql-cluster-community-data-node_7.6.9-1ubuntu18.04_amd64.deb'

# Copy MySQL Data Node Configuration
sudo cp '/vagrant/files/clusterdb2/my.cnf' '/etc/my.cnf'

# Create Folder Data Node
sudo mkdir -p /usr/local/mysql/data

# Starting Node
sudo ndbd

# Allow Firewall
sudo ufw allow from 192.168.33.11

sudo ufw allow from 192.168.33.13

sudo ufw allow from 192.168.33.14

# Kill Service Data Node
sudo pkill -f ndbd

# Copy Configuration Service Data Node
sudo cp '/vagrant/files/clusterdb2/ndbd.service' '/etc/systemd/system/ndbd.service'

# Reload Service
sudo systemctl daemon-reload

# Enable Startup Data Node Service
sudo systemctl enable ndbd

# Starting Data Node Service
sudo systemctl start ndbd

# Installation MySQL API
# Get Download Files MySQL Server
sudo curl -OL https://dev.mysql.com/get/Downloads/MySQL-Cluster-7.6/mysql-cluster_7.6.9-1ubuntu18.04_amd64.deb-bundle.tar

# Create MySQL Server Installation Folder
sudo mkdir install

# Untar MySQL Requirements
sudo tar -xvf mysql-cluster_7.6.9-1ubuntu18.04_amd64.deb-bundle.tar -C install/

# Install MySQL Common
sudo dpkg -i '/home/vagrant/install/mysql-common_7.6.9-1ubuntu18.04_amd64.deb'

# Install MySQL Cluster Client
sudo dpkg -i '/home/vagrant/install/mysql-cluster-community-client_7.6.9-1ubuntu18.04_amd64.deb'

# Install MySQL Client
sudo dpkg -i '/home/vagrant/install/mysql-client_7.6.9-1ubuntu18.04_amd64.deb'
```

Provision clusterdb3:
```
# Update repositories
sudo apt-get update

# Install Libraries Perl
sudo apt-get install libclass-methodmaker-perl libaio1 libmecab2

# Copy MySQL Data Node
sudo cp '/vagrant/install/mysql-cluster-community-data-node_7.6.9-1ubuntu18.04_amd64.deb' '/home/vagrant/mysql-cluster-community-data-node_7.6.9-1ubuntu18.04_amd64.deb'

# Install MySQL Data Node
sudo dpkg -i '/home/vagrant/mysql-cluster-community-data-node_7.6.9-1ubuntu18.04_amd64.deb'

# Copy MySQL Data Node Configuration
sudo cp '/vagrant/files/clusterdb3/my.cnf' '/etc/my.cnf'

# Create Folder Data Node
sudo mkdir -p /usr/local/mysql/data

# Starting Node
sudo ndbd

# Allow Firewall
sudo ufw allow from 192.168.33.11

sudo ufw allow from 192.168.33.12

sudo ufw allow from 192.168.33.14

# Kill Service Data Node
sudo pkill -f ndbd

# Copy Configuration Service Data Node
sudo cp '/vagrant/files/clusterdb3/ndbd.service' '/etc/systemd/system/ndbd.service'

# Reload Service
sudo systemctl daemon-reload

# Enable Startup Data Node Service
sudo systemctl enable ndbd

# Starting Data Node Service
sudo systemctl start ndbd

# Installation MySQL API
# Get Download Files MySQL Server
sudo curl -OL https://dev.mysql.com/get/Downloads/MySQL-Cluster-7.6/mysql-cluster_7.6.9-1ubuntu18.04_amd64.deb-bundle.tar

# Create MySQL Server Installation Folder
sudo mkdir install

# Untar MySQL Requirements
sudo tar -xvf mysql-cluster_7.6.9-1ubuntu18.04_amd64.deb-bundle.tar -C install/

# Install MySQL Common
sudo dpkg -i '/home/vagrant/install/mysql-common_7.6.9-1ubuntu18.04_amd64.deb'

# Install MySQL Cluster Client
sudo dpkg -i '/home/vagrant/install/mysql-cluster-community-client_7.6.9-1ubuntu18.04_amd64.deb'

# Install MySQL Client
sudo dpkg -i '/home/vagrant/install/mysql-client_7.6.9-1ubuntu18.04_amd64.deb'
```

Provision clusterdb4:
```
# Install Proxy
sudo apt-get update

sudo cd /tmp

sudo curl -OL https://github.com/sysown/proxysql/releases/download/v2.0.2/proxysql_2.0.2-dbg-ubuntu18_amd64.deb

sudo dpkg -i proxysql_*

sudo rm proxysql_*

# Install MySQL Client
sudo apt-get install mysql-client -y

# Allow Port Proxy
sudo ufw allow 33061

sudo ufw allow 3306

# Allow Firewall
sudo ufw allow from 192.168.33.12

sudo ufw allow from 192.168.33.13

sudo ufw allow from 192.168.33.14

# Enable and Start Service
sudo systemctl enable proxysql

sudo systemctl start proxysql
```

## 3. Instalasi
Setelah vagrant up berhasil dijalankan, masuk kedalam node ``clusterdb2`` dan ``clusterdb3`` dan lakukan perintah berikut:
```
# Install MySQL Server
sudo dpkg -i '/home/vagrant/install/mysql-cluster-community-server_7.6.9-1ubuntu18.04_amd64.deb'

# Copy Configuration MySQL Server
sudo cp '/vagrant/files/clusterdb2/mysql/my.cnf' '/etc/mysql/my.cnf'

# Restarting MySQL Service
sudo systemctl restart mysql

# Enable Startup MySQL Service
sudo systemctl enable mysql
```
Perintah berikut akan membuat kedua node menginstall MySQL Server, dan memperbolehkan pengguna untuk mengatur password root yang akan digunakan.

Kemudian lakukan perintah berikut pada ``clusterdb2`` atau ``clusterdb3``
```
sudo mysql -u root -p < /vagrant/mysql-dump/mysqlsampledatabase.sql
```
Perintah berikut akan melakukan import sample database MySQL yang akan digunakan untuk ujicoba replikasi.

Setelah melakukan perintah diatas, jalankan perintah berikut pada ``clusterdb4``:
```
sudo mysql -u admin -p -h 127.0.0.1 -P 6032 --prompt='ProxySQLAdmin> ' < /vagrant/mysql-dump/proxy_config.sql
```

Dan lakukan perintah berikut pada ``clusterdb2`` dan ``clusterdb3``
```
# Mengunduh addition_to_sys.sql
curl -OL https://gist.github.com/lefred/77ddbde301c72535381ae7af9f968322/raw/5e40b03333a3c148b78aa348fd2cd5b5dbb36e4d/addition_to_sys.sql

# Melakukan Import addition_to_sys.sql
sudo mysql -u root -p < addition_to_sys.sql

# Melakukan Import proxy_config_connection.sql
sudo mysql -u root -p < /vagrant/mysql-dump/proxy_config_connection.sql
```
