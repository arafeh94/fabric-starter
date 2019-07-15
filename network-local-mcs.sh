#!/usr/bin/env bash

function info() {
    echo -e "************************************************************\n\033[1;33m${1}\033[m\n************************************************************"
}

DOMAIN=mcs.com

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

info "channel: users"
./channel-create.sh users
./channel-join.sh users


info "channel: tasks"
./channel-create.sh tasks
./channel-add-org.sh tasks worker
./channel-join.sh tasks


info "channel: taskParticipants"
./channel-create.sh taskParticipants
./channel-add-org.sh taskParticipants worker
./channel-join.sh taskParticipants


info "channel: reputations"
./channel-create.sh reputations
./channel-add-org.sh reputations worker
./channel-join.sh reputations

info "channel: observations"
./channel-create.sh observations
./channel-add-org.sh observations worker

info "channel: reports"
./channel-create.sh reports
./channel-join.sh reports

info "chaincode install"
./chaincode-install.sh ccusers
./chaincode-instantiate.sh users ccusers

./chaincode-install.sh cctasks
./chaincode-instantiate.sh tasks cctasks

./chaincode-install.sh cctaskparticipants
./chaincode-instantiate.sh taskParticipants cctaskparticipants

./chaincode-install.sh ccreputations
./chaincode-instantiate.sh reputations ccreputations

./chaincode-install.sh ccreports
./chaincode-instantiate.sh reports ccreports

info "Setting Up Worker Organization"
export ORG=worker
export COMPOSE_PROJECT_NAME=worker

info "channel: tasks"
./channel-join.sh tasks

info "channel: taskParticipants"
./channel-join.sh taskParticipants


info "channel: reputations"
./channel-join.sh reputations

info "channel: observations"
./channel-join.sh observations


info "chaincode install"
./chaincode-install.sh cctasks
./chaincode-instantiate.sh tasks cctasks

./chaincode-install.sh cctaskparticipants
./chaincode-instantiate.sh taskParticipants cctaskparticipants

./chaincode-install.sh ccreputations
./chaincode-instantiate.sh reputations ccreputations

./chaincode-install.sh ccobservations
./chaincode-instantiate.sh observations ccobservations
