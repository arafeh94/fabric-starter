#!/usr/bin/env bash

function info() {
    echo -e "************************************************************\n\033[1;33m${1}\033[m\n************************************************************"
}

export DOMAIN=mcs.com

info "Cleaning up"
./clean.sh


info "Creating Orderer"
docker-compose -f docker-compose-orderer.yaml -f docker-compose-orderer-ports.yaml up -d


info "Creating member organization Server with api 4000"
export ORG=server API_PORT=4000 WWW_PORT=81 PEER0_PORT=7054 CA_PORT=7051
export COMPOSE_PROJECT_NAME=server
docker-compose -f docker-compose.yaml -f docker-compose-couchdb.yaml -f docker-compose-dev.yaml up -d
unset ORG COMPOSE_PROJECT_NAME API_PORT WWW_PORT PEER0_PORT CA_PORT

info "Creating member organization Worker with api 4001"
export ORG=worker API_PORT=4001 WWW_PORT=82 PEER0_PORT=8054 CA_PORT=7052
export COMPOSE_PROJECT_NAME=worker
docker-compose -f docker-compose.yaml -f docker-compose-couchdb.yaml -f docker-compose-dev.yaml up -d
unset ORG COMPOSE_PROJECT_NAME API_PORT WWW_PORT PEER0_PORT CA_PORT

info "Adding Server to the consortium"
./consortium-add-org.sh server

info "Adding Worker to the consortium"
./consortium-add-org.sh worker


info "Setting Up Server Organization"
export ORG=server
export COMPOSE_PROJECT_NAME=server

info "Server - channel: users"
./channel-create.sh users
./channel-join.sh users


info "Server - channel: tasks"
./channel-create.sh tasks
./channel-add-org.sh tasks worker
./channel-join.sh tasks

info "Server - channel: TaskParticipants"
./channel-create.sh taskpts
./channel-add-org.sh taskpts worker
./channel-join.sh taskpts


info "Server - channel: reputations"
./channel-create.sh reputations
./channel-add-org.sh reputations worker
./channel-join.sh reputations


info "Server - channel: reports"
./channel-create.sh reports
./channel-join.sh reports

info "Server - chaincode install"
./chaincode-install.sh ccusers
./chaincode-install.sh cctasks
./chaincode-install.sh cctaskpts
./chaincode-install.sh ccreputations
./chaincode-install.sh ccreports
./chaincode-instantiate.sh users ccusers '["init","a","10","b","0"]'
./chaincode-instantiate.sh tasks cctasks '["init","a","10","b","0"]'
./chaincode-instantiate.sh taskpts cctaskpts '["init","a","10","b","0"]'
./chaincode-instantiate.sh reputations ccreputations '["init","a","10","b","0"]'
./chaincode-instantiate.sh reports ccreports '["init","a","10","b","0"]'


info "Setting Up Worker Organization"
export ORG=worker
export COMPOSE_PROJECT_NAME=worker

info "Worker - channel: tasks"
./channel-join.sh tasks

info "Worker - channel: TaskParticipants"
./channel-join.sh taskpts

info "Worker - channel: reputations"
./channel-join.sh reputations

info "Worker - channel: observations"
./channel-create.sh observations
./channel-join.sh observations


info "Worker - chaincode install"
./chaincode-install.sh cctasks
./chaincode-install.sh cctaskpts
./chaincode-install.sh ccreputations
./chaincode-install.sh ccobservations
./chaincode-instantiate.sh tasks cctasks '["init","a","10","b","0"]'
./chaincode-instantiate.sh taskpts cctaskpts '["init","a","10","b","0"]'
./chaincode-instantiate.sh reputations ccreputations '["init","a","10","b","0"]'
./chaincode-instantiate.sh observations ccobservations '["init","a","10","b","0"]'

