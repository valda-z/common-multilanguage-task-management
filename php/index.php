<!DOCTYPE html>

<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta charset="utf-8" />
    <title>PHP Azure Task List</title>
    <link href="site.css" rel="stylesheet" type="text/css" />

    <link href="http://ajax.aspnetcdn.com/ajax/jquery.ui/1.9.2/themes/smoothness/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="http://ajax.aspnetcdn.com/ajax/jQuery/jquery-1.8.3.js" ></script>
    <script src="http://ajax.aspnetcdn.com/ajax/jquery.ui/1.9.2/jquery-ui.js"></script>

    <link href="css/lightbox.css" rel="stylesheet" />
    <script src="js/lightbox.js"></script>

    <script>
        $(function()
        {
            $( "#datepicker" ).datepicker();

            $('#create').click(function(e) {
                $('#additemform').submit();
            });

            var is_chrome = navigator.userAgent.toLowerCase().indexOf('chrome') > -1;

            if (is_chrome)
            {
                $('#uploadbutton').click(function(e) {
                    e.preventDefault();
                    $('#upload').trigger('click');
                });

                $('#upload').live("change", function() {
                    $('#imagename').html(this.value.split('\\').pop())
                });
            }
            else
            {
                $('#upload').css('display','block');
                $('#uploadlabel').css('display','block');
                $('#uploadbutton').css('display', 'none');
            }
        });
    </script>

</head>

<body>

<div class="container">
    <h1>Azure Task List</h1>
    <div id="main-body">
<?php
require_once "init.php";

try {
    $result = $tableRestProxy->queryEntities('tasks');
}
catch(ServiceException $e){
    $code = $e->getCode();
    $error_message = $e->getMessage();
    echo $code.": ".$error_message."<br />";
}

    $entities = $result->getEntities();


for ($i = 0; $i < count($entities); $i++) {
    if ($i == 0) {
        echo "<table>
            <thead>
                <tr>
                    <td class=\"name\">Name</td>
                    <td class=\"category\">Category</td>
                    <td class=\"small\">Date</td>
                    <td class=\"small\">Complete</td>
                    <td class=\"collapse\">Image</td>
                    <td class=\"collapse\">Delete</td>
                </tr>
            </thead>
            <tbody>";
    }
    echo "
        <tr>
            <td>".$entities[$i]->getPropertyValue('Name')."</td>
            <td>".$entities[$i]->getPropertyValue('Category')."</td>
            <td>".$entities[$i]->getPropertyValue('Date')."</td>";

    if ($entities[$i]->getPropertyValue('Complete') == true)
        echo "<td><a href='completetask.php?complete=false&pk=".$entities[$i]->getPartitionKey()."&rk=".$entities[$i]->getRowKey()."'><img src=\"images/checked.png\" alt=\"complete\" title=\"complete\" /></a></td>";
    else
        echo "<td><a href='completetask.php?complete=true&pk=".$entities[$i]->getPartitionKey()."&rk=".$entities[$i]->getRowKey()."'><img src=\"images/unchecked.png\" alt=\"complete\" title=\"complete\" /></a></td>";

    echo "<td class=\"align-center\">";

    if ($entities[$i]->getPropertyValue('Image') != '')
    {
        echo "<a href=\"".$baseAttachmentUrl. "" .$entities[$i]->getPropertyValue('Image')."\" rel=\"lightbox\"><img src=\"images/icon-image.png\" alt=\"image\" title=\"image\" /></a>";
    }

    echo "</td>
            <td class=\"align-center\">
            <a href='deletetask.php?pk=".$entities[$i]->getPartitionKey()."&rk=".$entities[$i]->getRowKey()."'><img src=\"images/icon-delete.png\" alt=\"delete\" title=\"delete\" /></a>
         </td>
        </tr>";
}


if ($i > 0)
    echo "</tbody>
        </table>";
else
    echo "<h3>No items on list.</h3>";
?>
</div>
    <form id="additemform" name="additemform" action="addtask.php" method="post" enctype="multipart/form-data">
        <div class="widget">
            <div class="add-container">
                <h2>Add Task</h2>
                <label>Item Name</label>
                <input name="itemname" type="text" />
                <label>Category</label>
                <input name="category" type="text" />
                <label>Date</label>
                <input id="datepicker" name="date" type="text" value="11/28/12" class="small calendar" />
                <label id="uploadlabel" style="display:none;">Image</label>
                <input type="file" id="upload" name="upload" style="display:none;" />
                <div class="clear"></div>
                <a href="#" id="uploadbutton" class="upload" >image</a><span id="imagename"></span><!---- Just name of image being uploaded goes here ---->
                <a href="#" id="create" class="create">create</a>
            </div>
        </div>
    </form>
    <footer><a href="http://task.codeplex.com" target="_blank">View Project</a>
        <img src="images/lang-php.png" alt="language icon" title="language icon" />
    </footer>
</div>
</body>
</html>
