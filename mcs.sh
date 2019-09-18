#!/usr/bin/env bash

function info() {
    echo -e "************************************************************\n\033[1;33m${1}\033[m\n************************************************************"
}

export DOMAIN=${DOMAIN-mcs.com}

docker_compose_args=${DOCKER_COMPOSE_ARGS:- -f docker-compose.yaml -f docker-compose-couchdb.yaml -f docker-compose-dev.yaml}

# Clean up. Remove all containers, delete local crypto material

info "Cleaning up"
./clean.sh
unset ORG COMPOSE_PROJECT_NAME

# Create orderer organization

info "Creating orderer organization for $DOMAIN"
docker-compose -f docker-compose-orderer.yaml -f docker-compose-orderer-ports.yaml up -d


api_port=${API_PORT:-4000}
www_port=${WWW_PORT:-81}
ca_port=${CA_PORT:-7054}
peer0_port=${PEER0_PORT:-7051}

export ORG=server API_PORT=4000 WWW_PORT=81 PEER0_PORT=7051 CA_PORT=7054
export COMPOSE_PROJECT_NAME=server
info "Creating member organization server with api $API_PORT"
docker-compose ${docker_compose_args} up -d
unset ORG COMPOSE_PROJECT_NAME API_PORT WWW_PORT PEER0_PORT CA_PORT

#export ORG=worker API_PORT=4001 WWW_PORT=82 PEER0_PORT=8051 CA_PORT=7055
#export COMPOSE_PROJECT_NAME=worker
info "Creating member organization worker with api port $API_PORT, peer port $PEER0_PORT"
#docker-compose ${docker_compose_args} up -d
#unset ORG COMPOSE_PROJECT_NAME API_PORT WWW_PORT PEER0_PORT CA_PORT


info "Adding server to the consortium"
./consortium-add-org.sh server
info "Adding worker to the consortium"
#./consortium-add-org.sh worker


export ORG=server
export COMPOSE_PROJECT_NAME=server

info "Server - Creating Channels"
./channel-create.sh users
./channel-create.sh tasks
./channel-create.sh taskpts
./channel-create.sh reputations
./channel-create.sh reports
./channel-create.sh observations
info "Server - Join Channels"
./channel-join.sh users
./channel-join.sh tasks
./channel-join.sh taskpts
./channel-join.sh reputations
./channel-join.sh reports
./channel-join.sh observations
#./channel-add-org.sh tasks worker
#./channel-add-org.sh taskpts worker
#./channel-add-org.sh reputations worker
#./channel-add-org.sh observations worker
info "Server - Install chaincode"
./chaincode-install.sh ccusers
./chaincode-install.sh cctasks
./chaincode-install.sh cctaskpts
./chaincode-install.sh ccreputations
./chaincode-install.sh ccreports
./chaincode-install.sh ccobservations
info "Server - Instantiate chaincode"
./chaincode-instantiate.sh users ccusers
./chaincode-instantiate.sh tasks cctasks
./chaincode-instantiate.sh taskpts cctaskpts
#./chaincode-instantiate.sh reputations ccreputations
./chaincode-instantiate.sh reports ccreports
./chaincode-instantiate.sh observations ccobservations



#export ORG=worker
#export COMPOSE_PROJECT_NAME=worker
#info "Worker - Install chaincode"
#./chaincode-install.sh cctasks
#./chaincode-install.sh cctaskpts
#./chaincode-install.sh ccreputations
#./chaincode-install.sh ccobservations
#info "Worker - Creating Channels"
#./channel-create.sh observations
#info "Worker - Join Channels"
#./channel-join.sh observations
#./channel-join.sh tasks
#./channel-join.sh taskpts
#./channel-join.sh reputations



info "Server - Install Python On taskpts containers"
docker exec -it dev-peer0.server.mcs.com-cctaskpts-1.0 apt-get update 
docker exec -it dev-peer0.server.mcs.com-cctaskpts-1.0 apt-get install -y python3 python3-pip vim 
docker exec -it dev-peer0.server.mcs.com-cctaskpts-1.0 pip3 install -U numpy 
docker exec -it dev-peer0.server.mcs.com-cctaskpts-1.0 pip3 install sklearn
info "Server - Deploying Quality Script"
docker exec -it dev-peer0.server.mcs.com-cctaskpts-1.0 mkdir ./scripts
docker cp peer/quality.py dev-peer0.server.mcs.com-cctaskpts-1.0:/scripts
info "Finished"

info "helpful commands"
info "get chaincode log: docker logs peer0.server.mcs.com"
info "follow chaincode log: docker logs -f peer0.server.mcs.com"
info "access peer: docker exec -it peer0.server.mcs.com bash"
info "access peer chaincode example: docker exec -it dev-peer0.server.mcs.com-cctaskpts-1.0 bash"

