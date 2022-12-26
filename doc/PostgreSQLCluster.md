# PostgreSQL Cluster with EXPRESSCLUSTER

## Index
- [Evaluation Environment](#evaluation-environment)
- [Prerequisite](#prerequisite)
- [Clustering](#clustering)
- [Add Database Monitor](#add-database-monitor)

## Evaluation Environment
```
  +------------------------+
  | server1                |   +-------------+
  | - MIRACLE LINUX        |   |             |
  | - Podman               +---+ Mirror Disk |
  | - EXPRESSCLUSTER X 5.0 |   |             |
  +------------------------+   +------|------+
                                      | Mirroring
  +------------------------+   +------V------+
  | server2                |   |             |
  | - MIRACLE LINUX        +---+ Mirror Disk |
  | - Podman               |   |             |
  | - EXPRESSCLUSTER X 5.0 |   +-------------+
  +------------------------+
```
- MIRACLE LINUX 8.6 (4.18.0-372.32.1.el8_6.x86_64)
  - Podman (4.1.1)
  - EXPRESSCLUSTER X 5.0 (5.0.2-1)

## Prerequisite
- Install EXPRESSSCLUSTER and create a cluster. For details, refer to [Installation and Configuration Guide](https://docs.nec.co.jp/sites/default/files/minisite/static/1639a2de-5285-471a-817b-d0b98603d987/ecx_x50_linux_en/index.html).
- Add the following resources.
  - Mirror Disk Resource
    - Mount Point: /mnt/md1
  - Floating IP Resource
- Install podman and postgresql on both nodes.
  ```sh
  dnf install podman postgresql
  ```

## Clustering
1. Start Cluster WebUI and add Exec Resource.
1. Edit start.bat and stop.bat as below.
   - [start.bat](../script/PostgreSQL/start.sh)
   - [stop.bat](../script/PostgreSQL/sop.sh)
1. Recommend to enable script log.
   - Resource Properties
     1. [Details] tab
     1. [Tuning]
     1. [Maintenance] tab
        - Log Output Path: /opt/nec/clusterpro/log/exec-postgres
        - Rotate Log: Check
1. Click [Apply the Configuration File].
1. Start the failover group.
1. Check the cluster status.
   ```
   [root@server1 ~]# clpstat
    ========================  CLUSTER STATUS  ===========================
     Cluster : cluster
     <server>
      *server1 .........: Online           Primary server
         lankhb1        : Normal           Kernel Mode LAN Heartbeat
         httpnp1        : Normal           http resolution
       server2 .........: Online           Secondary server
         lankhb1        : Normal           Kernel Mode LAN Heartbeat
         httpnp1        : Normal           http resolution
     <group>
       failover1 .......: Online           Group for PostgreSQL
         current        : server1
         exec-postgres  : Online
         md1            : Online
     <monitor>
       mdnw             : Normal
       mdw              : Normal
       userw            : Normal           User mode monitor
    =====================================================================
   ```
## Add Database Monitor
1. On Cluster WebUI, add PostgreSQL Monitor Resource as below.
   - Monitor Level: Level 2
   - Database Name: watch
   - IP Address: 127.0.0.1
   - Port: 5432
   - User Name: postgres
   - Password: password
   - Table: psqlwatch
   - Library Path: /usr/lib64/libpq.so.5
1. Click [Apply the Configuration File].
1. Check the cluster status.
   ```
   [root@server1 ~]# clpstat
    ========================  CLUSTER STATUS  ===========================
     Cluster : cluster
     <server>
      *server1 .........: Online           Primary server
         lankhb1        : Normal           Kernel Mode LAN Heartbeat
         httpnp1        : Normal           http resolution
       server2 .........: Online           Secondary server
         lankhb1        : Normal           Kernel Mode LAN Heartbeat
         httpnp1        : Normal           http resolution
     <group>
       failover1 .......: Online           Group for PostgreSQL
         current        : server1
         exec-postgres  : Online
         md1            : Online
     <monitor>
       mdnw1            : Normal
       mdw1             : Normal
       psqlw            : Normal
       userw            : Normal           User mode monitor
    =====================================================================
   ```
