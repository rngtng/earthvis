
user='root'

mysql -u $user -e "CREATE DATABASE IF NOT EXISTS earthvis;"
mysql -u $user earthvis < earthvis.sql 

