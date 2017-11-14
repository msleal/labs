#byLeal
# Let's get the password first...
read -p ">> Enter SQL Server Name: " sname
read -p ">> Enter SQL Username: " user
stty -echo
read -p ">> Enter SQL Password: " pass; echo
stty echo

/opt/mssql-tools/bin/sqlcmd -S "$sname" -U "$user" -P "$pass" -dvnextdb -N -Q "
CREATE TABLE inventory (id INT, name NVARCHAR(50), quantity INT);
GO
INSERT INTO inventory VALUES (1, 'banana', 150);
INSERT INTO inventory VALUES (2, 'orange', 154);
GO
SELECT * FROM inventory WHERE quantity > 152;
GO"
