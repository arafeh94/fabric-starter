const StorageChaincode = require('chaincode-node-storage');
const tools = require('chaincode-node-storage/chaincode-tools');

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
            let data_score = [];
            for (let uid in data) {
                data_score.push(data[uid]);
            }
            let scores = this.score(data_score);
            console.log("scores", scores);
            let results = [];
            let pos = 0;
            for (let uid in data) {
                let taskpts = this.createTaskpts(tid, uid, scores[pos++] || null, 10);
                results.push(taskpts);
            }
            return Buffer.from(JSON.stringify(results));
        }
    }


    score(data) {
        const spawn = require('child_process').spawn;
        const spawnSync = require('child_process').spawnSync;
        let jsonData = JSON.stringify(data);
        console.log("scoring data:", jsonData);
        const child = spawnSync('python3', ['/scripts/quality.py', jsonData]);
        const out = child.stdout.toString();
        console.log("python results:", out);
        try {
            return JSON.parse(out);
        } catch (e) {
            console.log("error while scoring", e);
            return [];
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
