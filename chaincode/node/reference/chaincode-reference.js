const StorageChaincode = require('chaincode-node-storage');

module.exports = class ReferenceChaincode extends StorageChaincode {


    async addUser(args) {
        let rpr = [];

        rpr.push(await super.put(['user', "11", "{name:\"arafeh\"}"]));
        rpr.push(await super.put(['user', "21", "{name:\"arafeh\"}"]));
        rpr.push(await super.put(['user', "31", "{name:\"arafeh\"}"]));
        rpr.push(await super.put(['user', "41", "{name:\"arafeh\"}"]));
	
	return Buffer.from(JSON.stringify(rpr));

    }

};
