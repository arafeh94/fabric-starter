#!/usr/bin/env bash

function info() {
    echo -e "************************************************************\n\033[1;33m${1}\033[m\n************************************************************"
}

export DOMAIN=${DOMAIN-mcs.com}

orgs=${@:-org1}
first_org=${1:-org1}

channel=${CHANNEL:-common}
chaincode_install_args=${CHAINCODE_INSTALL_ARGS:-reference}
chaincode_instantiate_args=${CHAINCODE_INSTANTIATE_ARGS:-common reference}
docker_compose_args=${DOCKER_COMPOSE_ARGS:- -f docker-compose.yaml -f docker-compose-couchdb.yaml -f docker-compose-dev.yaml}

# Clean up. Remove all containers, delete local crypto material

info "Cleaning up"
./clean.sh
unset ORG COMPOSE_PROJECT_NAME

# Create orderer organization

info "Creating orderer organization for $DOMAIN"
docker-compose -f docker-compose-orderer.yaml -f docker-compose-orderer-ports.yaml up -d

# Create member organizations

api_port=${API_PORT:-4000}
#dev:
www_port=${WWW_PORT:-81}
ca_port=${CA_PORT:-7054}
peer0_port=${PEER0_PORT:-7051}
#

export ORG=server API_PORT=${api_port} WWW_PORT=${www_port} PEER0_PORT=${peer0_port} CA_PORT=${ca_port}
export COMPOSE_PROJECT_NAME=server
info "Creating member organization $ORG with api $API_PORT"
docker-compose ${docker_compose_args} up -d
api_port=$((api_port + 1))
www_port=$((www_port + 1))
ca_port=$((ca_port + 1))
peer0_port=$((peer0_port + 1000))
unset ORG COMPOSE_PROJECT_NAME API_PORT WWW_PORT PEER0_PORT CA_PORT


# Add member organizations to the consortium


info "Adding $org to the consortium"
./consortium-add-org.sh server


# First organization creates the channel

export ORG=server
export COMPOSE_PROJECT_NAME=server

info "Creating channel ${channel} by $ORG"
./channel-create.sh common
./channel-join.sh common


# First organization creates the chaincode

./chaincode-install.sh reference
./chaincode-instantiate.sh common reference






