define postfix::map (
  $map_name,
  $ensure = 'present',
  $type = 'none',
  $maps = [],
  $instance = '',
  $base_dir = $postfix::params::base_dir
) {

  case $ensure {
    present, absent: { }
    default: {
      fail("ensure must be present or absent, not ${ensure}")
    }
  }

  case $instance {
    '': {
      $map_target = "${base_dir}/${map_name}"
      $base_dir_real = $base_dir
    }
    default: {
      $map_target = "${base_dir}-${instance}/${map_name}"
      $base_dir_real = "${base_dir}-${instance}"
    }
  }

  $map = "${type}:${map_target}"

  $map_notify = $ensure ? {
    present => Exec["postmap ${map}"],
    absent  => undef,
  }

  file { $map_target:
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => $map_notify,
    content => template("${module_name}/map.erb"),
    require => File[$base_dir_real],
  }

  case $type {
    'none', 'pcre': {
      $cmd = "echo \"No update required for ${map}\""
    }
    default: {
      $cmd = "postmap ${map}"
    }
  }

  exec { "postmap ${map}":
    command     => $cmd,
    path        => '/bin:/usr/sbin',
    refreshonly => true,
    notify      => Service['postfix'],
  }
}
