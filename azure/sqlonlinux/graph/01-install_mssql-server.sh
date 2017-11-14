#Install Key and add the Repository.
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
curl https://packages.microsoft.com/config/ubuntu/16.04/mssql-server.list | sudo tee /etc/apt/sources.list.d/mssql-server.list

#Install the SQL Server using APT-GET (Debian/Ubuntu Official Package Manager)!
sudo apt-get update
sudo apt-get install -y mssql-server

#Configure SQL Server (Accept the License Terms).
## sudo /opt/mssql/bin/mssql-conf setup

#Get the Status of the SQL Server Service.
## systemctl status mssql-server
