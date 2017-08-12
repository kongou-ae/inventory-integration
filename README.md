# inventory-integration

Proof of Concept that serverspec uses the inventory of ansible.

![tty](tty.gif)

# Notes

- You must write the inventory of ansible in yaml.
- Serverspec expects that the inventory of ansible is on '../ansible/hosts.yml'. If the location of your hosts is not so, Please change 'Rakefile' and 'spec_helper.rb'

