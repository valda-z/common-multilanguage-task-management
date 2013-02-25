package com.fs180.sample.azure;

//Include the following imports to use table APIs
import java.io.*;
import java.net.URISyntaxException;
import java.security.InvalidKeyException;
import java.util.ArrayList;

import com.microsoft.windowsazure.services.blob.client.*;
import com.microsoft.windowsazure.services.core.ServiceException;
import com.microsoft.windowsazure.services.core.storage.*;
import com.microsoft.windowsazure.services.serviceBus.ServiceBusConfiguration;
import com.microsoft.windowsazure.services.serviceBus.ServiceBusContract;
import com.microsoft.windowsazure.services.serviceBus.ServiceBusService;
import com.microsoft.windowsazure.services.serviceBus.models.BrokeredMessage;

public class TaskManager {
	
	private static String storageConnectionString = null;
	private static com.microsoft.windowsazure.services.core.Configuration config = null;
	private static ServiceBusContract service = null;
	
	private static CloudBlobClient getBlobClient() throws InvalidKeyException, URISyntaxException
	{
		storageConnectionString = Configuration.getBlobConnectionString();
		// Retrieve storage account from connection-string
		CloudStorageAccount storageAccount =
		    CloudStorageAccount.parse(storageConnectionString);

		// Create the blob client
		return storageAccount.createCloudBlobClient();
	}
	
	public static void AddImage(String destName, InputStream stream, long fileSize) throws URISyntaxException, StorageException, InvalidKeyException, FileNotFoundException, IOException
	{
		// Create the blob client
		CloudBlobClient blobClient = getBlobClient();

		// Retrieve reference to a previously created container
		CloudBlobContainer container = blobClient.getContainerReference("images");

		// Create or overwrite the "myimage.jpg" blob with contents from a local file
		CloudBlockBlob blob = container.getBlockBlobReference(destName);

		blob.upload(stream, fileSize);
	}
	
	@SuppressWarnings("unchecked")
	public static Iterable<TaskEntity> getTasks() throws InvalidKeyException, URISyntaxException
	{

		ArrayList<TaskEntity> tasks = new ArrayList<TaskEntity>();
		
		//If cache is enabled try to retrieve tasks from cache and update if necessary
		if ( Configuration.getCacheEnabled()) {
			tasks = (ArrayList<TaskEntity>) Cache.getTasks();
			if ( tasks == null ) {
				//No tasks in cache, retrieve from the repository and cache
				ITaskRepository repo = TaskRepositoryFactory.GetRepository();
				tasks = (ArrayList<TaskEntity>) repo.GetList();
				
				Cache.updateTasks(tasks);
				return tasks;
			}
		}
		else
		{
			ITaskRepository repo = TaskRepositoryFactory.GetRepository();
			tasks = (ArrayList<TaskEntity>) repo.GetList();
		}
		
		return tasks;
	}
	
	public static void Add(TaskEntity task ) throws InvalidKeyException, URISyntaxException, StorageException
	{
		// Invalidate the cache, then add the task in the repository.
		Cache.invalidateCache();
		ITaskRepository repo = TaskRepositoryFactory.GetRepository();
		repo.Add(task);
		SendUpdate( "add", task.getName() );
	}
	
	public static void Delete(String taskId)
	{
		// Invalidate the cache, then delete it from the repository.
		Cache.invalidateCache();
		ITaskRepository repo = TaskRepositoryFactory.GetRepository();
		repo.Delete(taskId);
		SendUpdate( "delete", taskId );
	}
	
	public static void Update(String taskId, boolean status) 
	{
		// Invalidate the cache, then update the task in the repository.
		Cache.invalidateCache();
		ITaskRepository repo = TaskRepositoryFactory.GetRepository();
		repo.SetComplete(taskId, status);
		SendUpdate( "update", taskId + " : status set to : " + status );
	}
	
	public static void SendUpdate(String action, String msg)
	{
		// If we are using a service bus, send the given message.
		if ( Configuration.getSBEnabled() ) {
			try {
				sendMessage( action, msg );
			} catch (Exception ex) 
			{
				Logger.LogException(ex);
			}
		}
	}
	
	public static void sendMessage( String action, String msg ) throws ServiceException
	{
		// Get the values for the service bus.
		String serviceBus = Configuration.getSBName();
		String issuer = Configuration.getSBIssuer();
		String key = Configuration.getSBKey();
		String sbTopic = Configuration.getSBTopic();
		
		if ( config == null ) {
			config = ServiceBusConfiguration.configureWithWrapAuthentication(
						serviceBus, 
						issuer,
						key,
						".servicebus.windows.net/",
						"-sb.accesscontrol.windows.net/WRAPv0.9");
		}
		
		if ( service == null ) 
			service = ServiceBusService.create(config);
		
		
		BrokeredMessage message = new BrokeredMessage(msg);
		
		// Set the action property and which sample we are using
		message.setProperty( "action", action );
		message.setProperty( "sample" , "java" );
		
	    service.sendQueueMessage( sbTopic, message);
		
	}
}
