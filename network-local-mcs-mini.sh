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


info "Adding Server to the consortium"
./consortium-add-org.sh server



info "Setting Up Server Organization"
export ORG=server
export COMPOSE_PROJECT_NAME=server

info "Server - channel: users"
./channel-create.sh users
./channel-join.sh users

info "Server - chaincode install"
./chaincode-install.sh ccusers
./chaincode-instantiate.sh users ccusers '["init","a","10","b","0"]'

