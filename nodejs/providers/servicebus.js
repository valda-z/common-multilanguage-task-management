var azure = require('azure')
    , uuid = require('node-uuid');


module.exports = AzureServiceBus;

function AzureServiceBus(connectionString, topic) {
    this.serviceBusService = azure.createServiceBusService(connectionString);
    this.topic = topic;

    var topicOptions = {
        MaxSizeInMegabytes: '5120',
        DefaultMessageTimeToLive: 'PT1M'
    };

    this.serviceBusService.createTopicIfNotExists(topic, topicOptions, function(error){
        if(!error){
            // topic was created or exists
        }
    });
};

AzureServiceBus.prototype = {
    sendMessage: function(action, msg) {
        var self = this;

        var message = {
            body: msg,
            customProperties: {
                action: action,
                sample: 'node.js'
            }
        }

        self.serviceBusService.sendTopicMessage(self.topic, message, function(error) {
            if (error) {
                console.log(error);
            }
        });
    }
}