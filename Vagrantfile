Vagrant.configure("2") do |config|
  config.vm.box = "centos/8"
  config.vm.box_version = "2011.0"  # CentOS8.3

  config.vm.define "pgrex01" do |server|
    # slan
    server.vm.network "private_network", ip: "192.168.1.10"
    # dlan
    server.vm.network "private_network", ip: "192.168.2.10"
    # iclan
    server.vm.network "private_network", ip: "192.168.3.10"
    server.vm.network "private_network", ip: "192.168.4.10"
    # stonithlan
    server.vm.network "private_network", ip: "172.20.5.10"
  end

  config.vm.define "pgrex02" do |server|
    # slan
    server.vm.network "private_network", ip: "192.168.1.20"
    # dlan
    server.vm.network "private_network", ip: "192.168.2.20"
    # iclan
    server.vm.network "private_network", ip: "192.168.3.20"
    server.vm.network "private_network", ip: "192.168.4.20"
    # stonithlan
    server.vm.network "private_network", ip: "172.20.5.20"
  end
end
