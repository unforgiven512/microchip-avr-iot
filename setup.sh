#!/bin/bash
CLOUD_REGION=us-central1

# color variables
red=$'\e[1;31m'
grn=$'\e[1;32m'
blu=$'\e[1;34m'
mag=$'\e[1;35m'
cyn=$'\e[1;36m'
white=$'\e[0m'

echo
echo $blue "*********************************************"
echo
echo Welcome to the AVR-IoT interactive quick setup
echo
echo $blue "*********************************************" $white

# get device name, project name and device public key from user
echo
read -p 'Please enter device ID: ' DEVICE_ID
echo

# set the project and tell firebase to use it firebase
gcloud config set project $GOOGLE_CLOUD_PROJECT
firebase use $GOOGLE_CLOUD_PROJECT

# enable cloud functions, IoT core, and pub sub
gcloud services enable cloudfunctions.googleapis.com cloudiot.googleapis.com pubsub.googleapis.com

# create pubsub topic
gcloud pubsub topics create avr-iot

# create IoT core device registry
gcloud iot registries create AVR-IOT --region=$CLOUD_REGION --event-notification-config=topic=avr-iot

# add device to registry
gcloud iot devices create "d$DEVICE_ID" --region=$CLOUD_REGION --registry=AVR-IOT

#install npm dependencies
echo $blue Installing Cloud Function dependencies \(this may take a few minutes\)... $white
npm install --prefix ./functions/
echo $blue Installing UI dependencies \(this may take a few minutes\)... $white
npm install --prefix ./ui/

# retrieve UI config vars 
firebase setup:web > config.txt
node getFirebaseConfig.js config.txt

# build UI
echo $blue Creating a production build of the UI \(this may take a few minute\)... $white
npm run build --prefix ./ui

chmod +x ./ui/src/Config.js

firebase deploy --only functions:recordMessage
firebase deploy --only database
firebase deploy --only hosting

echo
echo $green "**************************************" $white
echo
echo $green Setup complete! $white
echo 
echo $red Remember to add your device\'s public key in the registry: 
echo https://console.cloud.google.com/iot/registries $white
echo
echo Once you\'ve added the public key, checkout your app:
echo $green $GOOGLE_CLOUD_PROJECT.firebaseapp.com/device/$DEVICE_ID 
echo
echo $green "**************************************" $white
echo