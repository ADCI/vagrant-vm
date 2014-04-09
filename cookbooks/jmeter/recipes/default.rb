#
# Cookbook Name:: jmeter
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

bash "install jmeter" do
  user node['jmeter']['user']
  group node['jmeter']['group']
  cwd #{Chef::Config[:file_cache_path]}
  code <<-EOC
    rm -f apache-jmeter-#{node['jmeter']['version']}
    curl -skOL #{node['jmeter']['url']}
    rm -rf apache-jmeter-#{node['jmeter']['version']}
    gzip -dc apache-jmeter-#{node['jmeter']['version']}.tgz | tar xf -
    mv apache-jmeter-#{node['jmeter']['version']} #{node['jmeter']['root']}
  EOC
  creates "#{node['jmeter']['root']}/apache-jmeter-#{node['jmeter']['version']}/bin/jmeter"
end

link "#{node['jmeter']['root']}/apache-jmeter" do
  to "apache-jmeter-#{node['jmeter']['version']}"
end

template "/etc/profile.d/jmeter.sh" do
  owner node['jmeter']['user']
  group node['jmeter']['group']
  mode 0644
end

