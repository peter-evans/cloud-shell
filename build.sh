#!/bin/bash

# Fetch configuration
source cloud-shell.cfg

packer build \
  -force \
  -on-error=cleanup \
  -var "project_id=$PROJECT_ID" \
  -var "image_name=$IMAGE_NAME" \
  -var "zone=$ZONE" \
  -var "machine_type=$MACHINE_TYPE" \
  -var "source_image=$SOURCE_IMAGE" \
  cloud-shell-packer.json
