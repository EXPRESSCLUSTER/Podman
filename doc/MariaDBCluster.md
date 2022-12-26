# MariaDB Cluster with EXPRESSCLUSTER

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
- MIRACLE LINUX 8.4 (4.18.0-305.25.1.el8_4.x86_64)
  - Podman (3.4.2)
  - EXPRESSCLUSTER X 5.0 (5.0.1-1)

## Prerequisite
- Install EXPRESSSCLUSTER and create a cluster. For details, refer to [Installation and Configuration Guide](https://docs.nec.co.jp/sites/default/files/minisite/static/1639a2de-5285-471a-817b-d0b98603d987/ecx_x50_linux_en/index.html).
- Add the following resources.
  - Mirror Disk Resource
    - Mount Point: /mnt/md1
  - Floating IP Resource
- Install podman and mariadb on both nodes.
  ```sh
  dnf install podman mariadb
  ```

## Clustering
1. Start Cluster WebUI and add Exec Resource.
1. Edit start.bat and stop.bat as below.
   - [start.bat](../script/MariaDB/start.sh)
   - [stop.bat](../script/MariaDB/sop.sh)
1. Recommend to enable script log.
   - Resource Properties
     1. [Details] tab
     1. [Tuning]
     1. [Maintenance] tab
        - Log Output Path: /opt/nec/clusterpro/log/exec-mariadb1
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
       failover1 .......: Online           Group for MariaDB
         current        : server1
         exec-mariadb   : Online
         md1            : Online
     <monitor>
       mdnw1            : Normal
       mdw1             : Normal
       userw            : Normal           User mode monitor
    =====================================================================
   ```
## Add Database Monitor
1. On Cluster WebUI, add MySQL Monitor Resource as below.
   - Monitor Level: Level 2
   - Database Name: watch
   - IP Address: 127.0.0.1
   - Port: 3306
   - User Name: root
   - Password: password
   - Table: mysqlwatch
   - Storage Engine: InnoDB
   - Library Path: /usr/lib64/libmariadb.so.3
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
       failover1 .......: Online           Group for MariaDB
         current        : server1
         exec-mariadb   : Online
         md1            : Online
     <monitor>
       mdnw1            : Normal
       mdw1             : Normal
       mysqlw           : Normal
       userw            : Normal           User mode monitor
    =====================================================================
   ```


<!--
1. If you have a proxy server, run the following command to pull images.
   ```sh
   export HTTP_PROXY=<your proxy server>
   ```
   ```sh
   export HTTPS_PROXY=<your proxy server>
   ```
1. Pull MariaDB container image on both servers.
   ```sh
   podman pull docker.io/library/mariadb:latest
   ```
1. Start the failover group on server1.
1. Run the following command on server1 to create and run MariaDB container.
   ```sh
   podman run --name mariadb1 -v /mnt/md1:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=watch -p 3306:3306 -d mariadb:latest
   ```
1. Login MadiaDB and check if the database (e.g. watch) is created.
   ```
   podman exec -it mariadb1 bash
   root@7afa0a7d8d7a:/# mysql -u root -p
   Enter password:
   Welcome to the MariaDB monitor.  Commands end with ; or \g.
   Your MariaDB connection id is 4
   Server version: 10.8.3-MariaDB-1:10.8.3+maria~jammy mariadb.org binary distribution
   
   Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.
   
   Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
   
   MariaDB [(none)]> show databases;
   +---------------------+
   | Database            |
   +---------------------+
   | #mysql50#lost+found |
   | information_schema  |
   | mysql               |
   | performance_schema  |
   | sys                 |
   | watch               |
   +---------------------+
   6 rows in set (0.012 sec)
   ```
1. Exit from the container.
   ```
   MariaDB [(none)]> quit
   Bye
   root@7afa0a7d8d7a:/# exit
   exit
   ```
1. Run the following command on server1 to stop the container.
   ```sh
   podman stop mariadb1
   ```
1. Move the failover group to server2.
   ```sh
   clpgrp -m failover1
   ```
1. Run the following command on server2 to create MariaDB container.
   ```sh
   podman create --name mariadb1 -v /mnt/md1:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=watch -p 3306:3306 mariadb:latest
   ```
1. Start Cluster WebUI and add Exec Resource as below.
   - start.sh
     ```sh
     #! /bin/sh
     #***************************************
     #*              start.sh               *
     #***************************************
     
     #ulimit -s unlimited
     
     podman start mariadb1
     
     echo "EXIT"
     exit 0
     ```    
   - stop.sh
     ```sh
     #! /bin/sh
     #***************************************
     #*               stop.sh               *
     #***************************************
     
     #ulimit -s unlimited
     
     podman stop mariadb1
     
     echo "EXIT"
     exit 0
     ```
1. On Cluster WebUI, add MySQL Monitor Resource as below.
   - Monitor Level: Level 2
   - Database Name: watch
   - IP Address: 127.0.0.1
   - Port: 3306
   - User Name: root
   - Password: password
   - Table: mysqlwatch
   - Storage Engine: InnoDB
   - Library Path: /usr/lib64/libmariadb.so.3
1. Click [Apply the Configuration File].
1. Check the cluster status.
   ```sh
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
       failover1 .......: Online           Group for MariaDB
         current        : server1
         exec-mariadb1  : Online
         md1            : Online
     <monitor>
       mdnw1            : Normal
       mdw1             : Normal
       mysqlw1          : Normal
       userw1           : Normal           User mode monitor
    =====================================================================
   ```
-->