const StorageChaincode = require('chaincode-node-storage');
const tools = require('chaincode-node-storage/chaincode-tools');
const ExpectationMaximization = require('ml-expectation-maximization').ExpectationMaximization;

module.exports = class ReferenceChaincode extends StorageChaincode {
    /**
     * ===========================================================================
     * Code bellow belong to cctaskpts/taskpts {chaincode/channel}
     * ===========================================================================
     */

    /**
     * data to fit for expectation maximisation are 2d array x=>user, y=>feature.
     * feature present the count of each activity
     * @param args
     * @returns {Promise<string>}
     */
    async quality(args) {
        console.log(this.createTaskpts('asd', 'asd', 10, 10));
        if (args.length < 1) {
            throw new Error('incorrect number of arguments, taskId at pos 0 is required');
        }
        let tid = args[0];
        let exists = await this.getTaskpts([tid]).then(value => JSON.parse(value));
        let data = await super.invokeChaincode('ccobservations', ['aggregate', tid], 'observations').then(value => JSON.parse(value));
        if (!data || tools.sizeOf(data) == 0) {
            throw new Error('no observations, please ensure you input the correct task id');
        } else {
            let training = [];
            for (let uid in data) {
                training.push(data[uid]);
            }
            const em = new ExpectationMaximization({numClusters: 1});
            em.train(training);
            // TODO: need a method to calculate the scores
            let scores = em.predict(training);
            let results = [];
            for (let uid in data) {
                let taskpts = this.createTaskpts(tid, uid, 10, 10);
                results.push(taskpts);
            }
            return Buffer.from(JSON.stringify(results));
        }
    }

	


    /**
     * [1] return all the taskpts of task 1
     * [1,1] return all the taskpts of user 1 in task 1
     * [false,1] return all the taskpts of user 1 in all tasks
     *
     * @param args
     * @returns {Promise<Buffer>}
     */
    async getTaskpts(args) {
        let tid = args[0] || false;
        let uid = args[1] || false;
        return super.list(['taskpts'])
            .then(value => JSON.parse(value))
            .then(value => value.filter(item => {
                let accept = true;
                if (tid !== false) {
                    accept = item.value.tid == tid;
                }
                if (accept && uid !== false) {
                    accept = item.value.uid == uid;
                }
                return accept;
            })).then(value => Buffer.from(JSON.stringify(value)))
    }

    createTaskpts($taskId, $userId, $quality, $payment) {
        return JSON.stringify({
            'tid': $taskId,
            'uid': $userId,
            'quality': $quality,
            'payment': $payment,
            'isDeleted': 0
        });
    }

};
