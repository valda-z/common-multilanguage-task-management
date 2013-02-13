var azure = require('azure')
    , uuid = require('node-uuid');


module.exports = BlobStore;

function BlobStore(accountName, accountKey, containerName) {
    this.blobService = azure.createBlobService(accountName, accountKey);
    this.containerName = containerName;
    this.blobService.createContainerIfNotExists(containerName, function(error){
        if(!error){
            // Container exists and is private
        }
    });
};

BlobStore.prototype = {
    upload: function(name, file, callback) {
        var self = this;

        this.blobService.createBlockBlobFromFile(this.containerName
            , name
            , file
            , function(error){
                callback(error);
            });
    }
}
