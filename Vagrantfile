# vi: set ft=ruby :

Vagrant.configure("2") do |config|

    config.vm.box = "ubuntu/xenial64"
    config.vm.provision "bash", path: "provisioning/node.bash", privileged: true

    (1..3).each do |sequence|
        config.vm.define "m#{sequence}" do |node|
            node.vm.network "private_network", ip: "192.168.99.20#{sequence}"
            node.vm.hostname = "m#{sequence}"
        end
    end

    (1..3).each do |sequence|
        config.vm.define "w#{sequence}" do |node|
            node.vm.network "private_network", ip: "192.168.99.21#{sequence}"
            node.vm.hostname = "w#{sequence}"
        end
    end

    config.vm.provider "virtualbox" do |v|
        v.memory = 2048
        v.cpus = 1
    end

end
