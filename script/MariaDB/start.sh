#! /bin/sh
#***************************************
#*              start.sh               *
#***************************************

#=======================================
# Set the following parameters
#---------------------------------------
name=mariadb1
mount=/mnt/md1
pass=password
database=watch
port=3306
version=10.9.3
#=======================================

# Create the container
# export https_proxy=<your proxy server>
podman create \
--name $name \
-v $mount:/var/lib/mysql \
-e MYSQL_ROOT_PASSWORD=$pass \
-e MYSQL_DATABASE=$database \
-p $port:3306 \
docker.io/library/mariadb:$version
ret=$?
if [ $ret -eq 0 ]; then
    echo "Suceeded to create $name."
elif [ $ret -eq 125 ]; then
    echo "$name is already in use."
else
    echo "Failed to ceate $name."
    exit 1
fi

# Start the container
podman start $name
if [ $? -eq 0 ]; then
    echo "Suceeded to start $name."
else
    echo "Failed to start $name."
    exit 1
fi

exit 0
