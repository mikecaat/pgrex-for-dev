cibadmin --empty > PG-REX_pm_pcsgen_env.xml

### Cluster Option
pcs -f PG-REX_pm_pcsgen_env.xml property set priority-fencing-delay=10s

### Resource Defaults
pcs -f PG-REX_pm_pcsgen_env.xml resource defaults update resource-stickiness=200
pcs -f PG-REX_pm_pcsgen_env.xml resource defaults update migration-threshold=1

### Primitive Configuration
pcs -f PG-REX_pm_pcsgen_env.xml resource create ipaddr-primary ocf:heartbeat:IPaddr2 \
    ip="192.168.1.11" nic="eth1" cidr_netmask="24" \
    op start timeout=60s on-fail=restart \
    monitor timeout=60s interval=10s on-fail=restart \
    stop timeout=60s on-fail=fence

### Primitive Configuration
pcs -f PG-REX_pm_pcsgen_env.xml resource create ipaddr-replication ocf:heartbeat:IPaddr2 \
    ip="192.168.2.30" nic="eth2" cidr_netmask="24" \
    meta migration-threshold="0" \
    op start timeout=60s on-fail=stop \
    monitor timeout=60s interval=10s on-fail=restart \
    stop timeout=60s on-fail=ignore

### Group Configuration
pcs -f PG-REX_pm_pcsgen_env.xml resource group add primary-group ipaddr-primary ipaddr-replication

### Primitive Configuration
pcs -f PG-REX_pm_pcsgen_env.xml resource create ipaddr-standby ocf:heartbeat:IPaddr2 \
    ip="192.168.1.21" nic="eth1" cidr_netmask="24" \
    meta resource-stickiness="1" \
    op start timeout=60s on-fail=restart \
    monitor timeout=60s interval=10s on-fail=restart \
    stop timeout=60s on-fail=fence

### Primitive Configuration
pcs -f PG-REX_pm_pcsgen_env.xml resource create pgsql ocf:linuxhajp:pgsql \
    pgctl="/usr/pgsql-13/bin/pg_ctl" psql="/usr/pgsql-13/bin/psql" pgdata="/dbfp/pgdata/data" pgdba="postgres" pgport="5432" pgdb="template1" rep_mode="sync" node_list="pgrex01 pgrex02" master_ip="192.168.2.30" restore_command="/bin/cp /dbfp/pgarch/arc1/%f %p" repuser="repuser" primary_conninfo_opt="keepalives_idle=60 keepalives_interval=5 keepalives_count=5" stop_escalate="0" xlog_check_count="0" \
    op start timeout=300s interval=0s on-fail=restart \
    monitor timeout=60s interval=10s on-fail=restart \
    monitor timeout=60s interval=9s on-fail=restart role=Master \
    promote timeout=300s interval=0s on-fail=restart \
    demote timeout=300s interval=0s on-fail=fence \
    notify timeout=60s interval=0s \
    stop timeout=300s interval=0s on-fail=fence

### Promotable Clone Configuration
pcs -f PG-REX_pm_pcsgen_env.xml resource promotable pgsql
pcs -f PG-REX_pm_pcsgen_env.xml resource meta pgsql-clone promoted-max=1 promoted-node-max=1 clone-max=2 clone-node-max=1 notify=true priority=1

### Primitive Configuration
pcs -f PG-REX_pm_pcsgen_env.xml resource create ping ocf:pacemaker:ping \
    name="ping-status" host_list="192.168.1.1" attempts="2" timeout="2" debug="true" \
    op start timeout=60s on-fail=restart \
    monitor timeout=60s interval=10s on-fail=restart \
    stop timeout=60s on-fail=fence

### Clone Configuration
pcs -f PG-REX_pm_pcsgen_env.xml resource clone ping

### STONITH Configuration
pcs -f PG-REX_pm_pcsgen_env.xml stonith create fence1-ipmilan fence_ipmilan \
    pcmk_host_list="pg-rex41" ip="172.20.145.87" username="Administrator" password="MKTZ9FFG" lanplus="1" \
    op start timeout=60s on-fail=restart \
    monitor timeout=60s interval=3600s on-fail=restart \
    stop timeout=60s on-fail=ignore

### STONITH Configuration
pcs -f PG-REX_pm_pcsgen_env.xml stonith create fence2-ipmilan fence_ipmilan \
    pcmk_host_list="pg-rex42" ip="172.20.145.88" username="Administrator" password="NJWQP62X" lanplus="1" \
    op start timeout=60s on-fail=restart \
    monitor timeout=60s interval=3600s on-fail=restart \
    stop timeout=60s on-fail=ignore

### Resource Location
pcs -f PG-REX_pm_pcsgen_env.xml constraint location fence1-ipmilan avoids pg-rex41
pcs -f PG-REX_pm_pcsgen_env.xml constraint location fence2-ipmilan avoids pg-rex42
pcs -f PG-REX_pm_pcsgen_env.xml constraint location ipaddr-standby rule score=200 pgsql-status eq HS:sync
pcs -f PG-REX_pm_pcsgen_env.xml constraint location ipaddr-standby rule score=100 pgsql-status eq PRI
pcs -f PG-REX_pm_pcsgen_env.xml constraint location ipaddr-standby rule score=-INFINITY not_defined pgsql-status
pcs -f PG-REX_pm_pcsgen_env.xml constraint location ipaddr-standby rule score=-INFINITY pgsql-status ne HS:sync and pgsql-status ne PRI
pcs -f PG-REX_pm_pcsgen_env.xml constraint location pgsql-clone rule score=-INFINITY not_defined ping-status or ping-status lt 1

### Resource Colocation
pcs -f PG-REX_pm_pcsgen_env.xml constraint colocation add pgsql-clone with ping-clone score=INFINITY
pcs -f PG-REX_pm_pcsgen_env.xml constraint colocation add primary-group with master pgsql-clone score=INFINITY

### Resource Order
pcs -f PG-REX_pm_pcsgen_env.xml constraint order ping-clone then pgsql-clone symmetrical=false
pcs -f PG-REX_pm_pcsgen_env.xml constraint order promote pgsql-clone then start primary-group symmetrical=false
pcs -f PG-REX_pm_pcsgen_env.xml constraint order demote pgsql-clone then stop primary-group kind=Optional symmetrical=false
