class postfix(
  $root_mail_recipient = '',
  $install_mailx = true,
  $ensure = 'present',
  $autoupgrade = false,
  $service_ensure = 'running',
  $service_enable = true,
  $service_hasstatus = $postfix::params::service_hasstatus,
  $service_hasrestart = $postfix::params::service_hasrestart,
  $monitor = false,
  $monitor_tool = false,
  $firewall = false,
  $firewall_tool = false,
  $firewall_src = false,
  $firewall_dst = false,
  $service = $postfix::params::service,
  $package = $postfix::params::package,
  $package_mailx = $postfix::params::package_mailx,
  $aliases_file = $postfix::params::aliases_file,
  $mailname_file = $postfix::params::mailname_file
) inherits postfix::params {

  validate_bool($install_mailx, $autoupgrade, $service_enable, $monitor, $firewall, $service_hasstatus, $service_hasrestart)

  case $ensure {
    present: {
      if $autoupgrade == true {
        $package_ensure = 'latest'
      } else {
        $package_ensure = 'present'
      }
      
      case $service_ensure {
        running, stopped: {
          $service_ensure_real = $service_ensure
        }
        default: {
          fail('service_ensure parameter must be running or stopped')
        }
      }

      $file_ensure = 'file'
    }
    absent: {
      $package_ensure = 'absent'
      $service_ensure_real = 'stopped'
      $file_ensure = 'absent'
    }
    default: {
      fail('ensure parameter must be present or absent')
    }
  }

  package { $package:
    ensure => $package_ensure,
  }

  if $install_mailx == true {
    package { 'mailx':
      ensure => $package_ensure,
      name   => $package_mailx,
    }
  }

  file { $mailname_file:
    ensure  => $file_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "${fqdn}\n",
    require => Package[$package],
    notify  => Service[$service],
  }

  file { $aliases_file:
    ensure  => $file_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package[$package],
    notify  => Exec['newaliases'],
  }

  exec { 'newaliases':
    command     => $postfix::params::newaliases_cmd,
    refreshonly => true,
    require     => Package[$package],
  }

  Mailalias {
    notify => Exec['newaliases'],
  }

  if $root_mail_recipient != '' {
    mailalias { 'root':
      recipient => $root_mail_recipient,
      require   => File[$aliases_file],
    }
  }

  service { $service:
    ensure     => $service_ensure,
    enable     => $service_enable,
    hasstatus  => $service_hasstatus,
    hasrestart => $service_hasrestart,
    require    => Package[$package],
  }
}
