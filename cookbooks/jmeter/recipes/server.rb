#
# Cookbook Name:: jmeter
# Recipe:: server
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "jmeter::default"

template "/etc/init.d/jmeter-server" do
  owner node['jmeter']['user']
  group node['jmeter']['group']
  mode 00755
end

service 'jmeter-server' do
  supports :status => true, :restart => true, :reload => false
  action [ :enable, :start ]
end
