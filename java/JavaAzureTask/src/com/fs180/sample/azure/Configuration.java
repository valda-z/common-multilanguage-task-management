package com.fs180.sample.azure;

import java.util.HashMap;
import java.util.Map;

public class Configuration {
	private static final Map<String, String> config = getConfiguration();
	
	private static Map<String, String> getConfiguration()
    {
       if (com.microsoft.windowsazure.serviceruntime.RoleEnvironment.isAvailable())
          return com.microsoft.windowsazure.serviceruntime.RoleEnvironment.getConfigurationSettings();
       
       //TODO: Change this to read form a different location
       return new HashMap<String, String>()
		{
		       private static final long serialVersionUID = 1L;
		{
		       //put("ConnectionString", "CONNECTION STRING STORAGE");
				put("ConnectionString", "jdbc:mysql://localhost/taskapplication?user=USERNAME&password=PASSWORD");
				put("StorageConnectionString","BLOB STORAGE CONNECTION STRING");
				//put("Provider", "AzureTable");
				put("Provider", "MySql");
		}};
    }
	
	public static String getProvider()
	{
		return config.get("Provider");
	}
	
	public static String getConnectionString()
	{
		return config.get("ConnectionString");
	}
	
	public static String getStorageConnectionString()
	{
		return config.get("StorageConnectionString");
	}
}
