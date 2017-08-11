require 'serverspec'
require 'net/ssh'
require 'winrm'
require 'ansible/vault'

# whether hosts is encrypt or not.
if File.open('../ansible/hosts.yml').read.include?('$ANSIBLE_VAULT;') == true then
  print 'spec_helper: innput the password of ansible-vault: '
  system "stty -echo"
  password = $stdin.gets.chop
  system "stty echo"
  puts ''
  contents = Ansible::Vault.read(path: '../ansible/hosts.yml', password: password)
else
  contents = File.open('../ansible/hosts.yml').read
end

# inject property from hosts.yml
properties = YAML.load(contents)
set_property properties[ENV['ansible_role']]['vars']

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