#
# Cookbook Name:: pdepend
# Recipe:: phar
#
# Copyright 2013-2014, Escape Studios
#

remote_file "#{node['pdepend']['install_dir']}/pdepend" do
  source node['pdepend']['phar_url']
  mode 0755
end
