var cas = require('cassandra-client')
    , uuid = require('node-uuid');

module.exports = CassandraTask;

function CassandraTask(ksHosts, ksName) {
    this.PooledCon = require('cassandra-client').PooledConnection;
    this.ksName = ksName;
    this.ksHosts = ksHosts;
    this.ksDefConOptions = { hosts: [ksHosts], keyspace: ksName, use_bigints: false };

    //TODO: Check for keyspace column family and add callbacks
    this.initialize();
};

CassandraTask.prototype = {
    initialize: function()
    {
        var self = this;

        var cql = 'SELECT keyspace_name from system.schema_keyspaces';
        var sysConOptions = { hosts: [self.ksHosts], keyspace: 'system', use_bigints: false };

        var con = new self.PooledCon(sysConOptions);

        self.createKeyspace();

        /*con.execute(cql, [], function(err, rows) {
            if (err) {
                console.log("Failed to check for Keyspace: " + self.ksName);
                console.log(err);
                //throw err;
            }
            else {
                //Check for and create keyspace
            }
        });*/
    },

    createKeyspace: function()
    {
        var self = this;

        var cql = 'CREATE KEYSPACE ' + self.ksName + ' WITH strategy_class=SimpleStrategy AND strategy_options:replication_factor=1';
        var sysConOptions = { hosts: [self.ksHosts], keyspace: 'system', use_bigints: false };

        var con = new self.PooledCon(sysConOptions);

        con.execute(cql, [], function(err) {
            if (err) {
                console.log("Failed to create Keyspace: " + self.ksName);
                console.log(err);
                //This will error if the keyspace already exists - need to determine how to check for this
                //throw err;
            }
            else {
                console.log("Created Keyspace: " + self.ksName);
                self.createTaskColumnFamily();
            }
        });
        con.shutdown();
    },

    createTaskColumnFamily: function()
    {
        var self = this;

        var params = ['Tasks','RowKey','text','Name', 'text','Category','text', 'Date', 'text', 'Complete', 'boolean', 'Image', 'text'];
        var cql = 'CREATE COLUMNFAMILY ? (? ? PRIMARY KEY,? ?, ? ?, ? ?, ? ?, ? ?)';

        var con =  new self.PooledCon(self.ksDefConOptions);
        con.execute(cql, params, function(err) {
            if (err) {
                console.log("Failed to create column family: " + params[0]);
                console.log(err);
            }
            else {
                console.log("Created column family: " + params[0]);
            }
        });
        con.shutdown();
    },

    getAllTasks: function(callback) {
        var self = this;

        var cql = 'SELECT * FROM Tasks';
        var con = new self.PooledCon(self.ksDefConOptions);

        con.execute(cql,[],function(err,rows) {
            if (err)
                console.log(err);
            else
            {
                var items = [];
                for (var i=0; i < rows.length; i++)
                {
                    var row = rows[i];
                    var item = new Object();
                    for (var l=0; l < row.cols.length; l++)
                    {
                        item[row.cols[l].name] = row.cols[l].value;
                        item.Image = '';
                    }
                    //TODO: if an item is not immediately deleted lets not return it - Need  to figure out a better approach
                    if (item.Date != null || item.Category != null || item.Name != null)
                        items.push(item);
                    //console.log(JSON.stringify(rows[i]));
                }
                callback(null, items);
            }
        });
        con.shutdown();
    },

    addItem: function(item, callback) {
        var self = this;

        var cql = 'INSERT INTO Tasks (RowKey, Name, Category, Date, Complete, Image) VALUES (?, ?, ?, ?, ?, ?)';
        var con = new self.PooledCon(self.ksDefConOptions);
        var params = [item.RowKey, item.Name, item.Category, item.Date, false, item.Image];

        con.execute(cql, params, function(err) {
            if (err) console.log(err);
            else console.log("Inserted customer : " + params[0]);
        });
        con.shutdown();

        callback(null);
    },

    deleteItem: function(key, callback) {
        var self = this;

        var cql = 'DELETE FROM Tasks WHERE RowKey=?';
        var con = new self.PooledCon(self.ksDefConOptions);
        var params = [key];

        con.execute(cql, params, function(err) {
            if (err) console.log(err);
            else console.log("Inserted customer : " + params[0]);
        });
        con.shutdown();

        callback(null);
    },

    updateItem: function(rowKey, isComplete, callback) {
        var self = this;

        var cql = 'UPDATE Tasks SET Complete=? WHERE RowKey=?';
        var con = new self.PooledCon(self.ksDefConOptions);
        var params = [isComplete,rowKey];

        con.execute(cql, params, function(err) {
            if (err) console.log(err);
            else console.log("Inserted customer : " + params[0]);
        });
        con.shutdown();

        callback(null);
    }
}