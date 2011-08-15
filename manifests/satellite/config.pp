class postfix::satellite::config {
    file { $postfix::params::master_file:
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => 644,
        source  => 'puppet:///modules/postfix/satellite/master.cf',
        notify  => Class['postfix::service'],
        require => Class['postfix'],
    }

    file { $postfix::params::main_file:
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => 644,
        content => template('postfix/satellite/main.cf.erb'),
        notify  => Class['postfix::service'],
        require => Class['postfix'],
    }
}
