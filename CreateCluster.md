# Create a Cluster with EXPRESSCLUSTER

## Index
- [Evaluation Environment](#evaluation-environment)
- [Prerequisite](#prerequisite)
- [MariaDB Clustering](#mariadb-clustering)

## Evaluation Environment
- Oracle Linux 8.3 (4.18.0-193.28.1.el8_2.x86_64)
- Podman (2.0.5)
- EXPRESSCLUSTER X 4.2
  ```
  +------------------------+
  | Node #1 (node1)        |   +-------------+
  | - Oracle Linux 8.3     |   |             |
  | - Podman               +---+ Mirror Disk |
  | - EXPRESSCLUSTER X 4.2 |   |             |
  +------------------------+   +------|------+
                                      | Mirroring
  +------------------------+   +------V------+
  | Node #2 (node2)        |   |             |
  | - Oracle Linux 8.3     +---+ Mirror Disk |
  | - Podman               |   |             |
  | - EXPRESSCLUSTER X 4.2 |   +-------------+
  +------------------------+
  ```
## Prerequisite
- Install EXPRESSSCLUSTER and create a cluster. For details, refer to **Installation and Configuration Guide**.
  - https://www.manuals.nec.co.jp/contents/system/files/nec_manuals/node/505/L42_IG_EN/index.html
- Add the following resources.
  - Mirror Disk Resource
    - Mount Point: /mnt/md1
  - Floating IP Resource
- Install Podman.
  ```sh
  # dnf install podman
  ```

## MariaDB Clustering
1. Install install mysql-libs on both servers.
   ```sh
   # dnf install mysql-libs
   ```
1. If you have a proxy server, run the following command to pull images.
   ```sh
   # export HTTP_PROXY=<your proxy server>
   ```
1. Pull MariaDB container image on both servers.
   ```sh
   # podman pull mariadb
   ```
1. Start the failover group on node1.
1. Run the following command on node1 to create and run MariaDB container.
   ```sh
   # podman run --name mariadb1 -v /mnt/md1:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=watch -e -p 3306:3306 -d mariadb:latest
   ```
1. Run the following command on node2 to create MariaDB container.
   ```sh
   # podman create --name mariadb1 -v /mnt/md1:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=watch -e -p 3306:3306 -d mariadb:latest
   ```
1. Run the following command on node1 to stop the container.
   ```sh
   # podman stop mariadb1
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
   - Database Name: watch
   - IP Address: 127.0.0.1
   - Port: 3306
   - User Name: root
   - Password: password
   - Table: mysqlwatch
   - Storage Engine: InnoDB
   - Library Path: /usr/lib64/mysql/libmysqlclient.so.21
1. Click [Apply the Configuration File].
1. Check the cluster status.
   ```sh
   # clpstat --long
    ========================  CLUSTER STATUS  ===========================
     Cluster : cluster
     <server>
      *node1 ............................: Online
         lankhb1                         : Normal           Kernel Mode LAN Heartbe
         lankhb2                         : Normal           Kernel Mode LAN Heartbe
       node2 ............................: Online
         lankhb1                         : Normal           Kernel Mode LAN Heartbe
         lankhb2                         : Normal           Kernel Mode LAN Heartbe
     <group>
       failover-mariadb1 ................: Online
         current                         : node1
         exec-mariadb1                   : Online
         md1                             : Online
     <monitor>
       mdnw1                             : Normal
       mdw1                              : Normal
       mysqlw1                           : Normal
    =====================================================================
   ```
