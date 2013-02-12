package com.fs180.sample.azure;

import java.io.IOException;
import java.io.InputStream;
import java.net.URISyntaxException;
import java.security.InvalidKeyException;
import java.util.UUID;

import javax.servlet.http.*;
import javax.servlet.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.annotation.MultipartConfig;

import com.microsoft.windowsazure.services.core.storage.StorageException;

@WebServlet(asyncSupported = false, name = "TaskServlet", urlPatterns = {"/Task"})
@MultipartConfig
public class TaskServlet extends HttpServlet implements Servlet {
	
	private static final long serialVersionUID = 1L;

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		try {
			AddTaskPost(req, resp);
		} catch (InvalidKeyException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IllegalStateException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (URISyntaxException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (StorageException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		//TODO: Some cleanup needed here - implement mvc pattern and use our .jsp as a simple view
		//getServletContext().getRequestDispatcher("/index.jsp").forward(req, resp);
		resp.sendRedirect("index.jsp");
	}
	
	@Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		
		String taskId = req.getParameter("delete");
		boolean delete = true;
		if ( taskId == null || taskId.isEmpty() ) {
			taskId = req.getParameter("complete");
			delete = false;
		}
		
		if ( null == taskId || taskId.isEmpty()  )
		{
			resp.sendRedirect("index.jsp");
			return;
		}

		if( delete )
			TaskManager.Delete(taskId);
		else {
			String val = req.getParameter("val");
			boolean status = ( val.equals("true") ? true : false );
			TaskManager.Update(taskId, status);
			
		}
		
		resp.sendRedirect("index.jsp");
    }
	
	protected void AddTaskPost(HttpServletRequest req, HttpServletResponse resp) throws IllegalStateException, IOException, ServletException, InvalidKeyException, URISyntaxException, StorageException
	{		
	    Part filePart = req.getPart("upload"); // Retrieves <input type="upload" name="upload">
	    String filename = getFilename(filePart);
	    
	    InputStream filecontent = filePart.getInputStream();
	    long fileSize = filePart.getSize();

	    String image = "";
	    
	    if (filename != null && !filename.isEmpty())
	    	image = UUID.randomUUID().toString() + filename.substring(filename.lastIndexOf('.'));
	    
		TaskEntity task = new TaskEntity();
		task.setName(req.getParameter("itemname"));
		task.setCategory(req.getParameter("category"));
		task.setDate(req.getParameter("date"));
		task.setComplete(false);
		task.setImage(image);
		
		TaskManager.Add(task);
		
		if ( null != filename && !filename.isEmpty())
			TaskManager.AddImage(image, filecontent, fileSize);
	}
	
	private static String getFilename(Part part)
	{

	    for (String cd : part.getHeader("content-disposition").split(";"))
	    {
	        if (cd.trim().startsWith("filename"))
	        {
	            String filename = cd.substring(cd.indexOf('=') + 1).trim().replace("\"", "");
	            return filename.substring(filename.lastIndexOf('/') + 1).substring(filename.lastIndexOf('\\') + 1); // MSIE fix.
	        }
	    }

	    return null;
	}
}
