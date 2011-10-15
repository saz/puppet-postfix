class postfix::params {
    # Default values
    case $postfix_root_mail_recipient {
        '': { $root_mail_recipient = 'nobody' }
        default: { $root_mail_recipient = $postfix_root_mail_recipient }
    }

    case $postfix_relayhost {
        '': { $relayhost = "smtp.${domain}" }
        default: { $relayhost = $postfix_relayhost }
    }

    case $operatingsystem {
        /(Ubuntu|Debian)/: {
            $package_name = 'postfix'
            $service_name = 'postfix'
            $config_dir = '/etc/postfix/'
            $master_file = "${config_dir}master.cf"
            $main_file = "${config_dir}main.cf"
            $aliases_file = '/etc/aliases'
            $mailname_file = '/etc/mailname'
            $newaliases_cmd = '/usr/bin/newaliases'

            case $lsbdistcodename {
                squeeze: { $mailx_package_name = 'bsd-mailx' }
                default: { $mailx_package_name = 'mailx' }
            }
        }
    }
}
