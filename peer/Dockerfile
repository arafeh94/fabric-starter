FROM docker.io/hyperledger/fabric-peer:1.4.1
RUN bash -c "apt-get update && apt-get install -y python3 python3-pip vim && pip3 install -U numpy && pip3 install sklearn"
ADD . /scripts


