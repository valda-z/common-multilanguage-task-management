<?php
require_once 'vendor\autoload.php';

use WindowsAzure\Common\ServicesBuilder;

use WindowsAzure\Common\ServiceException;

$connectionString = getenv("STORAGE_CONNECTION");
if ($connectionString == null)
    $connectionString = "";

$sbConnectionString = getenv("SB_CONNECTION");
if ($sbConnectionString == null)
    $sbConnectionString = "";

$baseAttachmentUrl = getenv("SB_BASE_ATTACH_PATH");
if ($baseAttachmentUrl == null)
    $baseAttachmentUrl = "https://zim.blob.core.windows.net/images/";

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
