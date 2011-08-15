class postfix::service {
    service { $postfix::params::service_name:
        ensure     => running,
        enable     => true,
        hasstatus  => true,
        hasrestart => true,
        require    => Class['postfix::install'],
    }
}
