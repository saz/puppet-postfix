class postfix::params {
  case $::operatingsystem {
    ubuntu, debian: {
      $package = 'postfix'
      $service = 'postfix'
      $service_hasstatus = true
      $service_hasrestart = true
      $aliases_file = '/etc/aliases'
      $mailname_file = '/etc/mailname'
      $newaliases_cmd = '/usr/bin/newaliases'

      $config_dir = '/etc/postfix/'
      $master_file = "${config_dir}master.cf"
      $main_file = "${config_dir}main.cf"

      if is_numeric($lsbmajdistrelease) {
        if $::operatingsystem == 'ubuntu' {
          $majrelease = 10
        } else {
          $majrelease = 6
        }

        if $lsbmajdistrelease >= $majrelease {
          $package_mailx = 'bsd-mailx'
        } else {
          $package_mailx = 'mailx'
        }
      }
    }
    default: {
      fail("Unsupported platform: ${::operatingsystem}")
    }
  }
}
