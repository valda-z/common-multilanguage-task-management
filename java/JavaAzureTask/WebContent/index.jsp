<%@page import="com.fs180.sample.azure.*"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>

<!DOCTYPE html>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta charset="utf-8" />
    <title>Azure Java Task List</title>
    <link href="site.css" rel="stylesheet" type="text/css" />

    <link href="http://ajax.aspnetcdn.com/ajax/jquery.ui/1.9.2/themes/smoothness/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="http://ajax.aspnetcdn.com/ajax/jQuery/jquery-1.8.3.js" ></script>
    <script src="http://ajax.aspnetcdn.com/ajax/jquery.ui/1.9.2/jquery-ui.js"></script>

    <link href="css/lightbox.css" rel="stylesheet" />
    <script src="js/lightbox.js"></script>

    <script>
        $(function()
        {
            var tomorrow = new Date();
            tomorrow.setDate(tomorrow.getDate() + 1);
            var dateString =(tomorrow.getMonth()+1) + '/' + tomorrow.getDate() + '/' +
                    tomorrow.getFullYear();
            $("#datepicker").val(dateString);

            $( "#datepicker" ).datepicker();

            $('#create').click(function(e) {
                $('#additemform').submit();
            });

            $('#select-complete').live("change", function () {
                window.location.href = 'markitem.php?pk=' + $(this).val();
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
        <table>
            <thead>
            <tr>
                <th class="name">Name</th>
                <th class="category">Category</th>
                <th class="small">Date</th>
                <th class="collapse">Complete</th>
                <th class="collapse">Attachment</th>
                <th class="collapse">Delete</th>
            </tr>
            </thead>
            <tbody>
            <%
        		for (TaskEntity entity : TaskManager.getTasks()) {
        	%>
                <tr>
                    <td><%=entity.getName() %></td>
                    <td><%=entity.getCategory() %></td>
                    <td><%=entity.getDate() %></td>
                    <td>
                    <%if (entity.getComplete()) { %>
                        <a href="Task?complete=<%=entity.getRowKey()%>&val=false"><img src="images/checked.png" alt="complete" title="complete" /></a>
                    <%} else { %>
                    	<a href="Task?complete=<%=entity.getRowKey()%>&val=true"><img src="images/unchecked.png" alt="incomplete" title="incomplete" /></a>
                    <%} %>
                    </td>
                    <td class="align-center">
                    <%if (entity.getImage() != null && !entity.getImage().isEmpty()) { %>
                    <a href="<%=Configuration.getEntityImageLocation() + entity.getImage() %>" rel="lightbox"><img src="images/icon-image.png" alt="image" title="image" /></a>
                    <%} %>
                    </td>
                    <td class="align-center">
                    	<a href="Task?delete=<%=entity.getRowKey()%>"><img src="images/icon-delete.png" alt="delete" title="delete" /></a>
                    </td>
                </tr>
              <%}%>
            </tbody>
        </table>
        </div>
    	<div class="widget">
        <form id="additemform" name="additemform" action="Task" method="post" enctype="multipart/form-data">
        <div class="add-container">
	        <h2>Add Item</h2>
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
	    </form>
    </div>
    <footer><a href="#" target="_blank">View Project</a>
        <img src="images/lang-java.png" alt="language icon" title="language icon" />
    </footer>
</div>
</body>
</html>