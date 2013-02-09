package com.fs180.sample.azure;

import java.net.URISyntaxException;
import java.security.InvalidKeyException;

import com.microsoft.windowsazure.services.core.storage.StorageException;

public interface ITaskRepository {

	public Iterable<TaskEntity> GetList() throws InvalidKeyException, URISyntaxException;
	
	public void Add(TaskEntity task) throws InvalidKeyException, URISyntaxException, StorageException;
	
	public void SetComplete(String taskId, Boolean status);
	
	public void Delete(String taskId);
}
