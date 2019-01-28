#!/bin/bash
# Script to remove all the unwanted containers and image.

# Script execution get terminated if an error encounters. 
set -e

DEFAULT_FILE="./dockerlist"

# Clear Screen
clear

# Check the default 'dockerlist' file exist in the directory where the script resides. 
# Otherwise read the file name containing list of container names that should be preserved.
if [ -e $DEFAULT_FILE ]; then
  FILE=$DEFAULT_FILE
  echo "Reading preserved container list from $DEFAULT_FILE..."
else
  echo "Enter the filename : "
  read FILE
  # Check if the filename entered exist
  if [ ! -e $FILE ]; then
    echo "File $FILE doesn't exist."
    exit 9
  fi
fi

# Execute the docker command to load all container names in tmp.txt file
echo "`docker ps -a --format '{{.Names}}'`" > tmp.txt 

while read -r DEL_CONTAINER; do
  match=false
  while read -r PRESERVE_CONTAINER; do
    if [ $DEL_CONTAINER == $PRESERVE_CONTAINER ]; then
      match=true
      break
    fi
  done < $FILE
  
  if [ "$match" = false ]; then
    docker stop --time=0 $DEL_CONTAINER 
    docker rm $DEL_CONTAINER
  fi
done < tmp.txt

# Remove all dangling images.
docker image prune -a --force

# Delete the tmp.txt file
rm -rf tmp.txt  
