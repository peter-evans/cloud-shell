#!/bin/bash
set -e

# Fetch Google Cloud project ID
source cloud-shell.cfg

# Service account details
SA_NAME=packer-service-account
SA_DISPLAY_NAME="Packer Service Account"
SA_EMAIL=$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com
KEY_FILE=service_account.json

# Create a new GCP IAM service account
gcloud iam service-accounts create $SA_NAME --display-name "$SA_DISPLAY_NAME" --project $PROJECT_ID

# Create and download a new key for the service account
gcloud iam service-accounts keys create $KEY_FILE --iam-account $SA_EMAIL

# Give the service account the "Compute Instance Admin v1" and "Service Account User" IAM roles
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:$SA_EMAIL --role roles/compute.instanceAdmin.v1
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:$SA_EMAIL --role roles/iam.serviceAccountUser
