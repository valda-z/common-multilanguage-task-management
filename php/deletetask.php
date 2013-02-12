<?php
require_once "init.php";

use WindowsAzure\ServiceBus\Models\BrokeredMessage;
use WindowsAzure\Table\Models\EdmType;

date_default_timezone_set('UTC');

try{
    $result = $tableRestProxy->getEntity('tasks', $_GET['pk'], $_GET['rk']);
    $entity = $result->getEntity();
    $taskname = $entity->getPropertyValue('Name');

    $tableRestProxy->deleteEntity('tasks', $_GET['pk'], $_GET['rk']);

    // Create message.
    $message = new BrokeredMessage();
    $message->setProperty('action','delete');
    $message->setProperty('sample','php');
    $message->setBody($taskname);

    // Send message.
    $serviceBusRestProxy->sendTopicMessage("tasks", $message);
}
catch(ServiceException $e){
    $code = $e->getCode();
    $error_message = $e->getMessage();
    echo $code.": ".$error_message."<br />";
}
header('Location: index.php');

?>
