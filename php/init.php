<?php
require_once 'vendor\autoload.php';

use WindowsAzure\Common\ServicesBuilder;

use WindowsAzure\Common\ServiceException;

$connectionString = getenv("STORAGE_CONNECTION");
if ($connectionString == null)
    $connectionString = "DefaultEndpointsProtocol=http;AccountName=zim;AccountKey=0c26sS8E+Nz1BJmgWVRLMEUPKPwa1lt3jvdjjXgZQ/FVdjKJHGl2GV96jVJvciV8In290PXuNLPZBPc0AOvb2g==";

$sbConnectionString = getenv("SB_CONNECTION");
if ($sbConnectionString == null)
    $sbConnectionString = "Endpoint=https://invader.servicebus.windows.net/;SharedSecretIssuer=owner;SharedSecretValue=7TkK9JqQXbLdy5fH9mhEivU+Js4RpsVI9TaugN6/zdA=";

$sbEnable = getenv("SB_ENABLE");
if ($sbEnable == null)
    $sbEnable = false;
else
    $sbEnable = ($sbEnable && strtolower($sbEnable) == "true");

$tableRestProxy = ServicesBuilder::getInstance()->createTableService($connectionString);

$blobRestProxy = ServicesBuilder::getInstance()->createBlobService($connectionString);

if ($sbEnable)
    $serviceBusRestProxy = ServicesBuilder::getInstance()->createServiceBusService($sbConnectionString);

?>
