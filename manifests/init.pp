# Class: cerebro
# ===========================
#
# Install and set up Cerebro.
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
  $version      = '0.6.6',
  $download_url = "https://github.com/lmenezes/cerebro/releases/download/v${version}/cerebro-${version}.tgz",
  $install_path = '/opt/cerebro',
  $user         = 'cerebro',
  $group        = 'cerebro',
  $service      = 'cerebro',
  $target_url   = 'http://localhost:9200',
  $target_name  = 'Local Elasticsearch',
) {
  require '::archive'

  if (!defined('::java')) {
    class { '::java':
      distribution          => 'jdk',
      package               => 'jdk1.8.0_73',
      java_alternative      => 'java',
      java_alternative_path => '/usr/java/jdk1.8.0_73/jre/bin/java',
      before                => Service[ $service ],
    }
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
    mode   => '0555',
  }

  -> archive{ "${install_path}/downloads/download-${version}.tgz":
    ensure       => present,
    source       => $download_url,
    extract      => true,
    extract_path => $install_path,
    creates      => "${install_path}/${service}-${version}/bin/${service}",
  }

  -> file{ "$install_path/${service}-${version}":
    ensure  => 'directory',
    owner   => $user,
    group   => $group,
    recurse => true,
  }

  -> file{ "${install_path}/current":
    ensure => link,
    owner   => $user,
    group   => $group,
    target => "${install_path}/${service}-${version}",
  }

  -> file{ "/etc/systemd/system/${service}.service":
    ensure  => 'file',
    mode    => '0550',
    content => template("${module_name}/cerebro.systemd.erb"),
  }

  -> file{ '/etc/cerebro':
    ensure => 'directory',
    owner  => $user,
    group  => $group,
    mode   => '0555',
  }

  -> file{ '/etc/cerebro/application.conf':
    ensure  => 'file',
    mode    => '0550',
    owner   => $user,
    group   => $group,
    content => template("${module_name}/application.conf.erb"),
  }

  -> file{ "${install_path}/current/conf/application.conf":
    ensure => link,
    owner   => $user,
    group   => $group,
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
