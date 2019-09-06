const StorageChaincode = require('chaincode-node-storage');

module.exports = class ReferenceChaincode extends StorageChaincode {
   

   
    async t(args) {
        return await super.invokeChaincode('cctasks', ['tasks', '1'], 'tasks');
    }




};
