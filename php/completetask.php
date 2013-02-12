<?php
require_once "init.php";

$result = $tableRestProxy->getEntity('tasks', $_GET['pk'], $_GET['rk']);
$entity = $result->getEntity();

$entity->setPropertyValue('Complete', ($_GET['complete'] == 'true') ? true : false);

try{
    $result = $tableRestProxy->updateEntity('tasks', $entity);
}
catch(ServiceException $e){
    $code = $e->getCode();
    $error_message = $e->getMessage();
    echo $code.": ".$error_message."<br />";
}

header('Location: index.php');
?>
