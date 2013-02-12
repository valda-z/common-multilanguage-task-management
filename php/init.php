<?php
require_once 'vendor\autoload.php';

use WindowsAzure\Common\ServicesBuilder;

use WindowsAzure\Common\ServiceException;

$connectionString = getenv("STORAGE_CONNECTION");
if ($connectionString == null)
    $connectionString = "STORAGE_CONNECTION_STRING";

$sbConnectionString = getenv("SB_CONNECTION");
if ($sbConnectionString == null)
    $sbConnectionString = "<SERVICEBUS_CONNECTION_STRING>";

$tableRestProxy = ServicesBuilder::getInstance()->createTableService($connectionString);

$blobRestProxy = ServicesBuilder::getInstance()->createBlobService($connectionString);

$serviceBusRestProxy = ServicesBuilder::getInstance()->createServiceBusService($sbConnectionString);

?>
