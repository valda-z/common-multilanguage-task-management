package com.fs180.sample.azure;

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
    	   prop.load(Thread.currentThread().getContextClassLoader().getResourceAsStream("config.properties"));
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
				put("BlobConnectionString", prop.getProperty("BlobConnectionString"));
				put("EntityImageLocation", prop.getProperty("EntityImageLocation"));
				put("CacheEnabled", prop.getProperty("CacheEnabled"));
				put("CacheKeyName", prop.getProperty("CacheKeyName"));
				put("SBEnabled", prop.getProperty("SBEnabled"));
				put("SBName", prop.getProperty("SBName"));
				put("SBIssuer", prop.getProperty("SBIssuer"));
				put("SBKey", prop.getProperty("SBKey"));
				put("SBTopic", prop.getProperty("SBTopic"));
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

	public static boolean getCacheEnabled() {
		return Boolean.parseBoolean(config.get("CacheEnabled"));
	}

	public static String getCacheKeyName() {
		return config.get("CacheKeyName");
	}
	
	public static String getEntityImageLocation() {
		return config.get("EntityImageLocation");
	}
	
	public static String getSBKey() {
		return config.get("SBKey");
	}
	
	public static String getSBIssuer() {
		return config.get("SBIssuer");
	}

	public static String getSBName() {
		return config.get("SBName");
	}
	
	public static boolean getSBEnabled() {
		return Boolean.parseBoolean(config.get("SBEnabled"));
	}
	
	public static String getSBTopic() {
		return config.get("SBTopic");
	}
}
