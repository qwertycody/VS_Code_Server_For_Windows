#!/bin/bash

##################################
#### Defining URL Encode     ####
#### Function for Passwords  ####
#### with Special Characters ####
#################################

rawurlencode() {
  local string="${1}"
  local strlen=${#string}
  local encoded=""
  local pos c o

  for (( pos=0 ; pos<strlen ; pos++ )); do
     c=${string:$pos:1}
     case "$c" in
        [-_.~a-zA-Z0-9] ) o="${c}" ;;
        * )               printf -v o '%%%02x' "'$c"
     esac
     encoded+="${o}"
  done
  echo "${encoded}"
}

PROXY_ADDRESS=companyProxy.com
PROXY_PORT=8080
PROXY_BYPASS=.companyName.com,asdf.com
ENVIRONMENT_VARIABLE_LIST="HTTP_PROXY HTTPS_PROXY http_proxy https_proxy ftp_proxy"
GIT_ENVIRONMENT_VARIABLE_LIST="http.proxy https.proxy"
USERNAME=""
PASSWORD=""
PASSWORD_ENCODED=""

setProxy() {

	###################################
	#### Defining Proxy Parameters ####
	###################################

	echo "Enter Username: "
	read USERNAME

	echo "Enter Password: "
	read -s PASSWORD

	PASSWORD_ENCODED=$(rawurlencode $PASSWORD)

	PROXY_URL="http://$USERNAME:$PASSWORD_ENCODED@$PROXY_ADDRESS:$PROXY_PORT/"

	for ENVIRONMENT_VARIABLE in $ENVIRONMENT_VARIABLE_LIST
	do
		TEMP=$ENVIRONMENT_VARIABLE="$PROXY_URL"
		export $TEMP
	done

	export no_proxy=$PROXY_BYPASS
}

unsetProxy() {
	if [[ $suffix == *"User"* ]]; then
		JAVA_ARGS+=" $prefix.$suffix=$USERNAME"
	fi

	for ENVIRONMENT_VARIABLE in $ENVIRONMENT_VARIABLE_LIST
	do
		TEMP=$ENVIRONMENT_VARIABLE=""
		export $TEMP
	done

	export no_proxy=""
}


launchJavaJar() {
	######################################################
	#### Setting JAVA Launch Parameters Configuration ####
	######################################################

	echo "Type Java JAR Path: "
	read JAVA_JAR_PATH

	JAVA_ARGS=""

	PREFIX_LIST="-Dhttp -Dhttps"
	SUFFIX_LIST="proxyHost proxyPort proxyUser proxyPassword"

	for prefix in $PREFIX_LIST
	do
		 for suffix in $SUFFIX_LIST
		 do
			if [[ $suffix == *"Host"* ]]; then
				JAVA_ARGS+=" $prefix.$suffix=$PROXY_ADDRESS"
			fi

			if [[ $suffix == *"Port"* ]]; then
				JAVA_ARGS+=" $prefix.$suffix=$PROXY_PORT"
			fi	
			
			if [[ $suffix == *"User"* ]]; then
				JAVA_ARGS+=" $prefix.$suffix=$USERNAME"
			fi

			if [[ $suffix == *"Password"* ]]; then
				JAVA_ARGS+=" $prefix.$suffix=\"$PASSWORD\""
			fi	  
		 done
	done
	
	JAVA_ARGS+=" -Djava.net.useSystemProxies=true"
	JAVA_ARGS+=" -Djdk.http.auth.tunneling.disabledSchemes=\"\""
	JAVA_ARGS+=" -Djdk.http.auth.proxying.disabledSchemes=\"\""

	java $JAVA_ARGS -jar "$JAVA_JAR_PATH"
}

# Bash Menu Script Example
choiceFunction() {
	SUCCESS="false"

	while [ $SUCCESS == "false" ]
	do
		clear
		echo 'Please enter your choice: '
		echo "1 - Set Proxy Settings (Yum, Environment, GIT)" 
		echo "2 - Disable/Remote Proxy Settings (Yum, Environment, GIT)" 
		echo "3 - Launch Java JAR with Proxy Settings" 
		echo "4 - Quit"
		read CHOICE

		case $CHOICE in
		   "1") SUCCESS="true";echo "Setting Proxy..."; unsetProxy; setProxy;;
		   "2") SUCCESS="true";echo "Disabling Proxy..."; unsetProxy;;
		   "3") SUCCESS="true";echo "Launching JAR with Proxy Settings...";unsetProxy; setProxy;launchJavaJar;;
		   "4") SUCCESS="true";echo "Exitting..."; exit;;
		   *) read -p "Invalid choice, Press any key to continue..." fakeVariableIgnoreMe;;
		esac
	done
}

choiceFunction
