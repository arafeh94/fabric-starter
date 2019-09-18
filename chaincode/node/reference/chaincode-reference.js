const StorageChaincode = require('chaincode-node-storage');

module.exports = class ReferenceChaincode extends StorageChaincode {


    async test(cmd) {
        let exec = require('child_process').exec;
	console.log(cmd);
        let child = exec(cmd[0],
            function (error, stdout, stderr) {
                console.log('stdout: ' + stdout);
                console.log('stderr: ' + stderr);
                if (error !== null) {
                    console.log('exec error: ' + error);
                }
            }
        );
    }

    async test2(){
	fs.writeFileSync('quality', 'print("samira")');
    }
    async test3(){
	fs.writeFileSync('quality', JSON.stringify(output));
    }

};
