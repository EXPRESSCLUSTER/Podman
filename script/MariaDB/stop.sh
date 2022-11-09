#! /bin/sh
#***************************************
#*               stop.sh               *
#***************************************

#===================================
# Set the following parameters
#-----------------------------------
name=mariadb1
#===================================

# Stop the container
podman stop $name
if [ $? -eq 0 ]; then
    echo "Suceeded to stop $name."
else
    echo "Failed to stop $name."
    exit 1
fi

exit 0
