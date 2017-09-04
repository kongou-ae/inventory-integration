# inventory-integration

Proof of Concept that serverspec uses the inventory of ansible.

![tty](tty.gif)

# Notes

- You must write the inventory of ansible in yaml.
- This script Loads the variables from following directory and file. 
    - roles/[ansible's group name]/vars/main.yml
    - group_vars/[ansible's group name].yml
    - group_vars/all.yml
- Support ansible-vault. But only support '--ask-vault-pass'. 
