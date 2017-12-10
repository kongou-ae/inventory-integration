require 'rake'
require 'rspec/core/rake_task'
require 'ansible/vault'
require 'yaml'

def setEnvVar(server)
  ENV['ansible_user'] = server[:var]['ansible_user'] if server[:var]['ansible_user']
  ENV['ansible_password'] = server[:var]['ansible_password'] if server[:var]['ansible_password']
  ENV['ansible_become_pass'] = server[:var]['ansible_become_pass'] if server[:var].has_key?('ansible_become_pass')
  ENV['ansible_ssh_private_key_file'] = server[:var]['ansible_ssh_private_key_file'] if server[:var].has_key?('ansible_ssh_private_key_file')
          
  # support windows
  if server[:var].has_key?('ansible_connection') then
    if server[:var]['ansible_connection'] == 'winrm' then
      ENV['ansible_port'] = server[:var]['ansible_port'].to_s
      ENV['ansible_connection'] = server[:var]['ansible_connection']
      ENV['ansible_winrm_server_cert_validation'] = server[:var]['ansible_winrm_server_cert_validation']
    end
  end
end

# whether hosts is encrypt or not.
if File.open('./hosts.yml').read.include?('$ANSIBLE_VAULT;') == true then
  print 'Rakefile: innput the password of ansible-vault: '
  system "stty -echo"
  password = $stdin.gets.chop
  ENV['VAULT_PASS'] = password
  system "stty echo"
  puts ''
  contents = Ansible::Vault.read(path: './hosts.yml', password: password)
else
  contents = File.open('./hosts.yml').read
end


# build hash from hosts.yaml
inventory = YAML.load(contents)
hosts = []
i = 0
inventory.each do |role,value|
  if role != "_meta" then
    hosts.push({
      :role => role,
      :server => [] #Array.new { Array.new }
    })
    value['hosts'].each do |host,variable|
      hosts[i][:server].push({
        :name => host,
        :var => variable    
      })
    end
    i = i + 1
  end
end

namespace :spec do
  desc "Run serverspec to all hosts"
  task :all => hosts.map {|host| 'spec:' + host[:role]}
  task :default  => :all

  hosts.each do |host|
    desc "Run serverspec to hosts of #{host[:role]}"
    host[:server].each do |server|
      RSpec::Core::RakeTask.new(host[:role].to_sym) do |t|
        ENV['TARGET_ROLE'] = host[:role]
        ENV['TARGET_HOST'] = server[:name]
        ENV['ansible_role'] = host[:role]
        if server[:var]
          setEnvVar(server)
        end
        t.pattern = 'spec/{' + host[:role] + '}/*_spec.rb'
      end
    end
  end
  
  hosts.each do |host|
    namespace host[:role] do
      host[:server].each do |server|
        desc "Run serverspec to #{server[:name]}"
        RSpec::Core::RakeTask.new(server[:name].to_sym) do |t|
          ENV['TARGET_ROLE'] = host[:role]
          ENV['TARGET_HOST'] = server[:name]
          ENV['ansible_role'] = host[:role]
          if server[:var]
            setEnvVar(server)
          end
          t.pattern = 'spec/{' + host[:role] + '}/*_spec.rb'
        end
      end
    end
  end
end
