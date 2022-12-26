#! /bin/sh
#***************************************
#*              start.sh               *
#***************************************

#===================================
# Set the following parameters
#-----------------------------------
name=postgres1
mount=/mnt/disk1
pass=password
database=watch
port=5432
version=15.1-bullseye
#===================================

# Create the container
# export https_proxy=<your proxy server>
podman create \
--name $name \
-v $mount:/var/lib/postgresql/data \
-e POSTGRES_PASSWORD=$pass \
-e POSTGRES_DB=$database \
-p $port:5432 \
docker.io/library/postgres:$version
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
