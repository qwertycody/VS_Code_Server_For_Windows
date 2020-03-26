CONTAINER_NAME="code-server"
IMAGE_NAME="garrett-tech:code-server-windows"

VOLUME_DOCKER_SOCK="//var/run/docker.sock:/var/run/docker.sock"
VOLUME_C_DRIVE='c:/:/mnt/c'

PORT_WEB_INTERFACE="443"
PORT_SSH_SERVER="22"

docker stop "$CONTAINER_NAME"
docker rm "$CONTAINER_NAME"

docker run -it --privileged --name "$CONTAINER_NAME" \
                            --volume "$VOLUME_C_DRIVE" \
                            --volume "$VOLUME_DOCKER_SOCK" \
                            --user root \
                            -p "$PORT_WEB_INTERFACE:443" \
                            -p "$PORT_SSH_SERVER:22" \
                            --restart always \
                            "$IMAGE_NAME" 
