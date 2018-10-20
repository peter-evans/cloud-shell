#!/bin/bash

# Fetch configuration
source cloud-shell.cfg

if [ $1 == "up" ]; then

	# Check for an existing instance
	if [ -e INSTANCE.cfg ]; then

		echo "ERROR: Active instance found. (INSTANCE.cfg present)"

	else

		# Create new instance name
		printf -v INSTANCEID '%x' $(printf '%.2s ' $((RANDOM%16))' '{00..8})		
		INSTANCE="cloud-shell-$INSTANCEID"
		# Write to file
		echo "INSTANCE=\"$INSTANCE\"" > INSTANCE.cfg
		echo "INFO: Starting instance $INSTANCE"

		gcloud beta compute instances create $INSTANCE \
			--project $PROJECT_ID \
			--zone $ZONE \
			--machine-type $MACHINE_TYPE \
			--boot-disk-size $BOOT_DISK_SIZE \
			--image $IMAGE_NAME \
			--scopes "cloud-platform" \
			--service-account $SERVICE_ACCOUNT

	fi

elif [ $1 == "ssh" ]; then

	# If there is an active instance ssh to it
	if [ -e INSTANCE.cfg ]; then

		source INSTANCE.cfg
		echo "INFO: SSH to $INSTANCE"

		gcloud compute ssh $INSTANCE \
			--project $PROJECT_ID \
			-- -R 52698:localhost:52698

	else

		echo "ERROR: No instance found. (INSTANCE.cfg missing)"

	fi

elif [ $1 == "down" ]; then

	# If there is an active instance delete it
	if [ -e INSTANCE.cfg ]; then

		source INSTANCE.cfg
		echo "INFO: Deleting instance $INSTANCE"

		gcloud compute instances delete $INSTANCE \
			--project $PROJECT_ID \
			--quiet

		if [ $? -eq 0 ]; then
			rm INSTANCE.cfg
		fi

	else

		echo "ERROR: No instance found. (INSTANCE.cfg missing)"

	fi

else

	echo "ERROR: Unrecogised command."

fi
