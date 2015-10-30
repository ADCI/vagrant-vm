VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Ubuntu 12.04 x32.
  #config.vm.box = "Ubuntu precise"
  #config.vm.box_url = "http://files.vagrantup.com/precise32.box"
  # Ubuntu 14.10 x64.
  #config.vm.box = "Ubuntu 14.10 x64"
  #config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/utopic/current/utopic-server-cloudimg-amd64-vagrant-disk1.box"
  # Ubuntu 14.10 x32.
  config.vm.box = "Ubuntu 14.10 x32"
  config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/utopic/current/utopic-server-cloudimg-i386-vagrant-disk1.box"

  config.vm.network :forwarded_port, host: 4567, guest: 4567
  #config.vm.network :forwarded_port, host: 8080, guest: 8080

  
  #config.vm.network "public_network", ip: "10.1.0.125"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = 1024
    # Improve network perfomance
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    #vb.customize ["modifyvm", :id, "--ioapic", "on"]
    #vb.customize ["modifyvm", :id, "--cpuexecutioncap", "100"]
  end

  # Update Chef and Ruby
  config.vm.provision :shell, :inline => 'apt-get update'
  config.vm.provision :shell, :inline => 'apt-get install build-essential ruby ruby-dev --yes'
  # Chef 12.0.0-3 has bug which hasn't been fixed in released versions.
  # https://github.com/chef/chef/issues/2677
  config.vm.provision :shell, :inline => 'gem install chef -v 11.16.4 --no-rdoc --no-ri --conservative'
  # Yeah, weird things going on.
  config.vm.provision :shell, :inline => 'gem install chef -v 12.0.3 --no-rdoc --no-ri --conservative'
  config.vm.provision :shell, :inline => 'gem uninstall chef -v 12.0.3'

  # Install/update Alpine
  # config.vm.provision :shell, :inline => 'apt-get install alpine --no-upgrade --yes'

  
  config.vm.provision "chef_solo" do |chef|
    chef.add_recipe "apt"
    chef.add_recipe "git"
    chef.add_recipe "phpapp"
    chef.add_recipe "drush"
    chef.add_recipe "phing"
    # Use following recipes when you really need it.
    #chef.add_recipe "codesniffer"
    #chef.add_recipe "phpmd"
    #chef.add_recipe "phpcpd"
    #chef.add_recipe "postfix"
    #chef.add_recipe "dovecot::default"
    #chef.add_recipe "php_imap"
    #chef.add_recipe "redis"
    #chef.add_recipe "jenkins::java"
    #chef.add_recipe "jenkins::master"
    #chef.add_recipe "firefox"
    #chef.add_recipe "xvfb"
    #chef.add_recipe "jenkins_plugins"
    #chef.add_recipe "jmeter"
    #chef.add_recipe "imagemagick"
    #chef.add_recipe "poppler"
    #chef.add_recipe "pdftk"

    # Nodejs related cookbooks.
    #chef.add_recipe "nodejs"
    # Gulp requires nodejs cookbook.
    #chef.add_recipe "gulp"

    # Configure available sites.
    # Available fields are:
    #  - port - Tells nginx to listen on this port.
    #  - dir - Path to site's files. "project" will be added to the end of path.
    #  - domain - Can be used if site name and site domain are different.
    #  - flag_www_redirect - "true" if www.site.com should be redirected to site.com.
    #  - ssl - if set to "on" then ssl_certificate and ssl_certificate_key
    #          also should be specified.
    #  - ssl_certificate - Path to ssl sertificate.
    #  - ssl_certificate_key - Path to ssl sertificate key.
    #  - conf_inc - Additional conf file which will be included in site's conf.
    #               Path to file should either be relative to nginx conf dir or
    #               absolute.
    # - redirect - create redirect rule, can contain next fields:
    #          www: "enforce", "remove" or nothing
    #          scheme: any supported scheme (like "https" or "http") or nothing
    #          listen: default nginx listen field (can accept something like "80 443")
    #          ssl: "on" - ssl is enabled and ssl_certificate and ssl_certificate_key will be added to redirect rule too

    chef.json = {
      "project" => {
        "sites" => {
          "site" => {
            "port" => 4567,
            "dir" => "/var/www/site",
          },
          "another_site" => {
            "domain" => "site.com",
          },
          "empty_site" => {

          }
        }
      }
    }

    # Settings in external file roles/webserver.rb
    chef.roles_path = "roles"
    chef.add_role("webserver")
  end
end
