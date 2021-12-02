 if ($($args.Count) -lt 2) {
    Write-Output "Usage: deploy.ps1 start <PORT>|deploy.ps1 stop <PORT>|deploy.ps1 restart <PORT>."
    Exit
}

$PORT=$args[1]
$CONTAINER="stabilaprotocol-ubuntu-container-$PORT"

if ($($args.Count) -gt 2) {
    $PRIVATE_KEY=$args[3]
}

$CONTAINER_ID=docker ps -aqf "$CONTAINER"

if ($CONTAINER_ID -eq $null) {
    $DOCKER_IMAGE_ID=docker build -t "stabilaprotocol/ubuntu/local" -f Dockerfile .
    $DOCKER_CONTAINER_ID=sudo docker run -it -d -p ${PORT}:${PORT} --name "$CONTAINER" $DOCKER_IMAGE_ID
    
    if ($PRIVATE_KEY -ne $null) {
        docker exec -it $CONTAINER /home/work.sh stop
	    docker exec -it $CONTAINER /home/work.sh start $PRIVATE_KEY
    }
}

$CMD=$args[0]

if ($CMD -eq "start") {
    if (docker inspect -f {{.State.Running}} $CONTAINER) {
        Write-Output "stabilaprotocol-ubuntu-container is running"
        Exit
    }
    
    docker start $CONTAINER
    if ($PRIVATE_KEY -ne $null) {
        docker exec -it $CONTAINER /home/work.sh stop
	    docker exec -it $CONTAINER /home/work.sh start $PRIVATE_KEY
    }
    
    if (docker inspect -f {{.State.Running}} $CONTAINER) {
        Write-Output "Succeeded to start stabilaprotocol-ubuntu-container."
    } else {
        Write-Output "Failed to start stabilaprotocol-ubuntu-container."
    }
} elseif ($CMD -eq "stop") {
    if (docker inspect -f {{.State.Running}} $CONTAINER -eq $false) {
        Write-Output "stabilaprotocol-ubuntu-container is not running"
        Exit
    }
    
    docker exec -it $CONTAINER /home/work.sh stop
    docker stop $CONTAINER
    if (docker inspect -f {{.State.Running}} $CONTAINER) {
        Write-Output "Failed to stop stabilaprotocol-ubuntu-container."
    } else {
        Write-Output "Succeeded to stop stabilaprotocol-ubuntu-container."
    }
} elseif ($CMD -eq "restart") {
    if (docker inspect -f {{.State.Running}} $CONTAINER -eq $false) {
        Write-Output "stabilaprotocol-ubuntu-container is not running"
        Exit
    }
    
    docker exec -it $CONTAINER /home/work.sh stop
    if ($PRIVATE_KEY -ne $null) {
	    docker exec -it $CONTAINER /home/work.sh start $PRIVATE_KEY
    } else {
        docker exec -it $CONTAINER /home/work.sh start
    }
    
    if (docker inspect -f {{.State.Running}} $CONTAINER) {
        Write-Output "Succeeded to restart stabilaprotocol-ubuntu-container."
    } else {
        Write-Output "Failed to restart stabilaprotocol-ubuntu-container."
    }
}
