# Squid transparent proxy setup

This repository contains playbooks that will set up a squid transparent proxy in HA mode. The only file you need to edit or care about is the ```config.yml``` file. The config itself is fairly well documented.

## What you will need

  * Three bare metal servers or three virtual machines installed with CentOS 8
  * The 3 servers need to be on the same network
  * A VIP (Virtual IP) in the same network as the 3 servers

Optional settings:

  * A CA certificate and CA key, concatenated in a single file. This will be used to generate certificates dinamically. If no bundle is provided, one will be generated automatically. You will be able to grab it from the /etc/squid folder on any of the 3 servers. 

This playbook was tested on a 3 node environment running CentOS 8. Running it on other OS' may not work.


## Before you begin

  * Each node must have a proper hostname set
  * Each hostname must be unique inside the cluster. Having multiple nodes with the same hostname will not result in a working cluster.
  * Make sure that the hostname does not point to ```127.0.0.1``` inside your ```/etc/hosts``` file.
  * Set static IP addresses on all nodes

Your ```/etc/hosts``` file should only have the following entries:

```bash
127.0.0.1	localhost

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

This playbook will add the necessary entries in ```/etc/hosts``` when you run it.

Secondly, each squid node must be able to access the CentOS software repositories in order for it to work.


## Running the playbook

On your machine, you will need to install ansible:

```bash
python3 -m venv $HOME/ansible-venv
source $HOME/ansible-venv/bin/activate
pip3 install ansible
```

Or you can install it from your distributions repository:

```bash
yum -y install epel-release
yum -y install ansible git wget
```

Generate a new SSH public/private key pair. If you already have one, skip this step:

```bash
ssh-keygen -t rsa -b 4096
```

On each of the 3 nodes, install and enable SSH server:

```bash
yum -y install openssh-server
systemctl enable sshd
systemctl start sshd
```

Copy your ssh key to each of the nodes:

```bash
ssh-copy-id -i $HOME/.ssh/id_rsa.pub root@<IP of squid server 1>
ssh-copy-id -i $HOME/.ssh/id_rsa.pub root@<IP of squid server 2>
ssh-copy-id -i $HOME/.ssh/id_rsa.pub root@<IP of squid server 3>
```

Download/clone the repository:

```bash
git clone https://github.com/cloudbase/AzureStackWorkloads
```

Change directory into the ```squid-ha``` folder:

```bash
cd AzureStackWorkloads/squid-ha
```

You should have a folder structure like the following:

```bash
gabriel@rossak:~/squid-ha$ tree -L 2
.
├── config.yml
├── deploy.sh
├── files
│   ├── broken-but-trusted.txt
│   ├── tunneled.txt
│   └── whitelisted.txt
├── hosts
├── install_prereqs.sh
├── playbook-ha.yml
├── roles
│   ├── ondrejhome.ha-cluster-pacemaker
│   └── ondrejhome.pcs-modules-2
└── templates
    └── squid.conf.j2
```

We need to edit 2 files: ```hosts``` and ```config.yml```

The ```hosts``` file contains the ip addresses of your 3 nodes:

```ini
[squid]
10.78.220.133
10.78.220.26
10.78.220.118
```

Simply add each IP address on a new line, under the ```squid``` section.

Next, edit the ```config.yml``` to match your desired setup. Pay close attention to the comments in that file, as they best describe each option and what it does.

Once you're finished editing that file, run the playbook:

```bash
gabriel@rossak:~/squid-ha$ ./deploy.sh 
```

This will set up Squid, will create the necessary firewall rules, will create the cluster and add the cluster IP. At the end of the run, you should have a fully functional HA transparent proxy you can direct your HTTP and HTTPS traffic to.


## Important considetarions

This setup is meant to work as a transparent proxy, in intercept mode. It is not meant to work as an explicit proxy. As such, there are some things you need to know.

### Modes of operation

There are currently two modes of operation for this transparent proxy:

  * bump
  * splice
  
  When in Bump mode, a certificate gets automatically generated by the squid transparent proxy, and is used to mimic the website you are accessing. for this mode to work successfully, you will need to import the CA certificate used by your squid server, on each client that uses your proxy. That CA certificate needs to be trusted.
  
  When in Splice mode, all traffic will be tunneled between the client and the server. Squid acts as a TCP proxy between clients and destinations.

### Dealing with DNS traffic managers

Both the clients and the squid proxy servers should use the same DNS servers. This is needed because Squid validates that the IP the client resolves a domain to, and the IP address the server resolved the same domain to, match. This is a security measure, and currently it cannot be disabled when in transparent mode. This means that if you use a DNS traffic manager that returns just one IP address in a round robin fashion, you will run into errors on ocasion. Setting the same DNS server for both clients and squid will mitigate this to some extent.

### Whitelists and tunneling

There are 3 files that deal with domains that clients are allowed to access and the method by which they are served by the proxy. These whitelists act a little bit differently based on the mode of operation used (splice or bump). The three files are:

  * whitelisted.txt
  * tunneled.txt
  * broken-but-trusted.txt
  
  When in Bump mode, anything that is added to ```whitelisted.txt``` will get proxied. Anything that is in ```broken-but-trusted.txt``` will be proxied, even if the certificate used by those endpoints is not trusted by the squid proxy. You can use this file for domains which are trusted by some clients but not squid itself. The ```tunneled.txt``` is a special allow list which acts like a "force splice" for particular domains. Anything in this file will be spliced, not bumped.
  
  When in Splice mode, all 3 files will be used to splice traffic directly.
  
To disable whitelists completely, set ```squid_use_whitelist``` to ```false``` in ```config.yaml```. 