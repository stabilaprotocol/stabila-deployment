## Linux installation and deploy
Docker file Dockerfile provides execution environment for FullNode.<br/>
Bash script deploy.sh manages installation, deploy and lifecycle of FullNode execution.

## Download Dockerfile and deploy.sh files

```shell
wget https://raw.githubusercontent.com/stabilaprotocol/stabila-deployment/master/Dockerfile -O Dockerfile
wget https://raw.githubusercontent.com/stabilaprotocol/stabila-deployment/master/deploy.sh -O deploy.sh
```
## Run deploy.sh script
```shell
bash deploy.sh start 8090
# In case warning message containing "The following signatures couldn't be verified because the public key is not available: NO_PUBKEY 7EA0A9C3F273FCD8" is displayed, run:
# sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7EA0A9C3F273FCD8
# sudo apt-get update
# and try again "bash deploy.sh start 8090"
```

## Parameter Illustration

```shell
bash deploy.sh [start|stop|restart] port path-to-json-file

start : install (if not already installed) docker, fetch images, build local image and start FullNode.jar application.
stop : stop FullNode.jar application and related docker container.
restart : restart FullNode.jar application.
port : required, port on which docker container will run
path-to-json-file : optional, path to the file (create manually) containing executive private key for seed node, default is peer node
```

## Examples

### Scripts execution

```shell
bash deploy.sh start 8090
bash deploy.sh restart 8090
bash deploy.sh stop 8090

bash deploy.sh start 8091 '/home/user/secret.json'
bash deploy.sh restart 8091 '/home/user/secret.json'
bash deploy.sh stop 8091
```

### Test execution
```shell
bash deploy.sh start 8090
curl -X POST -k http://127.0.0.1:8090/wallet/listexecutives
```
If you get executive-list json data then FullNode started successfully.
