<?php
	$db_password_file = fopen("/run/secrets/mariadb_password", "r");
	$db_password = fgets($db_password_file);
	$db_password = substr($db_password, 0, -1); 
	fwrite(STDOUT, "Waiting for database to be online...\n");
	while (true) {
		try {
			$conn = mysqli_connect('mariadb:3306', getenv("MARIADB_USER"), $db_password, getenv("MARIADB_WORDPRESS_NAME"));
		}
		catch (mysqli_sql_exception $e) {
			continue ;
		}
		$conn->close();
		break ;
	}
	fwrite(STDOUT, "Database connection test success!\n");
	fclose($db_password_file);
?>
