const StorageChaincode = require('chaincode-node-storage');

module.exports = class ReferenceChaincode extends StorageChaincode {

    async tasks(args){
        return await super.list(['task'])
            .then(value => JSON.parse(value))
            .then(value => value.filter(obs => {
                let accept = true;
                return accept;
            }))
            .then(value => JSON.stringify(value));
    }

};
