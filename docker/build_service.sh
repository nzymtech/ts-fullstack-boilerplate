#!/bin/bash

# Check if the service folder is present. 
if [ -z "$1"]; then
	echo "Usage: $0 <foldername>"
	exit 1
fi

# Assign the first argument to a variable 
SERVICE_NAME="$1"

# Check if the service folder exists
if [ ! -d "$SERVICE_NAME" ]; then
	echo "Error: Service folder $SERVICE_NAME does not exist";
	exit 1
fi

# Copy the dockerfile of the service to the root folder
cp "./docker/$SERVICE_NAME/Dockerfile" .

# Print success message 
echo "Dockerfile for $SERVICE_NAME copied successfully"

# Run build command for the dockerfile
docker build -t "$SERVICE_NAME" .

# Checking of the docker build was successfull
if [ $? -eq 0]; then 
	echo "Docker build was successful"
else 
	echo "Docker build failed"
fi 

# Delete the Dockerfile 
rm Dockerfile

exit 1




















