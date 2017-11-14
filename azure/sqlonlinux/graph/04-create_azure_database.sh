#byLeal
# Let's get the password first...
read -p ">> Enter SQL Server Name: " sname
read -p ">> Enter SQL Username: " user
stty -echo
read -p ">> Enter SQL Password: " pass; echo
stty echo

# Here we go...
/opt/mssql-tools/bin/sqlcmd -S "$sname" -U "$user" -P "$pass" -dmaster -N -Q "CREATE DATABASE vnextdb;"
