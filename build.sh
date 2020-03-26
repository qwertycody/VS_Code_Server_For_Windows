#Ensure nothing happens outside the directory this script is ran from
cd "$(dirname "$0")"
SCRIPT_DIRECTORY=$(pwd)

DOCKER_BUILD_CONTEXT_FOLDER="."

IMAGE_NAME="garrett-tech:code-server-windows"

ASSETS_FOLDER="Assets"
ASSET_CODE_SERVER="code-server-3.0.0-linux-x86_64.tar.gz"
ASSET_STARTUP_SCRIPT="startup.sh"
ASSET_PROXY_SCRIPT="proxy.sh"

chmod -R 700 "./$ASSETS_FOLDER"

##########################################################
# Uncomment if you deal with a corporate proxy like I do #
##########################################################

#if [ -z "$HTTP_PROXY" ]
#then
#    source "./$ASSETS_FOLDER/$ASSET_PROXY_SCRIPT"
#fi

docker image build --file ./Dockerfile -t "$IMAGE_NAME" \
                                                  --build-arg ASSETS_FOLDER="$ASSETS_FOLDER" \
                                                  --build-arg ASSET_CODE_SERVER="$ASSET_CODE_SERVER" \
                                                  --build-arg ASSET_STARTUP_SCRIPT="$ASSET_STARTUP_SCRIPT" \
                                                  --build-arg ASSET_PROXY_SCRIPT="$ASSET_PROXY_SCRIPT" \
												                          --build-arg HTTP_PROXY="$HTTP_PROXY" \
                                                  --build-arg HTTPS_PROXY="$HTTPS_PROXY" \
                                                  --build-arg NO_PROXY="$NO_PROXY" \
                                                  --rm=true \
                                                  $DOCKER_BUILD_CONTEXT_FOLDER 
