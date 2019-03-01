apt install unzip dialog openssh-server -y
wget https://github.com/rstracke/roger_skyline_1/archive/master.zip
unzip master.zip
cp -r roger_skyline_1-master/* root/rs
mkdir /root/rs
cp .bashrc /root/rs/tmp/.bashrctmp
cd /root/rs
cp res/.bashrc /root/.bashrc
cp /lib/systemd/system/getty@.service /root/rs/tmp/getty@.service
cp res/getty@.service /lib/systemd/system/getty@.service
./main.sh