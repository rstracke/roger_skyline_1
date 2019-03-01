apt install unzip dialog openssh-server -y
wget https://github.com/rstracke/roger_skyline_1/archive/master.zip
unzip master.zip
mkdir /root/rs
cp -r roger_skyline_1-master/* /root/rs
./main.sh