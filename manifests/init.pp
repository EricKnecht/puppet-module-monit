class monit($ensure=present, $admin='', $interval=60) {
  $is_present = $ensure == 'present'

  $service_pattern = $ensure ? {
    'present'   => '/usr/sbin/monit',
    default     => undef,
  }

  package { 'monit':
    ensure => $ensure,
  }

  $monit_conf = $::operatingsystem ? {
    /(?i)(centos|redhat|fedora|scientific|amazon)/ => '/etc/monit.conf',
    default => '/etc/monit/monitrc',
  }

  $monit_dir = $::operatingsystem ? {
    /(?i)(centos|redhat|fedora|scientific|amazon)/ => '/etc/monit.d',
    default => '/etc/monit/conf.d',
  }

  file { $monit_conf:
    ensure  => $ensure,
    content => template('monit/monitrc.erb'),
    mode    => '0600',
    require => Package['monit'],
  }

  file { '/etc/default/monit':
    ensure  => $ensure,
    content => "startup=1\n",
    require => Package['monit'],
  }

  file { '/etc/logrotate.d/monit':
    ensure  => $ensure,
    source  => 'puppet:///modules/monit/monit.logrotate',
    require => Package['monit'],
  }

  service { 'monit':
    ensure      => $is_present,
    enable      => $is_present,
    hasrestart  => $is_present,
    pattern     => $service_pattern,
    subscribe   => File[$monit_conf],
    require     => [
      File[$monit_conf],
      File['/etc/logrotate.d/monit']
    ],
  }
}
