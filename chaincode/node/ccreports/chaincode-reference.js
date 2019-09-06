const StorageChaincode = require('chaincode-node-storage');

module.exports = class ReferenceChaincode extends StorageChaincode {
    /**
     * ===========================================================================
     * Code bellow belong to ccreports/reports {chaincode/channel}
     * ===========================================================================
     */

    /**
     * [1] generate (optional) and return the report of task 1
     * @param args
     * @returns {Promise<Buffer>}
     */
    async report(args) {
        if (args.length < 1) {
            throw new Error('incorrect number of arguments, taskId at pos 0 is required');
        }
        let report = await super.list(['reports']).then(value => JSON.parse(value));
        if (!report || report.length == 0) {
            let tid = args[0];
            let data = await super.invokeChaincode('ccobservations', ['aggregate', tid], 'observations').then(value => JSON.parse(value));
            report = {tid: tid, data: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0}};
            for (let uid in data) {
                for (let activity in data[uid]) {
                    report.data[parseInt(activity) + 1] += data[uid][activity];
                }
            }
            let jsonReport = JSON.stringify(report);
            super.put(['reports', jsonReport]);
            return Buffer.from(jsonReport);
        } else {
            return Buffer.from(JSON.stringify(report));
        }
    }

    /**
     * check if the report is generated or not
     * @param args
     * @returns {Promise<Buffer>}
     */
    async exists(args) {
        if (args.length < 1) {
            throw new Error('incorrect number of arguments, taskId at pos 0 is required');
        }
        let tid = args[0];
        let response = await super.list(['reports']).then(value => JSON.parse(value));
        if (!response || response.length == 0) {
            return Buffer.from(JSON.stringify(false));
        } else {
            return Buffer.from(JSON.stringify(true));
        }
    }
};
