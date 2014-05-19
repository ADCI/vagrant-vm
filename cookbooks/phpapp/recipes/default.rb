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
include_recipe "php::module_apc"
include_recipe "php::module_gd"
include_recipe "php-fpm"
include_recipe "mysql::client"
include_recipe "mysql::server"
include_recipe "http_request"
include_recipe "http_request::default"

# Create directory /var/www.
Dir.mkdir("/var/www") unless File.exists?("/var/www")
FileUtils.chown("vagrant", "vagrant", "/var/www")

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
    site_port = site[1]
    template "/etc/nginx/sites-available/#{site_name}.conf" do
      source "nginx.site.conf.erb"
      mode "0640"
      owner "root"
      group "root"
      variables(
                :server_name => site_name,
                :server_port => site_port,
                :server_aliases => ["*.#{site_name}"],
                :docroot => "#{node[:doc_root]}/var/www/#{site_name}/project",
                :logdir => "#{node[:nginx][:log_dir]}"
                )
    end

    nginx_site "#{site_name}.conf" do
      :enable
    end
  end
end
