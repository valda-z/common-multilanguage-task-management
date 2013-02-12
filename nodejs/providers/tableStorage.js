var azure = require('azure')
    , uuid = require('node-uuid');

module.exports = TableStorageTask;

function TableStorageTask(accountName, accountKey, tableName, partitionKey) {
    this.storageClient = azure.createTableService(accountName, accountKey);
    this.tableName = tableName;
    this.partitionKey = partitionKey;

    this.storageClient.createTableIfNotExists(tableName,
        function tableCreated(err) {
            if(err) {
                //Throws an error if the table exists
                //throw error;
            }
        });
};

TableStorageTask.prototype = {

    getAllTasks: function(callback) {
        var self = this;

        var query = azure.TableQuery
            .select()
            .from(self.tableName);

        self.storageClient.queryEntities(query,
            function(err, entities){
                if(err) {
                    callback(err);
                } else {
                    callback(null, entities);
                }
            });
    },


    //Add a task entity to table storage
    addItem: function(item, callback) {
        var self = this;

        // Modify task entity for table storage
        item.PartitionKey = self.partitionKey;
        item.Complete = { '@': { type: 'Edm.Boolean' }, '#': item.Complete };

        self.storageClient.insertEntity(self.tableName, item,
            function entityInserted(err) {
                if(err){
                    callback(err);
                }
                callback(null);
            });
    },

    //Delete an item in table storage using the rowkey
    deleteItem: function(key, callback) {
        var self = this;
        self.storageClient.deleteEntity('tasks'
            , {
                PartitionKey : self.partitionKey
                , RowKey : key
            }
            , function(error){
                if(!error){
                    //Entity deleted
                }
                callback(null);
            });
    },

    //Mark an item in table storage in/complete by rowkey in table storage
    updateItem: function(rowKey, isComplete, callback) {
        var self = this;
        self.storageClient.queryEntity(self.tableName, self.partitionKey, rowKey,
            function entityQueried(err, entity) {
                if(err) {
                    callback(err);
                }
                entity.Complete = { '@': { type: 'Edm.Boolean' }, '#': (isComplete == "True" || isComplete == "true")};
                self.storageClient.updateEntity(self.tableName, entity,
                    function entityUpdated(err) {
                        if(err) {
                            callback(err);
                        }
                        callback(null);
                    });
            });
    }
}