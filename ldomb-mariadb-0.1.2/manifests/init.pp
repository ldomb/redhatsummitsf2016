# == Class: mariadb
#
# Full description of class mariadb here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { mariadb:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2015 Your name here, unless otherwise noted.
#
class mariadb (
  $mysqlrootpasswd = '',
) {
  package {
    'mariadb-server': ensure => present
  }

  file { '/tmp/createwordpressdb.sql':
    content => template('mariadb/createwordpressdb.sql.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => 0644,
    notify  => Service['mariadb'];
  }

  service { 'mariadb':
      ensure  => running,
      enable  => true,
      status  => '/sbin/service mariadb status',
      require => Package['mariadb-server'];
  }

  exec { "setmysqlroot":
    unless  => "/usr/bin/mysql -u root -p${mysqlrootpasswd}",
    command => "/usr/bin/mysqladmin -u root password ${mysqlrootpasswd}",
    path    => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin",
    before  => Exec['createdb'],
    require => Service["mariadb"];
  }

  exec { "createdb":
    unless  => "mysql -u root -p${mysqlrootpasswd} -e 'use wordpress'",
    command => "mysql -u root -p${mysqlrootpasswd} < '/tmp/createwordpressdb.sql'",
    path    => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin",
    require => [Service["mariadb"],File["/tmp/createwordpressdb.sql"]];
  }

}
