class postfix::install {
    package { $postfix::params::package_name:
        ensure => present,
    }

    package { $postfix::params::mailx_package_name:
        ensure => present,
    }
}
