
# DOCKERS images required for DVC Test Env

This repo contains consul, rabbitmq, couchbase docker images and default congiguration to support dvc L0/L1 test enviorment

dvc_checker is a containers to validate all contariners are running correctly 


## A. Developying with Docker-compose

### Pre-Requirement
* docker-engine
```sh
sudo pip install docker-compose
```

### step1: update env file
```sh
TAG=<mytag>
HOST_IP=1.1.1.1
```
### step2: start all containers 
```sh
cd dvc_docker
docker-compose up -d

## make sure all test passing in the checker before start using containers
docker logs -f dvc_checker
```
## step3: To stop and remove all containers
```sh
docker-compose down
```


## B. check dvc-docker  Enviromennt

```sh
docker run -it --rm dvc_checker --consul=52.53.151.62
```
or 

```sh
cd dvc_docker/test
source ENV.sh
pytest test.py [  --consul=1.1.1.1 ]
```

## C. Run Individual containers seperately

### step1 Setup ip address
```sh
dockerhost=10.157.100.58  #host runs the docker containers. will be couchbase/rabmmitmq ip
consul=10.157.100.58
```


### Step2 Start consul
- register couchbase , couchbaseTest , rabbitmq , rabbitmqTest
- login info : http://$host_ip:8500 

```sh
docker run --name consul  -d -p 8500:8500  <consul_image>
docker logs -f consul
```


### Step3 Start couchbase
- create Administration account 
- create dvcbucket , dvcbucketTest
- create primary Index
- Register to consul 
- Login info : http://$host_ip:8901 ( Administrator/password)
- Please make sure you see bucket is queryable before using it


```sh
docker run --name couchbase -d --add-host dockerhost:$dockerhost --add-host consul:$consul -p 8091-8094:8091-8094 -p 11207:11207 -p 11210-11211:11210-11211 -p 18091-18093:18091-18093 <couchbase_image>
docker logs -f couchbase
```

### Step4 Start Rabbitmq
- create tachyon/tacyon  with access to "/" vhost 
- register to consul
- Login info  http://$host_ip:15672 (guest/guest  or tachyon/tachyon)
- Wait for 3 min before using it.

```sh
docker run --name rabbitmq -d  --add-host dockerhost:$dockerhost --add-host consul:$consul  -p 15672:15672 -p 5672:5672 <rabbitmq_image>
docker logs -f rabbitmq
```


