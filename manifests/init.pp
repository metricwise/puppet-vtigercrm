class vtigercrm {
    include mysql::server

	$version = "5.3.0"

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

    mysql::database { "vtigercrm$version":
    	ensure => present,
    }

    mysql::rights { "Grant database privileges to vtigercrm@localhost":
        database => "vtigercrm$version",
        host     => "localhost",
        password => "vtigercrm$version",
        user     => "vtigercrm$version",
    }
}
