<?php
require_once 'vendor\autoload.php';

use WindowsAzure\Common\ServicesBuilder;

use WindowsAzure\Common\ServiceException;

$connectionString = getenv("STORAGE_CONNECTION");
if ($connectionString == null)
    $connectionString = "";

$sbConnectionString = getenv("SB_CONNECTION");
if ($sbConnectionString == null)
    $sbConnectionString = "Endpoint=";

$sbEnable = getenv("SB_ENABLE");
if ($sbEnable == null)
    $sbEnable = true;
else
    $sbEnable = ($sbEnable && strtolower($sbEnable) == "true");

$tableRestProxy = ServicesBuilder::getInstance()->createTableService($connectionString);

$blobRestProxy = ServicesBuilder::getInstance()->createBlobService($connectionString);

if ($sbEnable)
    $serviceBusRestProxy = ServicesBuilder::getInstance()->createServiceBusService($sbConnectionString);

?>
