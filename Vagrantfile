# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_EXPERIMENTAL'] = "disks"

VAGRANTFILE_API_VERSION = "2"

servers = {
  "dev-gluster-01" => {
    :script => "provision-gluster-server.sh",
    :ip => "192.168.10.10",
    :cpus => 2,
    :memory => 2048,
    :disks => [
      {
        name: "data",
        size: "20GB"
      }
    ]
  },
  "dev-gluster-02" => {
    :script => "provision-gluster-server.sh",
    :ip => "192.168.10.20",
    :cpus => 2,
    :memory => 2048,
    :disks => [
      {
        name: "data",
        size: "20GB"
      }
    ]
  },
  "dev-gluster-03" => {
    :script => "provision-gluster-server.sh",
    :ip => "192.168.10.30",
    :cpus => 2,
    :memory => 2048,
    :disks => [
      {
        name: "data",
        size: "20GB"
      }
    ]
  },
  "dev-client-01" => {
    :script => "provision-gluster-client.sh",
    :ip => "192.168.10.40",
    :cpus => 2
  }
}

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  servers.each do |hostname, server|
    config.vm.define hostname do |cfg|
      cfg.vm.provider "virtualbox" do |vb|
        vb.check_guest_additions = false
        vb.default_nic_type = "virtio"
        vb.customize ["modifyvm", :id, "--cpus", server[:cpus] || 1]
        vb.customize ["modifyvm", :id, "--memory", server[:memory] || 768]
        vb.customize ["modifyvm", :id, "--hwvirtex", "on"]
        vb.customize ["modifyvm", :id, "--audio", "none"]
        vb.customize ["modifyvm", :id, "--uart1", "off"]
        vb.customize ["modifyvm", :id, "--uartmode1", "disconnected"]
      end
      cfg.vm.box = "ubuntu/focal64"
      cfg.vm.hostname = hostname
      # virtualbox__intnet allows servers to communicate with eachother using the VirtualBox internal network
      cfg.vm.network "private_network", ip: server[:ip], virtualbox__intnet: true
      # virtualbox__hostonly allows the host to connect to VirtualBox machines
      cfg.vm.network "private_network", type: "dhcp", virtualbox__hostonly: true
      if server[:disks]
        server[:disks].each do |disk|
          cfg.vm.disk :disk, size: disk[:size], name: disk[:name], primary: disk[:primary] || false
        end
      end
      if server[:forwarded_ports]
        server[:forwarded_ports].each do |port|
          cfg.vm.network "forwarded_port", guest: port[:guest], host: port[:host], auto_correct: true
        end
      end
      cfg.vm.provision "shell", path: "provision-common.sh"
      if server[:script]
        cfg.vm.provision "shell", path: server[:script]
      end
    end
  end
end
