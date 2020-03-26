LOCAL_CERT_PATH="/opt/code-server/cert.cer"
LOCAL_KEY_PATH="/opt/code-server/key.key"

CREDENTIAL_FILE="/root/.password.sh"

WORKSPACE_DIRECTORY="/mnt/c/"

function misc_findReplace()
{
    VARIABLE_FIND="$1"
    VARIABLE_REPLACE="$2"
    VARIABLE_FILE="$3"

	#echo "Finding: $VARIABLE_FIND"
	#echo "Replacing With: $VARIABLE_REPLACE"
	#echo "File to Operate On: $VARIABLE_FILE"

    sed -i "s@${VARIABLE_FIND}@${VARIABLE_REPLACE}@g" "$VARIABLE_FILE"
}

function getCredential_setPassword()
{
    VARIABLE_PASSWORD=""
    VARIABLE_PASSWORD2=""

    while true; do
        read -s -p "Password: " VARIABLE_PASSWORD
        echo
        read -s -p "Password (again): " VARIABLE_PASSWORD2
        echo
        [ "$VARIABLE_PASSWORD" = "$VARIABLE_PASSWORD2" ] && break
        echo "Passwords do not match. Please try again."
    done

    export PASSWORD="$VARIABLE_PASSWORD"
    echo "export PASSWORD='$VARIABLE_PASSWORD'" > "$CREDENTIAL_FILE"
    chmod 700 "$CREDENTIAL_FILE"
}

function getCredential()
{
    if [ -f "$CREDENTIAL_FILE" ]; then
        echo "Credential Found, Setting..."
        source "$CREDENTIAL_FILE"
    else
        echo "Credential Not Found, Enter Your Desired Workspace Password..."
        getCredential_setPassword
    fi
}

function startSSH()
{
    VARIABLE_FILE="/etc/ssh/sshd_config"

    VARIABLE_TO_FIND="#PermitRootLogin prohibit-password"
    VARIABLE_TO_REPLACE="PermitRootLogin yes"
    misc_findReplace "$VARIABLE_TO_FIND" "$VARIABLE_REPLACE" "$VARIABLE_FILE"

    VARIABLE_TO_FIND="#PasswordAuthentication yes"
    VARIABLE_TO_REPLACE="PasswordAuthentication yes"
    misc_findReplace "$VARIABLE_TO_FIND" "$VARIABLE_REPLACE" "$VARIABLE_FILE"

    echo "root:$PASSWORD" | chpasswd 
    nohup /usr/sbin/sshd -D &
}

function startVsCode()
{
    while :
    do
        if [ -f "$LOCAL_CERT_PATH" ]; then
            echo "Cert Found, running VS Code with it..."
            /opt/code-server/code-server "$WORKSPACE_DIRECTORY" --cert "$LOCAL_CERT_PATH" --cert-key "$LOCAL_KEY_PATH" --port 443 --host 0.0.0.0
        else
            echo "Cert Not Found, running VS Code with self-signed cert..."
            /opt/code-server/code-server "$WORKSPACE_DIRECTORY" --cert --port 443 --host 0.0.0.0
        fi
    done
}

function main()
{
    getCredential
    startSSH
    
    #Should be last since Code Server is sometimes prone to crashing
    startVsCode
}

main
