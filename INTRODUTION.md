When we work with microservices we want to spread part of our application among the infrastructure. However, this decentralized approach lead us to the need to solve new another problems like, where my services are going ton run? How can I control how many instances of a particular service I am running? How I balance the traffic among the instances? How I find the instances in my network or another network?

Docker Swarm integrates these orchestration capabilities into Docker Engine 1.12 and newer releases. Docker Swarm uses the standard Docker API to interact with other tools, such as Docker Machine.

In this post, I am going to give an introduction to the swarm mode capabilities.


- Service: it is a definition of the kind of task that is going to be run by the cluster. It is the unit of the swarm. Services can be of two types, replicated or global. In replicated mode the user specifies the number of replicas the cluster must run and the swarm choose in which nodes they are going to run. In global mode, only one task is going to run per node and there is not need to specify the number of replicas.

- [Task](https://docs.docker.com/engine/swarm/how-swarm-mode-works/services/#tasks-and-scheduling): it is the unit of work. These tasks are defined in the service and they are scheduled to create or deleted when the orchestrator receives the desired service state. Also, a task can be created when a task is marked as unhealthy and the unhealthy one is deleted in order to maintain the desired state. The abstraction of the task can be a virtual machine, a process or a container. Even if the docker swarm orchestrator and scheduler are general purpose docker swarm only supports containers.

### Deploying with stack
You can use [docker stack](https://docs.docker.com/engine/swarm/stack-deploy/#deploy-the-stack-to-the-swarm) to deploy a bunch of services, for instance, services that together represent an application. Instead of run commands to run services one by one you can define all of them in a file and let `docker stack deploy` deploy all the services for you.
This file can be done in `docker-compose` v3.0 syntax or above. Here is an example of a stack definition:

```
version: '3.1'

services:
  webapp:
    image: vendor/api
    ports:
      - "8000:8000"
  sqldb:
    image: vendor/db
```

You can deploy this file doing `docker stack deploy --compose-file docker-compose.yml stackname`. This is going to create two services `stackname_webapp` and `stackname_sqldb` in the swarm. `stackname_webapp` is going to run the image `vendor/api` and expose the port 8000 to the external world. `stackname_sqldb` is going to run the image `vendor/db` and is going to be accessible only inside the swarm because it doesn't expose any port.


### Setting up local environment

In docker swarm, we need to setup 2 kinds of roles, manager, and worker. Each of them run in a docker machine which can run on different host machines or in the same listening to different ports. Later in this post, you will find the description of each of them in more detail.

In this post, I am going to consider that the docker machines are running in different IP addresses so the only thing we need to change to talk with any of them is the IP of the `DOCKER_HOST` environment variable to talk with any of them.

I have a [repository](https://github.com/charlyraffellini/docker-swarm-poc) where I configured several virtual machines on my computer with the following IP addresses:

- Manager 1 - Instance Name: `m1` - Address: `192.168.99.201`
- Manager 2 - Instance Name: `m2` - Address: `192.168.99.202`
- Worker 1 - Instance Name: `w1` - Address: `192.168.99.211`
- Worker 2 - Instance Name: `w2` - Address: `192.168.99.212`
- Worker 3 - Instance Name: `w3` - Address: `192.168.99.213`

For instance, if we want to run commands in the instance `w2 ` we are going to export the `DOCKER_HOST` environment variable and using the address `192.168.99.212`. `DOCKER_HOST=192.168.99.212`.


## Manager and worker roles

Managers and workers are instances of Docker Engine.

[Managers](https://docs.docker.com/engine/swarm/how-swarm-mode-works/nodes/#manager-nodes) are responsible for maintaining a consistent state on the swarm and services. The managers schedule services. One [optimization](https://blog.docker.com/2016/07/docker-built-in-orchestration-ready-for-production-docker-1-12-goes-ga/) for the scheduler is that the managers keep an in-memory state of the swarm. The internal distributed data store is copied in all the managers.

The purpose of [workers](https://docs.docker.com/engine/swarm/how-swarm-mode-works/nodes/#worker-nodes) is to execute containers. Workers can be promoted to managers so the state of the cluster is copied to the promoted node.


### Initialize the swarm

When we run `docker swarm init` in a single node it will switch on the swarm mode. `docker info` to check that. Also, assign the current node as leader manager. There are more setups that follow the initialization that can be read in the official [documentation](https://docs.docker.com/engine/swarm/swarm-mode/#create-a-swarm).

Sometimes you have many interfaces with different IP in the machine that initializes the swarm. Add `--advertise-addr 192.168.99.201` at the end of the init command to set which of them is going to advertise in the cluster.

### Joining a swarm

Joining a swarm can be done as a redundant manager or worker. To get the tokens you necessary to join run `docker swarm join-token manager` or `docker swarm join-token worker`.

The token has the following shape corresponds to the pattern `SWMTKN-1-< digest-of-root-CA-cert>-< random-secret >`. `SWMTKN-1` means this is swarm token version 1. [Here](https://github.com/docker/labs/tree/master/security/swarm#step-2-add-a-new-manager) you can find detailed info.


