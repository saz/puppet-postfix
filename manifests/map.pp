define postfix::map (
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

  $map_target = $instance ? {
    ''      => "${base_dir}/${name}",
    default => "${base_dir}-${instance}/${name}",
  }

  $map = "${type}:${map_target}"

  $map_notify = $ensure ? {
    present => Exec["postmap ${map}"],
    absent  => undef,
  }

  # TODO: require postfix instance
  file { $map_target:
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => $map_notify,
    content => template("${module_name}/map.erb"),
  }

  case $type {
    'none', 'pcre': {
      $cmd = "echo \"No update required for ${map}\""
    }
    default: {
      $cmd = "postmap ${map}"
    }
  }

  # TODO: notify postfix instance
  exec { "postmap ${map}":
    command     => $cmd,
    path        => '/bin:/usr/sbin',
    refreshonly => true,
  }
}
