BOX_NAME="rockylinux/8"
BOX_VERSION="5.0.0"

Vagrant.configure("2") do |config|
  config.vm.box = BOX_NAME
  config.vm.box_version = BOX_VERSION

  # TODO: use variables for ip addresses. can we use group_vars/pgrex.yml?
  config.vm.define "pgrex01" do |server|
    # slan
    server.vm.network "private_network", ip: "192.168.56.10"
    # dlan
    server.vm.network "private_network", ip: "192.168.57.10"
    # iclan
    server.vm.network "private_network", ip: "192.168.58.10"
    server.vm.network "private_network", ip: "192.168.59.10"
    # stonithlan
    server.vm.network "private_network", ip: "192.168.60.10"
  end

  config.vm.define "pgrex02" do |server|
    # slan
    server.vm.network "private_network", ip: "192.168.56.20"
    # dlan
    server.vm.network "private_network", ip: "192.168.57.20"
    # iclan
    server.vm.network "private_network", ip: "192.168.58.20"
    server.vm.network "private_network", ip: "192.168.59.20"
    # stonithlan
    server.vm.network "private_network", ip: "192.168.60.20"
  end
end
