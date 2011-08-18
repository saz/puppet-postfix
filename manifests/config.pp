class postfix::config {
    Mailalias {
        notify => Exec['newaliases'],
    }

    file { $postfix::params::mailname_file:
        ensure  => present,
        content => "${fqdn}\n",
        notify  => Class['postfix::service'],
        require => Class['postfix::install'],
    }

    file { $postfix::params::aliases_file:
        ensure  => present,
        replace => false,
        notify  => Exec['newaliases'],
        require => Class['postfix::install'],
    }

    exec { 'newaliases':
        command     => $postfix::params::newaliases_cmd,
        refreshonly => true,
        require     => Class['postfix::install'],
        subscribe   => File[$postfix::params::aliases_file],
    }

    mailalias { 'root':
        recipient => $postfix::params::root_mail_recipient,
        require   => File[$postfix::params::aliases_file],
    }
}
