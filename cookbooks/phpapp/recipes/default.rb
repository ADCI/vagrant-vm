#
# Cookbook Name:: phpapp
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

require 'fileutils'

include_recipe "nginx"
include_recipe "php"
include_recipe "php::module_mysql"
include_recipe "php::module_curl"
#include_recipe "php::module_apc"
include_recipe "php::module_gd"
include_recipe "php-fpm"
#include_recipe "mysql_adci"
include_recipe "percona::package_repo"
include_recipe "percona::client"
include_recipe "percona::server"
include_recipe "http_request"
include_recipe "http_request::default"

# Create directory /var/www.
Dir.mkdir("/var/www") unless File.exists?("/var/www")
FileUtils.chown(ENV['SSH_USER'], ENV['SSH_USER'], "/var/www")

# Delete old config files.
Dir.glob("/etc/nginx/sites-enabled/*.conf").each { |file| File.delete(file) }
Dir.glob("/etc/nginx/sites-available/*.conf").each { |file| File.delete(file) }

template "php.ini" do
  path "#{node['php-fpm']['conf_dir']}/php.ini"
  source "php.ini.erb"
  owner "root"
  group "root"
  mode 0644
  variables(:directives => node['php']['directives'])
  notifies :reload, 'service[php-fpm]'
end

template "nginx.conf" do
  path "#{node['nginx']['dir']}/nginx.conf"
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :reload, 'service[nginx]'
end        

# nginx.site.conf templates
if node.has_key?("project") && node["project"].has_key?("sites")
  node["project"]["sites"].each do |site|
    site_name = site[0]
    site_config = site[1]
    site_port = ''
    domain = ''
    flag_www_redirect = false
    index = 'index.php'
    cors_headers = false
    ssl = ''
    ssl_certificate = ''
    ssl_certificate_key = ''
    conf_inc = ''
    docroot = "#{node[:doc_root]}/var/www/#{site_name}/project"
    redirect = false
    # Means "copy scheme".
    redirect_scheme = '$scheme'
    # 80 is default port. It'll be changed either to "listen" from "redirect" param or to "site_port" of available.
    redirect_listen = '80'
    redirect_from = ''
    redirect_to = ''
    redirect_ssl = ''
    www_action = ''
    api = false
    api_path = ''
    api_alias = ''

    site_config.each do |config|
      case config[0]
        when 'port'
          site_port = config[1]

        when 'domain'
          domain = config[1]

        when 'redirect'
          redirect = true
          if config[1].has_key?('www')
            www_action = config[1][:www]
          end
          if config[1].has_key?('scheme')
            redirect_scheme = config[1][:scheme]
          end
          if config[1].has_key?('listen')
            redirect_listen = config[1][:listen]
          end
          if config[1].has_key?('ssl')
            redirect_ssl = config[1][:ssl]
          end

        when 'api'
          api = true
          if config[1].has_key?('path')
            api_path = config[1][:path]
          end
          if config[1].has_key?('alias')
            api_alias = config[1][:alias]
          end

        when 'dir'
          docroot = "#{node[:doc_root]}#{config[1]}/project"

        when 'root'
          docroot = config[1]

        when 'ssl'
          ssl = config[1].downcase

        when 'ssl_certificate'
          ssl_certificate = config[1]

        when 'ssl_certificate_key'
          ssl_certificate_key = config[1]

        when 'conf_inc'
          conf_inc = config[1]

        when 'index'
          index = config[1]

        when 'cors_headers'
          cors_headers = config[1]

      end
    end
    if site_port == '' && domain == ''
      ::Chef::Log.error("The #{site_name} project doesn't have port or domain option")
      break
    end
    if domain == ''
      domain = site_name;
    end

    if redirect
      domain_without_www = domain.sub(/www./, '')
      domain_with_www = "www.#{domain_without_www}"
      if www_action == 'enforce'
        redirect_from = domain_without_www
        redirect_to = domain_with_www
      elsif www_action == 'remove'
        redirect_from = domain_with_www
        redirect_to = domain_without_www
      else
        redirect_from = domain
        redirect_to = domain
      end
      if redirect_listen == '' && site_port != ''
        redirect_listen = site_port
      end
    end

    template "/etc/nginx/sites-available/#{site_name}.conf" do
      source "nginx.site.conf.erb"
      mode "0640"
      owner "root"
      group "root"
      variables(
                :server_name => site_name,
                :server_port => site_port,
                :domain => domain,
                :flag_www_redirect => flag_www_redirect,
                :index => index,
                :cors_headers => cors_headers,
                :ssl => ssl,
                :ssl_certificate => ssl_certificate,
                :ssl_certificate_key => ssl_certificate_key,
                :conf_inc => conf_inc,
                #:server_aliases => ["*.#{site_name}"],
                :docroot => docroot,
                :logdir => "#{node[:nginx][:log_dir]}",
                :redirect => redirect,
                :redirect_scheme => redirect_scheme,
                :redirect_listen => redirect_listen,
                :redirect_ssl => redirect_ssl,
                :redirect_from => redirect_from,
                :redirect_to => redirect_to,
                :api => api,
                :api_path => api_path,
                :api_alias => api_alias
      )
    end

    nginx_site "#{site_name}.conf" do
      :enable
    end
  end
end
