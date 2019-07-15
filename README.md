# Decentralised Mobile Crowd Sensing Using Hyperledger Fabric

##Run: 
### Required Ubuntu 18

```bash
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update
sudo apt-get install docker-ce

sudo curl -L "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

sudo usermod -aG docker ${USER}

sudo curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo chmod +x ./network-local-mcs.sh
```

>###re-login

```bash
./network-local-mcs.sh
```


##Description: 
create a local mobile crowd sensing network composed from 2 organisation server and worker, the first one focus on the users and tasks management while the later focus on receiving data from users and calculating reputations and quantifying data quality

##Need to develop:
 - Chaincodes
 - Server Websites to register participants and clients
 - Server Websites to take task request from clients and show reports
 - Worker Observations Receiver API
