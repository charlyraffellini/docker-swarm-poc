# docker-swarm-poc

## Requirements:

Virtual box and Vagrant installed.

---

## What it is?

It helps to setup your environment to run a docker swarm cluster. It downloads an ubuntu image, creates 4 virtual machines, installs and configure docker on each machine. It assigns certain IPs to each machine that you will use during the session.

## Why it is important?

Docker swarm is an easy way set up a cluster and create services. This repo helps to create the environment to run a few virtual machines based on the configuration in Vagrantfile.

## What to do next?

- clone this repo: git clone `https://github.com/charlyraffellini/docker-swarm-poc.git`.
- bring up the machines `vagrant up`.
- wait till vagrant download the ubuntu image and provisioning each machine. It could take 10 minutes or more.
- to connect to any machine run `vagrant ssh <machine name>`. For instance, `vagrant ssh m1`.
- to shut down the machines `vagrant halt`.
- Continue with the [exercises](https://github.com/charlyraffellini/docker-swarm-poc/blob/master/STEPS.md).
