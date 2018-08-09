#
# Cookbook Name:: kafka
# Recipe:: pkg_install.rb
#
# Copyright 2015, @WalmartLabs
#
# All rights reserved - Do Not Redistribute

# get kafka version specified for node so appropriate packages can be installed
kafka_version = node.workorder.rfcCi.ciAttributes.version

Chef::Log.info("install patch")
`sudo yum -y install patch`
#`yum -y install redhat-lsb-core`

Chef::Log.info("install zookeeper gem")
chef_gem 'zookeeper' do
  options ('--no-ri  --no-rdoc')
  action :install
end
Chef::Log.info("finished installing zookeeper gem")


kafka_rpm = "kafka-#{kafka_version}.noarch.rpm"

cloud = node.workorder.cloud.ciName
mirror_url_key = "lola"
Chef::Log.info("Getting mirror service for #{mirror_url_key}, cloud: #{cloud}")

mirror_svc = node[:workorder][:services][:mirror]
mirror = JSON.parse(mirror_svc[cloud][:ciAttributes][:mirrors]) if !mirror_svc.nil?
base_url = ''

# Search for Kafka mirror
base_url = mirror[mirror_url_key] if !mirror.nil? && mirror.has_key?(mirror_url_key)

if base_url.empty?
  Chef::Log.error("#{mirror_url_key} mirror is empty for #{cloud}.")
end

if kafka_version.to_i < 1
   kafka_download = base_url + "#{kafka_rpm}"

   execute "remove kafka" do
     user "root"
     exists = <<-EOF
     rpm -qa | grep 'kafka'
     EOF
     command "rpm -e $(rpm -qa '*kafka*'); rm -rf /usr/local/kafka/*"
     only_if exists, :user => "root"
   end

   # download kafka
   remote_file ::File.join(Chef::Config[:file_cache_path], "#{kafka_rpm}") do
     owner "root"
     mode "0644"
     source kafka_download
     action :create
   end

   # install kafka
   execute 'install kafka' do
     user "root"
     cwd Chef::Config[:file_cache_path]
     command "rpm -i #{kafka_rpm} --force"
   end
else
  
   kafka_download = "https://repository.walmart.com/repository/apache-dist-archive/kafka/#{kafka_version}/kafka_2.11-#{kafka_version}.tgz"
   `rm -rf /usr/local/kafka/* && mkdir -p /usr/local/kafka`

   remote_file "/usr/local/kafka/kafka_2.11-#{kafka_version}.tgz" do
     owner "root"
     mode "0644"
     source kafka_download
     action :create
   end

   execute 'install kafka' do
     user "root"
     cwd '/usr/local/kafka'
     command "tar -zxf kafka_2.11-#{kafka_version}.tgz -C /usr/local/kafka --strip-components=1"
   end
end


template "/usr/local/kafka/bin/kafka_status.sh" do
  source "kafka_status.sh.erb"
  owner "root"
  group "root"
  mode  '0755'
end

# remove libconfuse
execute "remove libconfuse" do
  user "root"
  exists = <<-EOF
  rpm -qa | grep 'libconfuse'
  EOF
  command "rpm -e $(rpm -qa 'libconfuse')"
  only_if exists, :user => "root"
end

# install libconfuse.x86_64
if ["redhat", "centos", "fedora"].include?(node["platform"])
  yum_package "libconfuse.x86_64" do
      action :install
  end
else
  Chef::Log.error("we currently support redhat, centos, fedora. You are using some OS other than those.")
end


jmxtrans_rpm = node['kafka']['jmxtrans']['rpm']
jmxtrans_download = base_url + "#{jmxtrans_rpm}"

# remove jmxtrans
execute "remove jmxtrans" do
  user "root"
  exists = <<-EOF
  rpm -qa | grep 'jmxtrans*'
  EOF
  command "rpm -e $(rpm -qa 'jmxtrans*')"
  only_if exists, :user => "root"
end

# download jmxtrans
remote_file ::File.join(Chef::Config[:file_cache_path], "#{jmxtrans_rpm}") do
  owner "root"
  mode "0644"
  source jmxtrans_download
  action :create
end

# install jmxtrans
execute 'install jmxtrans' do
  user "root"
  cwd Chef::Config[:file_cache_path]
  command "rpm -i #{jmxtrans_rpm} --nodeps "
end

kafka_gem_rpm = node['kafka']['gem']['rpm']
kafka_gem_download = base_url + "#{kafka_gem_rpm}"

# remove kafka-gem
execute "remove kafka-gem" do
  user "root"
  exists = <<-EOF
  rpm -qa | grep 'kafka-gem*'
  EOF
  command "rpm -e $(rpm -qa 'kafka-gem*')"
  only_if exists, :user => "root"
end

# download kafka-gem
remote_file ::File.join(Chef::Config[:file_cache_path], "#{kafka_gem_rpm}") do
  owner "root"
  mode "0644"
  source kafka_gem_download
  action :create
end

# install kafka-gem
execute 'install kafka gem' do
  user "root"
  cwd Chef::Config[:file_cache_path]
  command "rpm -i #{kafka_gem_rpm} --force"
end

bash "gem-install" do
  user "root"
  code <<-EOF
  (gem install --local /tmp/ping.gem --no-rdoc --no-ri)
  EOF
end

# make sure /tmp is writable for everyone
bash "tmp-writable" do
  user "root"
  code <<-EOF
  (chmod a+rwx /tmp)
  EOF
end
