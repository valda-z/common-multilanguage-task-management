
/**
 * Module dependencies.
 */
var nconf = require('nconf');

nconf.env()
    .file({ file: 'config.json'});

var tableName = nconf.get("TABLE_NAME")
    , partitionKey = nconf.get("PARTITION_KEY")
    , accountName = nconf.get("STORAGE_NAME")
    , accountKey = nconf.get("STORAGE_KEY")
    , blobContainer = nconf.get("BLOB_CONTAINER")
    , storageProvider = nconf.get("STORAGE_PROVIDER")
    , casHosts = nconf.get("CAS_HOSTS")
    , casKsName = nconf.get("CAS_KS_NAME")
    , sbUse = nconf.get("SB_ENABLED")
    , sbConnectionString = nconf.get("SB_CONNECTION_STRING")
    , sbTopic = nconf.get("SB_TOPIC");

var express = require('express')
  , routes = require('./routes')
  , http = require('http')
  , path = require('path');

var app = express();

app.configure(function(){
  app.set('port', process.env.PORT || 3000);
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.favicon());
  app.use(express.logger('dev'));
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(app.router);
  app.use(express.static(path.join(__dirname, 'public')));
});

var TableStorageTaskProvider = require('./providers/tableStorage');
var CassandraTaskProvider = require('./providers/cassandra');
var BlobStore = require('./providers/blob');
var ServiceBus = require('./providers/servicebus');

//Create a task provider to store task data
var taskStore = null;
if (storageProvider == 'cas') {
    taskStore = new CassandraTaskProvider(casHosts, casKsName);
} else {
    taskStore = new TableStorageTaskProvider( accountName,accountKey ,tableName, partitionKey);
}

var blobStore = new BlobStore(accountName, accountKey, blobContainer);
var sb = null;
if (sbUse == 'true' || sbUse == 'True')
    sb = new ServiceBus(sbConnectionString, sbTopic);

var TaskController = require('./routes/index');

var taskController = new TaskController(taskStore, blobStore, sb);

//Configure Routes
app.get('/', taskController.home.bind(taskController));
app.get('/delete/:taskId', taskController.deleteTask.bind(taskController));
app.get('/complete/:taskId/:isComplete', taskController.completeTask.bind(taskController));
app.post('/add', taskController.addTask.bind(taskController));

app.configure('development', function(){
  app.use(express.errorHandler());
});

http.createServer(app).listen(app.get('port'), function(){
  console.log("Express server listening on port " + app.get('port'));
});
