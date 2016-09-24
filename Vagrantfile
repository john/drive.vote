# -*- mode: ruby -*-
# vi: set ft=ruby :

ruby_version = File.read('.ruby-version').strip()

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/wily64"
  config.vm.network "private_network", ip: "192.168.42.100"
  config.vm.provider "virtualbox" do |v|
    v.memory = 4096
  end
  config.vm.synced_folder '.', '/opt/drive.vote'
  config.vm.provision "shell", inline: <<-SHELL
    apt-get install -y postgresql \
      postgresql-server-dev-9.4 \
      nodejs \
      redis-server \
      libreadline6-dev \
      zlib1g-dev \
      libssl-dev \
      libyaml-dev \
      libsqlite3-dev \
      sqlite3 \
      autoconf \
      libgdbm-dev \
      libncurses5-dev \
      automake \
      libtool \
      bison \
      pkg-config \
      libffi-dev
    sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'admin';"
  SHELL
  config.vm.provision "shell", privileged: false, env: {"RUBY_VERSION": ruby_version}, inline: <<-SHELL
    gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
    curl -sSL https://get.rvm.io | bash -s stable --ruby=$RUBY_VERSION
    source ~/.rvm/scripts/rvm
    gem install bundler
    cd /opt/drive.vote
    bin/setup
  SHELL
end
