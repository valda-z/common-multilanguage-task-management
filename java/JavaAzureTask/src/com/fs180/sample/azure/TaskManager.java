package com.fs180.sample.azure;

//Include the following imports to use table APIs
import java.io.*;
import java.net.URISyntaxException;
import java.security.InvalidKeyException;

import com.microsoft.windowsazure.services.blob.client.*;
import com.microsoft.windowsazure.services.core.storage.*;

import javax.jms.*;
import javax.naming.Context;
import javax.naming.InitialContext;

import java.util.Hashtable;

public class TaskManager {
	
	private static String storageConnectionString = null;
	private static javax.jms.Connection connection;
	private static Session sendSession;
	private static MessageProducer sender;
	private static Context context;
	
	private static CloudBlobClient getBlobClient() throws InvalidKeyException, URISyntaxException
	{
		storageConnectionString = Configuration.getConnectionString();
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
	
	public static Iterable<TaskEntity> getTasks() throws InvalidKeyException, URISyntaxException
	{
		ITaskRepository repo = TaskRepositoryFactory.GetRepository();

		return repo.GetList();
	}
	
	public static void Add(TaskEntity task ) throws InvalidKeyException, URISyntaxException, StorageException
	{
		
		ITaskRepository repo = TaskRepositoryFactory.GetRepository();
		repo.Add(task);
	}
	
	public static void Delete(String taskId)
	{
		
		ITaskRepository repo = TaskRepositoryFactory.GetRepository();
		repo.Delete(taskId);
	}
	
	// TODO - exception handling
	public static void SendUpdate(String action, String msg)
	{
		try {
			initiateJMSConnection();
			sendMessage( action, msg );
			closeJMSConnection();
		} catch (Exception ex) 
		{
			Logger.LogException(ex);
		}
	}
	
	public static void sendMessage( String action, String msg ) throws JMSException
	{
		// Create the message
		BytesMessage message = sendSession.createBytesMessage();
		// Set the body as the message
		message.writeObject( msg );
		// Include a property under 'action' as 'add' or 'delete'
		message.setStringProperty("action", action);
		// Include Client language as Java
		message.setStringProperty("sample", "java");
		// Send the message to the topic
		sender.send( message );
	}
	
	public static void initiateJMSConnection() 
	{
		try 
		{
			// Configure JNDI Environment
            Hashtable<String, String> env = new Hashtable<String, String>();
            env.put(Context.INITIAL_CONTEXT_FACTORY,
            "org.apache.qpid.amqp_1_0.jms.jndi.PropertiesFileInitialContextFactory");
            env.put(Context.PROVIDER_URL, "servicebus.properties");
            context = new InitialContext(env);
    
            // Lookup ConnectionFactory and Topic
            ConnectionFactory cf = (ConnectionFactory) context.lookup("SBCONNECTIONFACTORY");
            Destination topic = (Destination) context.lookup("TOPIC");
            
			// Create Connection
			connection = cf.createConnection();
			
			// Create sender-side Session and MessageProducer
            sendSession = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);
            sender = sendSession.createProducer(topic);
            
		} catch (Exception ex) 
		{
			Logger.LogException(ex);
		}
	}
	
	public static void closeJMSConnection() throws JMSException
	{
		sender.close();
		sendSession.close();
		connection.close();
	}

}
