# Some convenience routines for rails

define rails::create::db($cwd="", $rails_env=""){
  exec{"create_rails_database":
         cwd         => $cwd,
         environment => "RAILS_ENV=${rails_env}",
         command     => "/usr/bin/rake db:create:all"}

}

define rails::migrate::db($cwd="", $rails_env=""){
  exec{"migrate_rails_database":
         cwd         => $cwd,
         environment => "RAILS_ENV=${rails_env}",
         command     => "/usr/bin/rake db:migrate"}
}

define rails::drop::db($cwd="", $rails_env=""){
  exec{"drop_rails_database":
         cwd         => $cwd,
         onlyif      => "/usr/bin/test -f ${cwd}/Rakefile",
         environment => "RAILS_ENV=${rails_env}",
         command     => "/usr/bin/rake db:drop:all"}
}
