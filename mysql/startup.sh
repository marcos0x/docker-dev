#/bin/bash

if [ ! -f /var/lib/mysql/ibdata1 ]; then

	mkdir -p /var/run/mysqld
	chown mysql:mysql /var/run/mysqld

	# mysql_install_db
	mysqld --initialize --datadir=/var/lib/mysql

	/usr/bin/mysqld_safe &
	sleep 10s

	echo "GRANT ALL ON *.* TO root@'%' IDENTIFIED BY '' WITH GRANT OPTION; FLUSH PRIVILEGES" | mysql

	killall mysqld
	sleep 10s
fi

/usr/bin/mysqld_safe
