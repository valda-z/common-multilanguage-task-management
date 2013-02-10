package com.fs180.sample.azure;

public class TaskRepositoryFactory {

	public static ITaskRepository GetRepository() {
		
		String config = Configuration.getProvider();
		
		switch (config) {
        case "MySql" :
        	return new MySqlTaskRepository();
        
        case "AzureTable" :
        	return new AzureTableTaskRepository();
        	
        default :
        	return new MySqlTaskRepository();
        	
		}
	}
}
