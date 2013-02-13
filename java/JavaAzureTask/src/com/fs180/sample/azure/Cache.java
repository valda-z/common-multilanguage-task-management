package com.fs180.sample.azure;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.util.ArrayList;
import java.util.List;

import net.spy.memcached.BinaryConnectionFactory;
import net.spy.memcached.MemcachedClient;

public class Cache {

		public static boolean validCache = false;
		private static String keyName;
		private static MemcachedClient client = null;
		private static ArrayList<InetSocketAddress> worker = null;
		
		public static Object getTasks() {
			if ( worker == null ) {
				worker = new ArrayList<InetSocketAddress>(1);
				worker.add(new InetSocketAddress("localhost_workerrole1", 11211));
			}
			try {
				if ( keyName == null ) 
					keyName = Configuration.getCacheKeyName();
				if ( client == null ) {
					client = new MemcachedClient( new BinaryConnectionFactory(), worker); 
				}				

				return client.get(keyName, new CustomSerializingTranscoder());
				
			} catch ( Exception e ) {
		   		System.out.println("2. Failed to retrieve list.");
		    	Logger.LogException(e);
			}
			return null;
		}
		
		public static void invalidateCache(){ 
			try {
				if ( keyName == null ) 
					keyName = Configuration.getCacheKeyName();
				if ( worker == null ) {
					worker = new ArrayList<InetSocketAddress>(1);
					worker.add(new InetSocketAddress("localhost_workerrole1", 11211));
				}
				if ( client == null ) 
					client = new MemcachedClient( new BinaryConnectionFactory(), worker);
				
				client.delete(keyName);
				
			} catch (IOException e) {
				Logger.LogException(e);
			}
			validCache = false;
		}
		
		public static void validateCache() {
			validCache = true;
		}
		
		public static void updateTasks( List<TaskEntity> list ) {
			try {
				if ( keyName == null )
					keyName = Configuration.getCacheKeyName();
				if ( worker == null ) {
					worker = new ArrayList<InetSocketAddress>(1);
					worker.add(new InetSocketAddress("localhost_workerrole1", 11211));
				}
				if ( client == null ) 
					client = new MemcachedClient( new BinaryConnectionFactory(), worker); 
				
				client.set(keyName, 3600, list, new CustomSerializingTranscoder());
				
			} catch (Exception ex) {
				Logger.LogException(ex);
			}
		}
}
