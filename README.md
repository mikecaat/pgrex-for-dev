# Summary

This repository enables to make [PG-REX 14](https://ja.osdn.net/projects/pg-rex/releases/p18934) environments for development use using Vagrant, VirtualBox, and Ansible.

# Requirements

* [Vagrant](https://www.vagrantup.com/). The tested version is 2.2.19.
* [VirtualBox](https://www.virtualbox.org/). The tested version is 6.1.38.
* [Ansible](https://github.com/ansible/ansible). The tested version is 4.2.0.

# Limitation

* Although PG-REX 14 doesn't assume without STONITH environment, it modifies /usr/local/share/perl5/PGRex/common.pm to disable STONITH. So, please use it for your own risk.
* Although PG-REX 14 assumed the OS is RHEL 8, this repository uses Rockey Linux 8.5 instead to avoid license issues.

# Preparation

* install ansible and so on

```sh
virtualenv .venv
source .venv/bin/activate
pip3 install -r requirements.txt
```

# Making the PG-REX environments

1. make virtual machines with Vagrant

```sh
vagrant up
```

If the following error happened, you need to update packages manually.

> Error: Unable to find a match: kernel-devel-4.18.0-348.20.1.el8_5.x86_64

```sh
vagrant ssh pgrex01
[pgrex01] sudo dnf -y update
[pgrex01] exit
vagrant reload --provision
vagrant up  # start pgrex02 and fix the same issue.
```

2. add ssh-config to ~/.ssh/config

```sh
vagrant ssh-config >> ~/.ssh/config
```

3. execute the ansible playbook

```sh
ansible-playbook -i development site.yml
```

# Create the PG-REX cluster

1. login pgrex01

```sh
vagrant ssh pgrex01
```

2. start primary

* you can see the PG-REX manual in detail

```
[vagrant@pgrex01 ~]# sudo su -
[root@pgrex01 ~]# pg-rex_primary_start PG-REX_pm_pcsgen_env.xml
# default password is 'root'
```

3. login pgrex02

```sh
vagrant ssh pgrex02
```

4. start secondary

* you can see the PG-REX manual in detail

```
[vagrant@pgrex02 ~]$ sudo su -
[root@pgrex02 ~]# pg-rex_standby_start
# default password is 'root'
```

5. check if working properly

* you can see the PG-REX manual in detail
* STONITH is not supported in this repository.

```
[root@pgrex02 ~]# pcs status --full
```
