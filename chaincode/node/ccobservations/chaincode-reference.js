const StorageChaincode = require('chaincode-node-storage');

module.exports = class ReferenceChaincode extends StorageChaincode {
    /**
     * ===========================================================================
     * Code bellow belong to ccobservations/observations {chaincode/channel}
     * ===========================================================================
     */
    /**
     * [1] return all the observations of task 1
     * [1,1] return all the observations of user 1 in task 1
     * [false,1] return all the observations of user 1 in all tasks
     * @param args
     * @returns {Promise<Buffer>}
     */
    async observations(args) {
        let tid = args[0] || false;
        let uid = args[1] || false;
        return super.list(['observation'])
            .then(value => JSON.parse(value))
            .then(value => value.filter(obs => {
                let accept = obs.isDeleted || true;
                if (tid !== false) {
                    accept = obs.value.tid == tid;
                }
                if (accept && uid !== false) {
                    accept = obs.value.uid == uid;
                }
                return accept;
            }))
            .then(value => Buffer.from(JSON.stringify(value)));
    }

    async aggregate(args) {
        let tid = args[0] || false;
        let uid = args[1] || false;
        let observations = await this.observations(args).then(value => JSON.parse(value));
        if (!observations) {
            return Buffer.from(JSON.stringify([]));
        } else {
            let data = {};
            for (let pos in observations) {
                let observation = observations[pos].value;
                let uid = observation.uid.toString();
                let record = JSON.parse(observation.record);
                if (!data[uid]) data[uid] = [];
                data[uid].push(parseInt(record.activity));
            }
            let agg = {};
            for (let uid in data) {
                let activities = data[uid];
                let set = [];
                [1, 2, 3, 4, 5, 6, 7].forEach(value => {
                    set[value] = activities.filter(act => {
                        return act == value
                    }).length;
                });
                set = set.filter(value => value != null || value != undefined);
                agg[uid] = set;
            }
            return Buffer.from(JSON.stringify(agg));
        }
    }
};
