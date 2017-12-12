require 'serverspec'
require 'net/ssh'
require 'winrm'
require 'ansible/vault'

vars = {}

puts ENV['ansible_become_pass']
puts ENV['ansible_password']

def read_with_vault(filename)
  if File.open(filename).read.include?('$ANSIBLE_VAULT;') == true then
    contents = Ansible::Vault.read(path: filename, password: ENV['VAULT_PASS'])
  else
    contents = File.open(filename).read
  end
  return contents
end

# inject the variables which set in roles directry
Dir::foreach('roles') {|dir|
  if dir == ENV['ansible_role'] then
    Dir::foreach("roles/#{dir}/vars") {|f|
      if f =~ /.yml/ then
        vars = YAML.load(read_with_vault("roles/#{dir}/vars/#{f}"))
      end  
    }
  end    
}

# inject the variables which set in group vars
Dir::foreach('group_vars') {|file|
  if file == "all.yml" then
    vars = vars.merge(YAML.load(read_with_vault("group_vars/all.yml")))
  end
  
  if file == "#{ENV['ansible_role']}.yml" then
    vars = vars.merge(YAML.load(read_with_vault("group_vars/#{ENV['ansible_role']}.yml")))
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
  set :disable_sudo, true
  set :backend, :ssh
  host = ENV['TARGET_HOST']
  options = Net::SSH::Config.for(host)
  options[:user] = ENV['ansible_user']
  options[:password] = ENV['ansible_password'] if not ENV['ansible_password'].nil?
  options[:keys] = ENV['ansible_ssh_private_key_file'] if not ENV['ansible_ssh_private_key_file'].nil?
  puts("Test for #{ENV['TARGET_HOST']}")
  set :host,        options[:host_name] || host
  set :ssh_options, options
  set :sudo_password, ENV['ansible_become_pass'] if not ENV['ansible_become_pass'].nil?
  #set :sudo_options, 'su -'
end
