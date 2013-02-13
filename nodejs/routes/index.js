var azure = require('azure')
    , async = require('async')
    , uuid = require('node-uuid')
    , express = require('express')
    , TaskEntity = require('../models/task');

module.exports = TaskController;

function TaskController(repository, blobStore, messaging, attachmentBaseUrl) {
    this.repository = repository;
    this.blobStore = blobStore;
    this.messaging = messaging;
    this.attachmentBaseUrl = attachmentBaseUrl;
}

TaskController.prototype = {
    home: function(req, res) {
        var self = this;

        self.repository.getAllTasks(function(err, items) {
            var app = express();
            res.render('index',{title: 'Node.js Task List', attachmentBaseUrl: self.attachmentBaseUrl, tasks: items});
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
        if (req.files.upload.name != '' && req.files.upload.size > 0)
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
            self.messaging.sendMessage('add', newTask.Name);
            res.redirect('/');
        });
    },

    deleteTask: function(req, res) {
        var self = this;
        self.repository.deleteItem(req.params.taskId, function(err) {
            // We need to retrieve the task or return deleted task from repository
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