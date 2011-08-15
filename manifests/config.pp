class postfix::config {
    Mailalias {
        notify => Exec['newaliases'],
    }

    file { $postfix::params::mailname_file:
        ensure  => present,
        content => "${fqdn}\n",
    }

    file { $postfix::params::aliases_file:
        ensure  => present,
        source  => 'puppet:///modules/postfix/aliases',
        notify  => Exec['newaliases'],
    }

    exec { 'newaliases':
        command     => $postfix::params::newaliases_cmd,
        refreshonly => true,
        require     => Class['postfix::install'],
        subscribe   => File[$postfix::params::aliases_file],
    }

    mailalias { 'root':
        recipient => $postfix::params::postfix_root_mail_recipient,
    }
}
