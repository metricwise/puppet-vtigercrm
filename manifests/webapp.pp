# = Define: vtigercrm::webapp
#
#   Installs vtiger CRM.
#
# == Parameters:
#
#   $docroot::
#     The folder where vtiger source will be installed.
#
#   $ensure::
#     present (default)
#     absent
#
#   $provider::
#     svn
#     tgz (default) 
#
#   $version::
#     5.3.0
#     5.4.0 (default)
#     6.0.0
#
# == Requirements:
#
#   puppet-apache2
#   puppet-iptables
#   puppet-mysql
#
define vtigercrm::webapp(
	$docroot = "/var/www/$name",
	$ensure = "present",
	$provider = "tgz",
	$version = "5.4.0"
) {
    include apache2::php
    include iptables
    include mysql::server

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
        notify => Service[httpd],
        require => Package[php-common],
    }

    if "tgz" == $provider {
        exec { "Download source tarball":
            before => Exec["Chown source"],
            command => "wget http://prdownloads.sourceforge.net/vtigercrm/vtigercrm-$version.tar.gz -O /tmp/vtigercrm-$version.tar.gz",
            creates => "/tmp/vtigercrm-$version.tar.gz",
        }
    
        exec { "Unzip source tarball":
            command => "tar xzf /tmp/vtigercrm-$version.tar.gz",
            creates => "$docroot/vtigercrm",
            cwd => "$docroot",
            require => Exec["Download source tarball"],
        }
    } elsif "svn" == $provider {
    	package { subversion: }

        exec { "Export source from subversion":
            command => "svn export http://trac.vtiger.com/svn/vtiger/vtigercrm/branches/$version $docroot",
            creates => $docroot,
            before => Exec["Chown source"],
            require => Package["subversion"],
            timeout => 0,
        }
    }

    exec { "Chown source":
        command => "chown -R apache:apache $docroot",
    }

    iptables { http:
        proto => "tcp",
        dport => "80",
        jump => "ACCEPT",
        state => "NEW",
    }

    mysql::database { "vtigercrm$version":
    	ensure => present,
    }

    mysql::rights { "Grant database privileges to vtigercrm@localhost":
        database => "vtigercrm$version",
        host => "localhost",
        password => "vtigercrm$version",
        user => "vtigercrm$version",
    }

    package {[ php-common, php-gd, php-imap, php-mysql ]:
        ensure => latest,
        notify => Service[httpd],
        provider => yum,
    }

	apache2::site { $name:
		docroot => $docroot,
		ensure => $ensure,
	}
}
