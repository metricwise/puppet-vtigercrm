class vtigercrm {
	include apache2::php
	include iptables
    include mysql::server

	$version = "5.3.0"

    augeas { "/etc/php.ini":
        changes => [
            "set allow_call_time_pass_reference On",
            "set display_errors On",
            "set error_reporting \"E_WARNING & ~E_NOTICE & ~E_DEPRECATED\"",
            "set log_errors Off",
            "set max_execution_time 600",
            "set short_open_tag On",
        ],
        context => "/files/etc/php.ini/PHP",
        notify  => Service[httpd],
        require => Package[php-common],
    }

	exec { "Download source tarball":
		command => "wget http://prdownloads.sourceforge.net/vtigercrm/vtigercrm-$version.tar.gz -O /tmp/vtigercrm-$version.tar.gz",
		creates => "/tmp/vtigercrm-$version.tar.gz",
	}

	exec { "Unzip source tarball":
		command => "tar xzf /tmp/vtigercrm-$version.tar.gz",
		creates => "/var/www/html/vtigercrm",
		cwd     => "/var/www/html",
		require => Exec["Download source tarball"],
	}

	exec { "Chown source":
		command => "chown -R apache:apache /var/www/html/vtigercrm",
		require => Exec["Unzip source tarball"],
	}

	iptables { http:
		proto => "tcp",
		dport => "80",
		jump  => "ACCEPT",
		state => "NEW",
	}

    mysql::database { "vtigercrm$version":
    	ensure => present,
    }

    mysql::rights { "Grant database privileges to vtigercrm@localhost":
        database => "vtigercrm$version",
        host     => "localhost",
        password => "vtigercrm$version",
        user     => "vtigercrm$version",
    }

    package {[ php-common, php-gd, php-imap, php-mysql ]:
    	ensure => latest,
    	notify => Service[httpd],
    	provider => yum,
    }
}
