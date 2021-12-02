#!/bin/bash
if [ $# -lt 2 ]
then
    echo "Usage: deploy.sh start <PORT>|deploy.sh stop <PORT>|deploy.sh restart <PORT>."
    exit 1
fi

PORT="${2}"
CONTAINER="stabilaprotocol-ubuntu-container-$PORT"

if [[ ${3+x} ]]
then
PRIVATE_KEY=$(<"${3}")
echo $PRIVATE_KEY
fi

function install_docker() {
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
echo "Succeeded to install docker"
}

function build_docker_image() {
sudo docker build -t "stabilaprotocol/ubuntu/local" .
DOCKER_IMAGE_ID=`sudo docker images -q stabilaprotocol/ubuntu/local`
DOCKER_CONTAINER_ID=`sudo docker run -it -d -p $PORT:$PORT --name "$CONTAINER" $DOCKER_IMAGE_ID`
if [[ ${PRIVATE_KEY+x} ]]
then
    sudo docker exec -it $CONTAINER /home/work.sh stop
    sudo docker exec -it $CONTAINER /home/work.sh start $PRIVATE_KEY
fi
}

if [ -z "$(sudo dpkg -l | grep docker)" ]
then
    install_docker
    build_docker_image
else
    if [ ! $(sudo docker ps -a | grep $CONTAINER | wc -l ) -gt 0 ]
    then
    	build_docker_image
    fi
fi

function update_docker_image() {
LOCAL_REPO_DIGESTS=`sudo docker inspect --format='{{index .RepoDigests 0}}' stabilaprotocol/ubuntu`
ARRAY=(${LOCAL_REPO_DIGESTS//@/ })
LOCAL_DIGEST_HASH=${ARRAY[1]}
REPO_DOCKERHUB_URL=`curl https://hub.docker.com/v2/repositories/stabilaprotocol/ubuntu/tags/latest/`
REMOTE_DIGEST_HASH=`echo "$REPO_DOCKERHUB_URL" | grep -oP '(?<="digest":")[^"]*'`

if [[ "$LOCAL_DIGEST_HASH" != "$REMOTE_DIGEST_HASH" ]]
then
    sudo docker pull stabilaprotocol/ubuntu
    sudo docker image rm -f stabilaprotocol/ubuntu/local
    build_docker_image
fi
}

case "${1}" in
    start)	
	if [ ! -z "$(sudo docker ps -q -f name=$CONTAINER)" ]
	then
      	    echo "stabilaprotocol-ubuntu-container is running"
      	    exit 1
	fi
	
	update_docker_image
	
	sudo docker start $CONTAINER
	if [[ ${PRIVATE_KEY+x} ]]
	then
	    sudo docker exec -it $CONTAINER /home/work.sh stop	
	    sudo docker exec -it $CONTAINER /home/work.sh start $PRIVATE_KEY
	fi
        if [ "$(sudo docker ps -q -f name=$CONTAINER)" ]
        then
            echo "Succeeded to start stabilaprotocol-ubuntu-container."
        else
            echo "Failed to start stabilaprotocol-ubuntu-container."
        fi
    ;;
    stop)
    	if [ ! "$(sudo docker ps -q -f name=$CONTAINER)" ]
    	then
      	    echo "stabilaprotocol-ubuntu-container is not running"
      	    exit 1
        fi
        
        sudo docker exec -it $CONTAINER /home/work.sh stop
        sudo docker stop $CONTAINER
        if [ "$(sudo docker ps -q -f name=$CONTAINER)" ]
	then
	    echo "Failed to stop stabilaprotocol-ubuntu-container."
	else
	    echo "Succeeded to stop stabilaprotocol-ubuntu-container."
	fi
    ;;
    restart)
        if [ ! "$(sudo docker ps -q -f name=$CONTAINER)" ]
        then
            echo "stabilaprotocol-ubuntu-container is not running."
            exit 1
        fi
        
        sudo docker exec -it $CONTAINER /home/work.sh stop
        if [[ ${PRIVATE_KEY+x} ]]
        then
            sudo docker exec -it $CONTAINER /home/work.sh start $PRIVATE_KEY
        else
            sudo docker exec -it $CONTAINER /home/work.sh start    
        fi    
     	if [ "$(sudo docker ps -q -f name=$CONTAINER)" ]
        then	
            echo "Succeeded to restart stabilaprotocol-ubuntu-container."
        else
            echo "Failed to restart stabilaprotocol-ubuntu-container."    
        fi
    ;;
esac
