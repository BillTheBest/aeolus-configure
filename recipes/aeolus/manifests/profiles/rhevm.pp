class aeolus::profiles::rhevm {
  file {"/etc/rhevm.json":
    content => template("aeolus/rhevm.json"),
    mode => 755,
    require => Package['aeolus-conductor-daemons'] }

  file {"/etc/iwhd/conf.js":
    content => template("aeolus/iwhd-conf.js"),
    mode => 755,
    require => Package['aeolus-conductor-daemons'] }

  file {"$rhevm_nfs_mount_point":
    ensure => 'directory'}

  mount {"$rhevm_nfs_mount_point":
    ensure => mounted,
    device => "$rhevm_nfs_server:$rhevm_nfs_export",
    fstype => "nfs",
    options => "rw",
    require => File["$rhevm_nfs_mount_point"]}

  # give iwhd a restart to pick up new configuration files
  # in the event iwhd had already initialized at /var/lib/iwhd
  exec { "/sbin/service iwhd restart":
    require => [Service['iwhd'],
                Mount["$rhevm_nfs_mount_point"],
                File["/etc/rhevm.json"],
                File["/etc/iwhd/conf.js"]]}

  aeolus::create_bucket{"aeolus":}

  aeolus::conductor::site_admin{"admin":
     email           => 'dcuser@aeolusproject.org',
     password        => "password",
     first_name      => 'aeolus',
     last_name       => 'user'}

  aeolus::conductor::login{"admin": password => "password",
     require  => Aeolus::Conductor::Site_admin['admin']}

  aeolus::conductor::provider{"rhevm":
    deltacloud_driver   => "rhevm",
    url                 => "http://localhost:3002/api",
    deltacloud_provider => "$rhevm_deltacloud_provider",
    require             => Aeolus::Conductor::Login["admin"] }
    
  aeolus::conductor::provider::account{"rhevm":
      provider           => 'rhevm',
      type               => 'rhevm',
      username           => '$rhevm_deltacloud_username',
      password           => '$rhevm_deltacloud_password',
      require        => Aeolus::Conductor::Provider["rhevm"] }
    
  aeolus::conductor::hwp{"hwp1":
      memory         => "512",
      cpu            => "1",
      storage        => "",
      architecture   => "x86_64",
      require        => Aeolus::Conductor::Login["admin"] }

  aeolus::conductor::logout{"admin":
    require    => [Aeolus::Conductor::Provider['rhevm'],
                   Aeolus::Conductor::Provider::Account['rhevm'],
                   Aeolus::Conductor::Hwp['hwp1']] }

  # TODO: create a realm and mappings
}

class aeolus::profiles::rhevm::disabled {
  mount {"$rhevm_nfs_mount_point":
    ensure => unmounted,
    device => "$rhevm_nfs_server:$rhevm_nfs_export"}
}