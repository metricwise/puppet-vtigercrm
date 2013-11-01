# = Define: vtigercrm::database::mysql
#
#   Creates MySQL database and user for vtiger CRM.
#
# == Parameters:
#
#   $ensure::
#     present (default)
#     absent
#
#   $host::
#
#   $password_hash::
#
#   $user::
#
define vtigercrm::database::mysql(
    $ensure = "present",
    $host = "localhost",
    $password_hash = mysql_password("vtigercrm"),
    $user = "vtigercrm",
) {
    mysql_database { $name:
        ensure => $ensure,
    }

    mysql_user { "${user}@${host}":
        ensure => $ensure,
        password_hash => $password_hash,
    }

    mysql_grant { "${user}@${host}/${name}.*":
        ensure => $ensure,
        options => ["GRANT"],
        privileges => ["ALL"],
        table => "${name}.*",
        user => "${user}@${host}",
    }
}
