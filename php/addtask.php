<?php
require_once "init.php";
use WindowsAzure\Table\Models\Entity;
use WindowsAzure\Table\Models\EdmType;

use WindowsAzure\ServiceBus\Models\BrokeredMessage;

$imageName = (!empty($_FILES['upload']['tmp_name'])) ? gen_uuid() . '.' . pathinfo($_FILES['upload']['name'], PATHINFO_EXTENSION) : '';

$entity = new Entity();
$entity->setPartitionKey('p1');
$entity->setRowKey((string) microtime(true));
$entity->addProperty('Name', EdmType::STRING, $_POST['itemname']);
$entity->addProperty('Category', EdmType::STRING, $_POST['category']);
$entity->addProperty('Date', EdmType::STRING, $_POST['date']);
$entity->addProperty('Complete', EdmType::BOOLEAN, false);
$entity->addProperty('Image', EdmType::STRING, $imageName);

try{
    //If we have a file upload it to BLOB storage using the image names
    if(!empty($_FILES['upload']['tmp_name'])){
        $blobRestProxy->createBlockBlob('images', $imageName, fopen($_FILES['upload']['tmp_name'],"r"));
    }

    $tableRestProxy->insertEntity('tasks', $entity);

    // Create message.
    $message = new BrokeredMessage();
    $message->setProperty('action','add');
    $message->setProperty('sample','php');
    $message->setBody($_POST['itemname']);

    // Send message.
    $serviceBusRestProxy->sendTopicMessage("tasks", $message);

}
catch(ServiceException $e){
    $code = $e->getCode();
    $error_message = $e->getMessage();
    echo $code.": ".$error_message."<br />";
}

header('Location: index.php');

function gen_uuid() {
    return sprintf( '%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
        // 32 bits for "time_low"
        mt_rand( 0, 0xffff ), mt_rand( 0, 0xffff ),

        // 16 bits for "time_mid"
        mt_rand( 0, 0xffff ),

        // 16 bits for "time_hi_and_version",
        // four most significant bits holds version number 4
        mt_rand( 0, 0x0fff ) | 0x4000,

        // 16 bits, 8 bits for "clk_seq_hi_res",
        // 8 bits for "clk_seq_low",
        // two most significant bits holds zero and one for variant DCE1.1
        mt_rand( 0, 0x3fff ) | 0x8000,

        // 48 bits for "node"
        mt_rand( 0, 0xffff ), mt_rand( 0, 0xffff ), mt_rand( 0, 0xffff )
    );
}
?>
