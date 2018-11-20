#!/usr/bin/env bash

## source our settings from setup.inc (if it exists)
if [ -r "${PWD}/setup.inc" ]; then
	source "${PWD}/setup.inc"
fi

## set $CLOUD_REGION to default if not sourced
if [ "$CLOUD_REGION" = "" ]; then
	CLOUD_REGION="us-central1"
fi

## color variables
RED='\033[0;31m'
BLU='\033[0;34m'
GRN='\033[0;32m'
PUR='\033[0;35m'
NC='\033[0m'

## print welcome banner
printf "\n${BLU}***********************************************\n\n"
printf "Welcome to the AVR-IoT interactive quick setup\n\n"
printf "***********************************************${NC}\n\n"



## log in to firebase, if needed
if [ $FIREBASE_CLI_NEEDS_LOGIN ]; then
	if [ $SETUP_IS_LOCAL ]; then
		## print local firebase login/authorization instructions
		printf "${GRN}To set up your Firebase credentials for use by the 'firebase' command-line tool, perform\n"
		printf "the necesssary steps in the web browser window/tab that will be opened. Once completed, this\n"
		printf "setup procedure should automatically resume.${NC}\n\n"

		## perform local/interactive firebase login/authorization
		firebase login
	else
		## print remote firebase login/authorization instructions
		printf "${GRN}To set up your Firebase credentials for use by the 'firebase' command-line tool, copy the URL\n"
		printf "that is emitted below, and paste it into a new browser tab. Perform the necessary steps in the web\n"
		printf "browser tab. Finally, copy and paste the authorization code into this terminal.${NC}\n\n"

		## perform remote firebase login/authorization
		firebase login --no-localhost
	fi
fi

## get device name, project name and device public key from user, if needed
if [ "$DEVICE_ID" == "" ]; then
	echo
	read -p 'Please enter device UID: ' DEVICE_ID
	echo
fi

## let user choose to set IoT core registry name
REG_NAME=""
ATTEMPT=0
## check that REG_NAME matches pattern
while ! [[ $REG_NAME =~ ^[a-zA-Z]{1}[a-zA-Z0-9+%~._-]{2,254} ]]
do

## display hint if user has made 1 or more attempt
if (( ATTEMPT > 0 )); then
printf "\n${RED}IoT Core Registry names must be between 3-255 characters,\nstart with a letter, and contain only letters, numbers and\n the following characters:\n"
echo '- . % ~ +'
echo
printf "${NC}"
fi

## get user REG_NAME input
read -p 'Choose an IoT Core registry name (return for AVR-IOT): ' REG_NAME
ATTEMPT=$((ATTEMPT + 1))

## set to default if no text entered
if [ "$REG_NAME" = "" ]; then
	REG_NAME="AVR-IOT"
fi

## strip white space
REG_NAME="$(echo "${REG_NAME}" | tr -d '[:space:]')"
done


## set the project and tell firebase to use it firebase
gcloud config set project $GOOGLE_CLOUD_PROJECT
firebase use $GOOGLE_CLOUD_PROJECT

## enable cloud functions, IoT core, and pub sub
gcloud services enable cloudfunctions.googleapis.com cloudiot.googleapis.com pubsub.googleapis.com

## create pubsub topic
gcloud pubsub topics create avr-iot

## create IoT core device registry
gcloud iot registries create $REG_NAME --region=$CLOUD_REGION --event-notification-config=topic=avr-iot

## add device to registry
printf "\n${BLU}Creating IoT core registry ${REG_NAME}${NC}"
gcloud iot devices create "d$DEVICE_ID" --region=$CLOUD_REGION --registry=$REG_NAME

## install npm dependencies
printf "${BLU}Installing Cloud Function dependencies (this may take a few minutes)...\n${NC}"
npm install --prefix ./functions/
printf "\n${BLU}Installing UI dependencies (this may take a few minutes)...\n${NC}"
npm install --prefix ./ui/

## retrieve UI config vars
firebase setup:web > config.txt
node getFirebaseConfig.js $DEVICE_ID config.txt

## build the UI
printf "${BLU}Creating a production build of the UI (this may take a few minutes)...\n${NC}"
npm run build --prefix ./ui

## XXX: is this needed?
chmod a+x ./ui/src/Config.js

## deploy everything needed to firebase
firebase deploy --only functions:recordMessage
firebase deploy --only database
firebase deploy --only hosting

## print "setup finished" banner
printf "\n${GRN}**************************************\n\n"
printf "Setup complete!\n\n"
printf "Remember to add your device\'s public key in the registry:\n\n"
printf "https://console.cloud.google.com/iot/registries\n\n"
printf "Once you\'ve added the public key, checkout your app:\n\n"
printf "${GOOGLE_CLOUD_PROJECT}.firebaseapp.com/device/${DEVICE_ID}\n\n"
printf "**************************************\n\n${NC}"
