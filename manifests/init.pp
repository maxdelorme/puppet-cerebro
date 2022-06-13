# Class: cerebro
# ===========================
#
# A basic module to install and set up Cerebro.
#
# Examples
# --------
#
# @example
#    class { 'cerebro': }
#
# Authors
# -------
#
# Author Name <brandon@webwulf.net>
#
# Copyright
# ---------
#
# Copyright 2017 Brandon Wulf
#
class cerebro (
  $version       = '0.7.0',
  $download_url  = "https://github.com/lmenezes/cerebro/releases/download/v${version}/cerebro-${version}.tgz",
  $install_path  = '/opt/cerebro',
  $user          = 'cerebro',
  $group         = 'cerebro',
  $service       = 'cerebro',
  $targets       = [ {
    host => 'http://localhost:9200',
    name => 'Local Elasticsearch',
  } ],
  $auth_type     = undef,
  $auth_settings = undef,
  $base_path     = '/',
) {
  require '::archive'

  validate_array($targets)

  if $auth_type {
    validate_hash( $auth_settings )
  }

  group{ $group:
    ensure => present,
  }

  -> user{ $user:
    ensure => present,
    groups => [$group],
  }

  -> file{ $install_path:
    ensure => 'directory',
    owner  => $user,
    group  => $group,
    mode   => '0775',
  }

  -> archive{ "${install_path}/downloads/download-${version}.tgz":
    ensure       => present,
    source       => $download_url,
    extract      => true,
    extract_path => $install_path,
    creates      => "${install_path}/${service}-${version}/bin/${service}",
  }

  -> file{ "${install_path}/${service}-${version}":
    ensure  => 'directory',
    owner   => $user,
    group   => $group,
    recurse => true,
  }

  -> file{ "${install_path}/current":
    ensure => link,
    owner  => $user,
    group  => $group,
    target => "${install_path}/${service}-${version}",
  }

  -> file{ "/etc/systemd/system/${service}.service":
    ensure  => 'file',
    mode    => '0664',
    content => template("${module_name}/cerebro.systemd.erb"),
  }

  -> file{ '/etc/cerebro':
    ensure => 'directory',
    owner  => $user,
    group  => $group,
    mode   => '0775',
  }

  -> file{ '/etc/cerebro/application.conf':
    ensure  => 'file',
    mode    => '0664',
    owner   => $user,
    group   => $group,
    content => template("${module_name}/application.conf.erb"),
    notify  => Service[ $service ],
  }

  -> file{ "${install_path}/current/conf/application.conf":
    ensure => link,
    owner  => $user,
    group  => $group,
    target => '/etc/cerebro/application.conf',
  }

  -> exec{ "Load ${service}.service unit":
    command     => 'sudo systemctl daemon-reload',
    refreshonly => true,
  }

  -> service{ $service:
    ensure => running,
    enable => true,
  }
}
