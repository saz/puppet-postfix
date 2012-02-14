class postfix::satellite(
  $relayhost = "smtp.${::domain}",
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
  $mailname_file = $postfix::params::mailname_file,
  $master_file = $postfix::params::master_file,
  $main_file = $postfix::params::main_file
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

  class { 'postfix':
    root_mail_recipient => $root_mail_recipient,
    install_mailx       => $install_mailx,
    ensure              => $ensure,
    autoupgrade         => $autoupgrade,
    service_ensure      => $service_ensure,
    service_enable      => $service_enable,
    service_hasstatus   => $service_hasstatus,
    service_hasrestart  => $service_hasrestart,
    monitor             => $monitor,
    monitor_tool        => $monitor_tool,
    firewall            => $firewall,
    firewall_tool       => $firewall_tool,
    firewall_src        => $firewall_src,
    firewall_dst        => $firewall_dst,
    service             => $service,
    package             => $package,
    package_mailx       => $package_mailx,
    aliases_file        => $aliases_file,
    mailname_file       => $mailname_file,
  }

  file { $master_file:
    ensure  => $file_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/postfix/satellite/master.cf',
    require => Package[$package],
    notify  => Service[$service],
  }

  file { $main_file:
    ensure  => $file_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('postfix/satellite/main.cf.erb'),
    require => Package[$package],
    notify  => Service[$service],
  }
}
