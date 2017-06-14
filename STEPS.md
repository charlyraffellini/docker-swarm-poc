# Intro

```bash
$ export DOCKER_HOST=192.168.99.201
$ docker info
```

- The swarm state is showed ad `Swarm: inactive`
- The name of the host is showed as `Name: m1`

# Init swarm

```
$ docker swarm init --advertise-addr 192.168.99.201
```

run `docker info` and show that now swarm is **active** and more info is showed.

# join a node to the swarm

```
$ export DOCKER_HOST=192.168.99.211
$ docker swarm join --token SWMTKN-1-5sf3tt1gygzgz7vve3f44q9i7k0f0s9mvqzr0lf0ag7fu20nm8-42e373w0xe1x1tv3xd4wdkt7r 192.168.99.201:2377
$ export DOCKER_HOST=192.168.99.212
$ docker swarm join --token SWMTKN-1-5sf3tt1gygzgz7vve3f44q9i7k0f0s9mvqzr0lf0ag7fu20nm8-42e373w0xe1x1tv3xd4wdkt7r 192.168.99.201:2377
```

# join as manager
```
$ export DOCKER_HOST=192.168.99.201
$ docker swarm join-token manager
$ export DOCKER_HOST=192.168.99.202
$ docker swarm join --token SWMTKN-1-5sf3tt1gygzgz7vve3f44q9i7k0f0s9mvqzr0lf0ag7fu20nm8-aywh15a240wt81o32zr0xljef 192.168.99.201:2377
```

![Alt text](https://docs.docker.com/engine/swarm/images/swarm-diagram.png)

#### which are the manager responsibilities?

**Manager nodes handle cluster management tasks:**
- maintaining cluster state - using an in-memory distributed store among the managers
- scheduling services
- serving swarm mode HTTP API endpoints

# list nodes
```
docker node list
```

- which manager is the **leader**?
- what is the **status** of the nodes?
- what is the **availability**? is **active or drain**?

# create a service to visualise

```
docker service create \
     --name=viz \
     --publish=8080:8080/tcp \
     --constraint=node.role==manager \
     --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
     dockersamples/visualizer
```
- keep in another console:
```
watch -d -n 1 docker service ls
```
- it only creates one task of the service in a manager.

which address can we use access to the service from a browser?
any address:
- http://192.168.99.211:8080/
- http://192.168.99.212:8080/
- http://192.168.99.201:8080/
- http://192.168.99.202:8080/

# how to get information about the status of services?
```
$ docker service ls
```
# how to get information about the status of tasks?
```
$ docker service ps viz
```
# how to get information about the status of nodes?
```
$ docker node ls
```
# how to get information about the status of containers?
```
$ docker ps
```

# how to scale a service?

```
docker service scale viz=3
```

See in the console that is running `watch -d -n 1 docker service ls` or in the visualiser service the new services that were created

# is my service behind a load balancer?
```
$ docker network create -d overlay --subnet=10.0.9.0/24 backend
$ docker service create --name inspector -p 5000:3000 --network backend charlieraffellini/inspector
```

- run a few times `curl http://192.168.99.201:5000/`
- scale the service `docker service scale inspector=4`
- run a few times  `curl http://192.168.99.201:5000/`

# how to deploy stack with compose files?

```
version: '3.1'

services:
  my_backend:
    image: charlieraffellini/backend
    deploy:
      replicas: 5
    networks:
      - backend
  frontend:
    image: charlieraffellini/frontend
    ports:
      - "4000:3000"
    environment:
      MY_BACKEND_API: "my_backend:3000"
    deploy:
      replicas: 2
    networks:
      - backend

networks:
  backend:
    external:
      name: backend
```

- deploy `docker stack deploy -c services/stack_back_and_front.yml app`
- query `http://192.168.99.201:4000/balance/40`


# let's query inside a container

- log in a container, for instance `docker exec -it $(docker ps -f name=app_my_backend -q) bash`
- install dig `apt-get install dnsutils`
- get the all internal IPs `dig tasks.inspector`

---

# what is mode global mode and publish mode host?
```
docker service create --mode=global --name cadvisor \
--publish=8090:8080 \
--mount type=bind,source=/,target=/rootfs,readonly=true \
--mount type=bind,source=/var/run,target=/var/run,readonly=false \
--mount type=bind,source=/sys,target=/sys,readonly=true \
--mount type=bind,source=/var/lib/docker/,target=/var/lib/docker,readonly=true \
google/cadvisor
```

- see which is the publish mode `docker service inspect cadvisor`

```
docker service create --mode=global --name cadvisor \
--publish mode=host,target=8080,published=8090 \
--mount type=bind,source=/,target=/rootfs,readonly=true \
--mount type=bind,source=/var/run,target=/var/run,readonly=false \
--mount type=bind,source=/sys,target=/sys,readonly=true \
--mount type=bind,source=/var/lib/docker/,target=/var/lib/docker,readonly=true \
google/cadvisor
```

- see which is the publish mode `docker service inspect cadvisor`

---

# what happens when an app crash?

- run in a different console `watch -d -n 1 docker service ps inspector`
- then crash the inspector app doing `http://192.168.99.201:5000/crash`
- see what happens with the watch. The task restarts, it is because this process exited.


# what happens when an app gets stale?

- create a new service

```
version: '3.1'
services:
  cow:
    image: charlieraffellini/cow
    ports:
      - "9000:80"
    deploy:
      placement:
        constraints:
          - node.role==manager
```

- deploy the service `docker stack deploy -c services/health_cow.yml cow`
- run in another console `watch -d -n 1 docker service ps cow_cow`
- look in which node cow is running and run `docker exec -it $(docker ps -f name=cow_cow -q) bash`
- change the name of the fortune file: `mv /usr/games/fortune /usr/games/fortune2`
- perform some queries through the browser `http://192.168.99.201:9000/`
- it should be broken

# how to add health checks?

```
version: '3.1'
services:
  cow:
    image: charlieraffellini/cow
    ports:
      - "9000:80"
    healthcheck:
      test: curl -f -s -S http://localhost || exit 1
      interval: 3s
      timeout: 5s
      retries: 3
    deploy:
      placement:
        constraints:
          - node.role==manager
```

- deploy the service `docker stack deploy -c services/health_cow.yml cow`
- run in another console `watch -d -n 1 docker service ps cow_cow`
- look in which node cow is running and run `docker exec -it $(docker ps -f name=cow_cow -q) bash`
- change the name of the fortune file: `mv /usr/games/fortune /usr/games/fortune2`
- perform some queries through the browser `http://192.168.99.201:9000/`
- it should come back to live soon

- Values that the health check understand
  - 0 success
  - 1 unhealthy
  - 2 reserved

# how to force a service to restart?

```
docker service update --force cow_cow
```

---

# how to access to secrets?

- create a new secret `echo root | docker secret create mysql_root_pass -`
- create a file `secrets.yml`
```
version: '3.1'
services:
  mysql:
    image: mysql
    environment:
      MYSQL_USER: wordpress
      MYSQL_DATABASE: wordpress
      MYSQL_ROOT_PASSWORD_FILE: "/run/secrets/root_pass"
    secrets:
      - root_pass
    deploy:
      placement:
        constraints:
          - node.role==manager
```

- get the content of the secret in the file system `cat /run/secrets/root_pass`
- connect to the container `docker exec -it $(docker ps -f name=mysql -q) bash`
- log as root `mysql -uroot -p`
- list databases `show databases;`
- 


