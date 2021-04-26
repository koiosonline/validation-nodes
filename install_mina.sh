#!/bin/sh
systemctl --user stop mina

echo Starting mina install

sudo ls
# enter the sudo password

# installing some usefull tools
sudo apt  install -y jq

#allow external port
sudo ufw allow 8302/tcp
# sudo ufw allow from ..... to any port 3085

mkdir -p ~/mina
cd ~/mina
rm -f *.deb

wget http://mirrors.kernel.org/ubuntu/pool/main/libf/libffi/libffi6_3.2.1-8_amd64.deb
wget https://repo.percona.com/apt/pool/main/j/jemalloc/libjemalloc1_3.6.0-2.focal_amd64.deb
wget http://archive.ubuntu.com/ubuntu/pool/main/p/procps/libprocps6_3.3.12-3ubuntu1_amd64.deb
sudo apt install ./*.deb

sudo apt-get remove -y mina-mainnet
echo "deb [trusted=yes] https://packages.o1test.net release main" | sudo tee /etc/apt/sources.list.d/mina.list
sudo apt-get update
sudo apt-get install -y curl unzip mina-mainnet
sudo apt-get install -y  mina-generate-keypair

mina version
mkdir ~/.mina-config

if [ -e ~/keys/my-wallet.pub ]; then
echo "Already keys"
else
  mkdir -p ~/keys
  chmod 700 ~/keys
  echo Choose password
  mina-generate-keypair -privkey-path ~/keys/my-wallet
  chmod 600 ~/keys/my-wallet
fi


cat ~/keys/my-wallet.pub
echo Validating the keys
mina-validate-keypair -privkey-path ~/keys/my-wallet
#access graphql from outside
curl https://storage.googleapis.com/mina-seed-lists/mainnet_seeds.txt > ~/peers.txt

echo export MINA_PUBLIC_KEY="$(cat ~/keys/my-wallet.pub)">> ~/.profile
echo Add the password here below
echo CODA_PRIVKEY_PASS=""  > ~/.mina-env
echo EXTRA_FLAGS=" -file-log-level Debug -insecure-rest-server --limited-graphql-port 3095 >> ~/.mina-env
# additional EXTRA_FLAGS disabled for now:
# -run-snark-worker $(cat ~/keys/my-wallet.pub)"
# -peer-list-url https://storage.googleapis.com/mina-seed-lists/mainnet_seeds.txt

systemctl --user daemon-reload
systemctl --user stop mina
systemctl --user enable mina
systemctl --user start mina
sudo loginctl enable-linger

systemctl --user status mina

journalctl --user-unit mina -n 1000 -f

#watch -n 30 "mina client status | sed -e '/ip4/d' -e '/External/d'  -e '/Configuration/d'"
#mina accounts import -privkey-path ~/keys/my-wallet
#mina accounts list
#cat /usr/lib/systemd/user/mina.service


