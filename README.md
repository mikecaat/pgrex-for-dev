# Summary

This repository enables to make [PG-REX 13](https://ja.osdn.net/projects/pg-rex/releases/74642) environments for development use using Vagrant, VirtualBox, and Ansible.

# Requirements

* [Vagrant](https://www.vagrantup.com/). The tested version is 2.2.16.
* [VirtualBox](https://www.virtualbox.org/). The tested version is 6.1.22.
* [Ansible](https://github.com/ansible/ansible). The tested version is 4.2.0.

# Limitation

* Although PG-REX 13 doesn't assume without STONITH environment, this repository doesn't support STONITH now. So, please use this repository for your own risk.
* Although PG-REX 13 assumed the OS is RHEL 8, this repository uses CentOS 8.4 instead to avoid license issues.

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

2. add ssh-config to ~/.ssh/config

```sh
vagrant ssh-config >> ~/.ssh/config
```

3. execute the ansible playbook

```sh
ansible-playbook -i production site.yml
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


# Note

* Update /usr/share/perl5/PGRex/common.pm because pg-rex operation tools don't work properly although this is a workaround.
  * The reason may be that pacemaker version is not the same as PG-REX13's one. PG-REX13 is tested with 2.0.3-5 and 2.0.4-6. But, this repository is tested with 2.0.5.
  * pg-rex operation tools check if the resource is running or not. In the logic, although it uses crm_resource, the return value assumed doesn't seem appropriate. The output of crm_resource is the following, and it doesn't have the last blank, but the common.pm assumes that a blank exists in the last.

```
# crm_resource output example

[root@pgrex02 ~]# crm_resource -r ping-clone -W 2> /dev/null
resource ping-clone is running on: pgrex01
resource ping-clone is running on: pgrex02
```

```
# Fix to remove the last blank. The following is an example.

[root@pgrex02 PGRex]# git diff
diff --git a/common.pm b/common.pm
index 40b4002..a00dc66 100755
--- a/common.pm
+++ b/common.pm
@@ -337,9 +337,9 @@ sub ping_running{
     $array_num = scalar(@resource_id);

     foreach my $id (@resource_id){
-        $result = `$CRM_RESOURCE -r $id -W 2> /dev/null | $GREP \" $my_node \"`;
+        $result = `$CRM_RESOURCE -r $id -W 2> /dev/null | $GREP \" $my_node\"`;
         chomp $result;
-        if ($result eq "resource $id is running on: $my_node "){
+        if ($result eq "resource $id is running on: $my_node"){
             $resource_check_count ++;
         }
     }
```