require 'serverspec'
require 'net/ssh'
require 'winrm'

# Windows
if ENV['ansible_connection'] == 'winrm' then

  if ENV['ansible_port'] == '5985' then
    endpoint = "http://#{ENV['TARGET_HOST']}:5985/wsman"
  end
  if ENV['ansible_port'] == '5986' then
    endpoint = "https://#{ENV['TARGET_HOST']}:5986/wsman"
  end
  puts(endpoint)
  set :backend, :winrm
  opts = {
    user: ENV['ansible_user'],
    password: ENV['ansible_password'],
    endpoint: endpoint,
    operation_timeout: 300,
  }
  puts("Test of #{ENV['TARGET_HOST']}")
  winrm = WinRM::Connection.new(opts)
  Specinfra.configuration.winrm = winrm
  
# linux
else
  set :backend, :ssh
  host = ENV['TARGET_HOST']
  options = Net::SSH::Config.for(host)
  options[:user] = ENV['ansible_user']
  options[:password] = ENV['ansible_password']
  puts("Test of #{ENV['TARGET_HOST']}")
  set :host,        options[:host_name] || host
  set :ssh_options, options      
end