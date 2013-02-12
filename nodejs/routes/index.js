var azure = require('azure')
    , async = require('async')
    , uuid = require('node-uuid')
    , TaskEntity = require('../models/task');

module.exports = TaskController;

function TaskController(repository, blobStore, messaging) {
    this.repository = repository;
    this.blobStore = blobStore;
    this.messaging = messaging;
}

TaskController.prototype = {
    home: function(req, res) {
        var self = this;

        self.repository.getAllTasks(function(err, items) {
            res.render('index',{title: 'Task List ', tasks: items});
        });
    },

    addTask: function(req, res) {
        var self = this;

        var item = req.body.item;
        var newTask = new TaskEntity();
        newTask.Name = item.Name;
        newTask.Category = item.Category;
        newTask.Date = item.Date;
        newTask.Complete = false;
        if (req.files.upload != null && req.files.upload.path != null)
        {
            var tmpFile = req.files.upload.path;
            var fileName = req.files.upload.name;
            var i = fileName.lastIndexOf('.');
            var ext =  (i < 0) ? '' : fileName.substr(i);

            fileName = uuid.v1() + ext;

            newTask.Image = fileName;

            self.blobStore.upload(fileName, tmpFile, function(){
                //handle error
            });
        }

        self.repository.addItem(newTask, function (err) {
            res.redirect('/');
        });
    },

    deleteTask: function(req, res) {
        var self = this;
        self.repository.deleteItem(req.params.taskId, function(err) {
            res.redirect('/');
        });
    },

    completeTask: function(req,res) {
        var self = this;
        self.repository.updateItem(req.params.taskId, req.params.isComplete, function(err) {
            res.redirect('/');
        });
    }
}