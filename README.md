# inventory-integration

Proof of Concept that serverspec uses the inventory of ansible.

![tty](tty.gif)

# Notes

- You must write the inventory of ansible in yaml.
- Only load the custom variables for role. Don't load the custom variables per host.
- Serverspec expects that the inventory of ansible is on '../ansible/hosts.yml'. If the location of your hosts is not so, Please change 'Rakefile' and 'spec_helper.rb'
- Support ansible-vault. But only support '--ask-vault-pass'. 
