require 'serverspec'
require 'net/ssh'
require 'winrm'
require 'ansible/vault'

vars = {}

# inject the variables which set in roles directry
Dir::foreach('roles') {|dir|
  if dir == ENV['ansible_role'] then
    Dir::foreach("roles/#{dir}/vars") {|f|
      if f =~ /.yml/ then
        vars = YAML.load(File.open("roles/#{dir}/vars/#{f}").read)
      end  
    }
  end    
}

# inject the variables which set in group vars
Dir::foreach('group_vars') {|file|
  if file == "all.yml" then
    vars = vars.merge(YAML.load(File.open("group_vars/all.yml").read))
  end
  
  if file == "#{ENV['ansible_role']}.yml" then
    vars = vars.merge(YAML.load(File.open("group_vars/#{ENV['ansible_role']}.yml").read))
  end 
}

set_property vars

# Windows
if ENV['ansible_connection'] == 'winrm' then

  if ENV['ansible_port'] == '5985' then
    endpoint = "http://#{ENV['TARGET_HOST']}:5985/wsman"
  end
  if ENV['ansible_port'] == '5986' then
    endpoint = "https://#{ENV['TARGET_HOST']}:5986/wsman"
  end

  set :backend, :winrm
  opts = {
    user: ENV['ansible_user'],
    password: ENV['ansible_password'],
    endpoint: endpoint,
    operation_timeout: 60,
    no_ssl_peer_verification: true
  }
  puts("Test for #{ENV['TARGET_HOST']}")
  winrm = WinRM::Connection.new(opts)
  Specinfra.configuration.winrm = winrm
  
# linux
else
  set :backend, :ssh
  host = ENV['TARGET_HOST']
  options = Net::SSH::Config.for(host)
  options[:user] = ENV['ansible_user']
  options[:password] = ENV['ansible_password']
  puts("Test for #{ENV['TARGET_HOST']}")
  set :host,        options[:host_name] || host
  set :ssh_options, options      
end