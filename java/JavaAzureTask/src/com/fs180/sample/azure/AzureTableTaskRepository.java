package com.fs180.sample.azure;

import java.net.URISyntaxException;
import java.security.InvalidKeyException;
import java.util.ArrayList;

import com.microsoft.windowsazure.services.core.storage.*;
import com.microsoft.windowsazure.services.table.client.*;
import com.microsoft.windowsazure.services.table.client.TableQuery.QueryComparisons;

public class AzureTableTaskRepository implements ITaskRepository {
	
	private static String storageConnectionString;

	private CloudTableClient getTableClient() throws InvalidKeyException, URISyntaxException
	{
		storageConnectionString = Configuration.getConnectionString();
		
		CloudStorageAccount storageAccount =
			    CloudStorageAccount.parse(storageConnectionString);

		// Create the table client.
		return storageAccount.createCloudTableClient();
	}

	@Override
	public Iterable<TaskEntity> GetList() throws InvalidKeyException, URISyntaxException {
		
		// Create the table client.
		CloudTableClient tableClient = getTableClient();

		// Create a filter condition where the partition key is "Smith".
		String partitionFilter = TableQuery.generateFilterCondition(
		    TableConstants.PARTITION_KEY, 
		    QueryComparisons.EQUAL,
		    "p1");

		// Specify a partition query, using "Smith" as the partition key filter.
		TableQuery<TaskEntity> partitionQuery =
		    TableQuery.from("tasks", TaskEntity.class)
		    .where(partitionFilter);

		ArrayList<TaskEntity> tasks = new ArrayList<TaskEntity>();
		for ( TaskEntity t : tableClient.execute(partitionQuery) ) 
			tasks.add(t);
		
		return tasks;
	}

	@Override
	public void Add(TaskEntity task) throws InvalidKeyException, URISyntaxException, StorageException {
		
		task.setRowKey( task.getId() );
		// Create the table client.
		CloudTableClient tableClient = getTableClient();
		
		// Create an operation to add the new customer to the people table.
		TableOperation insertTask = TableOperation.insert(task);

		// Submit the operation to the table service.
		tableClient.execute("tasks", insertTask);
	}

	@Override
	public void SetComplete(String taskId, boolean status) {
		// Create the table client.
		try {
			CloudTableClient tableClient = getTableClient();
			
			TableOperation getTask = TableOperation.retrieve("p1", taskId, TaskEntity.class);

			TaskEntity task = tableClient.execute("tasks", getTask).getResultAsType();
			
			task.setComplete( status );
			
			// Create an operation to delete the entity.
			TableOperation updateTask = TableOperation.replace(task);

			// Submit the delete operation to the table service.
			tableClient.execute("tasks", updateTask);
			
		} catch (InvalidKeyException | URISyntaxException | StorageException ex) {
			// TODO Best effort delete =)
			Logger.LogException(ex);
		}
		
	}

	@Override
	public void Delete(String taskId) {
		// Create the table client.
		try {
			CloudTableClient tableClient = getTableClient();
			
			TableOperation getTask = TableOperation.retrieve("p1", taskId, TaskEntity.class);

			TaskEntity task = tableClient.execute("tasks", getTask).getResultAsType();
			
			// Create an operation to delete the entity.
			TableOperation deleteTask = TableOperation.delete(task);

			// Submit the delete operation to the table service.
			tableClient.execute("tasks", deleteTask);
			
		} catch (InvalidKeyException | URISyntaxException | StorageException ex) {
			// TODO Best effort delete =)
			Logger.LogException(ex);
		}
	}
}
