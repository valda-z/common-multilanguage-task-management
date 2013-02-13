package com.fs180.sample.azure;

import java.io.FileInputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

public class Configuration {
	private static final Map<String, String> config = getConfiguration();
	
	private static Map<String, String> getConfiguration()
    {
       if (com.microsoft.windowsazure.serviceruntime.RoleEnvironment.isAvailable()) {
    	   return com.microsoft.windowsazure.serviceruntime.RoleEnvironment.getConfigurationSettings();
       }
       
 	   final Properties prop = new Properties();
       
       try {
    	   prop.load(new FileInputStream("config.properties"));
       } catch (Exception ex) {
    	   Logger.LogException(ex);
       }    
       
       //TODO: Change this to read form a different location
       return new HashMap<String, String>()
		{
		       private static final long serialVersionUID = 1L;
		{
				put("Provider", prop.getProperty("Provider"));
				put("ConnectionString", prop.getProperty("ConnectionString"));
				put("MySqlUsername", prop.getProperty("MySqlUsername"));
				put("MySqlPassword", prop.getProperty("MySqlPassword"));
				put("BlobConnectionString", prop.getProperty("BlobConnectionString"));
				put("EntityImageLocation", prop.getProperty("EntityImageLocation"));
				put("CacheEnabled", prop.getProperty("CacheEnabled"));
				put("CacheKeyName", prop.getProperty("CacheKeyName"));
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
	
	public static String getBlobConnectionString()
	{
		return config.get("BlobConnectionString");
	}

	public static boolean getCache() {
		return Boolean.parseBoolean(config.get("CacheEnabled"));
	}

	public static String getCacheKeyName() {
		return config.get("CacheKeyName");
	}
	
	public static String getMySQLUsername() {
		return config.get("MySqlUsername");
	}
	
	public static String getMySQLPassword() {
		return config.get("MySqlPassword");
	}
	
	public static String getEntityImageLocation() {
		return config.get("EntityImageLocation");
	}
}
