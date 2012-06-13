# Basic Puppet Apache manifest

class lucid32 {
    group { "puppet":
        ensure => "present",
    }
    
    package { "apache2":
        ensure  => present,
        require => Exec["apt-get update"]
    }
    
    service { "apache2":
        ensure  => running,
        require => Package["apache2"],
    }
    
    package { mysql-server: 
        ensure => installed,
        require => Exec["apt-get update"],
    }
    
    service {
        mysql:
        enable    => true,
        ensure    => running,
        subscribe => Package[mysql-server]
    }
    
    package { php5: 
        ensure => installed,
        require => Exec["apt-get update"],
    }
    package { php5-mysql: 
        ensure => installed,
        require => Exec["apt-get update"],
    }
    package { phpmyadmin: 
        ensure  => installed,
        require => [Package['php5'], Package['apache2'], Exec["apt-get update"]],
    }

   exec { "apt-get update":
        command => "/usr/bin/apt-get update && touch /tmp/apt.update",
        onlyif  => "/bin/sh -c '[ ! -f /tmp/apt.update ] || /usr/bin/find /etc/apt -cnewer /tmp/apt.update | /bin/grep . > /dev/null'",
   }
   
   file { "/etc/apache2/conf.d/phpmyadmin":
        ensure  => link,
        target  => '/etc/phpmyadmin/apache.conf',
        notify  => Exec[apache-restart],
        require => Package['phpmyadmin'],
   }
   file { "/etc/phpmyadmin/config.inc.php":
        ensure  => present,
        source  => "/var/Crewweb/vagrant/files/phpmyadmin-config.inc.php",
        require => Package['phpmyadmin'],
        owner   => 'root',
        group   => 'root',
   }
   file { "/etc/phpmyadmin/config-db.php":
        ensure  => present,
        source  => "/var/Crewweb/vagrant/files/phpmyadmin-config-db.php",
        require => Package['phpmyadmin'],
        owner   => 'root',
        group   => 'www-data',
        mode    => '640'
   }
   
   exec { "apache-restart":
        command     => "/etc/init.d/apache2 restart",
        refreshonly => true
   }

	$alias_crewwebwas = "
		Alias /crewweb /var/Crewweb/crewweb
		Alias /was /var/Crewweb/was
		Alias /tester /var/Crewweb/tester
	"
	file { "/etc/apache2/conf.d/alias.crewwebwas":
		content => $alias_crewwebwas,
		ensure  => present,
		require => Package['apache2'],
		notify  => Service['apache2'],
	}
	$dev_phpini = "
		display_errors = On
		error_reporting = E_ALL
	"
	file { "/etc/php5/conf.d/phpdev.ini":
		content => $dev_phpini,
		ensure  => present,
		require => Package['apache2'],
		notify  => Service['apache2'],
	}
	
	file { "/var/Crewweb/config":
		ensure	=> directory,
		mode	=> 0777,
	}
	
	file { "/var/Crewweb/config/configpath.php":
		source  => "/var/Crewweb/vagrant/files/configpath.php",
		ensure  => present,
	}
	
	
	file { "/tmp/templates_c_crewweb/":
		ensure  => directory,
		owner   => 'root',
		group   => 'www-data',
		mode    => 777,
	}
	file { "/tmp/templates_c_was/":
		ensure  => directory,
		owner   => 'root',
		group   => 'www-data',
		mode    => 777,
	}


	db { "warpcrew_crewweb":
		user     => "crewwebisawesome",
		password => "",
	}
	db { "warpcrew_was":
		user     => "wasisawesome",
		password => "",
	}
	exec { "grant-crewwebtowas":
		unless  => "/usr/bin/mysql -ucrewwebisawesome warpcrew_was",
		command => "/usr/bin/mysql -uroot -e \"grant select,insert,update on warpcrew_was.* to crewwebisawesome@localhost identified by '';\"",
		require => [Service["mysql"]]
	}
	exec { "grant-wastocrewweb":
		unless  => "/usr/bin/mysql -uwasisawesome warpcrew_crewweb",
		command => "/usr/bin/mysql -uroot -e \"grant select,insert,update on warpcrew_crewweb.* to wasisawesome@localhost identified by '';\"",
		require => [Service["mysql"]]
	}
	db_content { "warpcrew_crewweb":
		database => "warpcrew_crewweb",
		file     => "/var/Crewweb/doc/warpcrew_crewweb.sql",
		require => DB["warpcrew_crewweb"],
	}
	db_content { "warpcrew_crewweb_data":
		database => "warpcrew_crewweb",
		file     => "/var/Crewweb/doc/warpcrew_crewweb-data.sql",
		require => [DB["warpcrew_crewweb"], DB_CONTENT["warpcrew_crewweb"]],
	}
	db_content { "warpcrew_was":
		database => "warpcrew_was",
		file     => "/var/Crewweb/doc/warpcrew_was.sql",
		require => DB["warpcrew_was"],
	}
	db_content { "warpcrew_was_data":
		database => "warpcrew_was",
		file     => "/var/Crewweb/doc/warpcrew_was-data.sql",
		require => [DB["warpcrew_was"], DB_CONTENT["warpcrew_was"]],
	}
}

define db( $user, $password ) {
	exec { "create-${name}-db":
		unless  => "/usr/bin/mysql -uroot ${name}",
		command => "/usr/bin/mysql -uroot -e \"create database ${name};\"",
		require => Service["mysql"],
	}

	exec { "grant-${name}-db":
		unless  => "/usr/bin/mysql -u${user} -p${password} ${name}",
		command => "/usr/bin/mysql -uroot -e \"grant select,insert,update on ${name}.* to ${user}@localhost identified by '$password';\"",
		require => [Service["mysql"], Exec["create-${name}-db"]]
	}
}

define db_content ($database, $file) {
	exec { "importto-${database}-from-${file}":
		command => "/usr/bin/mysql -uroot -D ${database} --default_character_set utf8 < ${file}",
		require => Service["mysql"],
	}
}



include lucid32
