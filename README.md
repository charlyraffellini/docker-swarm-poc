# docker-swarm-poc
Prove of concept of docker swarm

In order to run vagrant in this example you need to have Virtual Box installed.

I am going to detail how to use this script.

In the vagrant definition, we have a set of managers and worker instances.

The names of the instances are going to be `m1,m2` for the managers and `w1, w2, w3` for the workers.

Also, we can hit the manager IPs with `192.168.99.20#{1,2}` and the worker IPs with `192.168.99.21#{1,2,3}`, where the sequence number match with the name suffix of the corresponding name.

For instance, supose I want to refer the manager 1 then the adress of it is `192.168.99.20*1*` or the adress of the worker 3 is `192.168.99.21*3*`

Wde are going to run `vagrant up m1 m2 w1 w2` to bring one manager and two workers live. Or you can run `vagrant up` to turn on all of the machines.

Once you finish you can run `vagrant halt` to turn down all the virtual machines.
asf
