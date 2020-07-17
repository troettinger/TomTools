#!/bin/bash

HERE=`dirname $0`
cd $HERE

which ansible-playbook > /dev/null 2>&1 || sudo ./install_prereqs.sh

ansible-playbook -i hosts playbook-ha.yml -e @config.yml
