package com.fs180.sample.azure;

import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class MySqlTaskRepository implements ITaskRepository {

	 @Override
     public List<TaskEntity> GetList() {

		 ArrayList<TaskEntity> tasks = new ArrayList<TaskEntity>();
			try {
				String configString = Configuration.getConnectionString() + "?user=" + 
							Configuration.getMySQLUsername() + "&password=" + Configuration.getMySQLPassword();
				Class.forName("com.mysql.jdbc.Driver");
				java.sql.Connection conn = DriverManager.getConnection( configString );
				Statement st = conn.createStatement();
				
				ResultSet result = st.executeQuery("SELECT `Id`, `Name`, `Category`, `Date`, `Complete`, `Image` FROM Task");
				DateFormat df = new SimpleDateFormat("MM/dd/yyyy", Locale.US);
				
				while (result.next()) {
					TaskEntity task = new TaskEntity();
					task.setRowKey(result.getString("Id"));
					task.setId(result.getString("Id"));
					task.setName(result.getString("Name"));
					task.setCategory(result.getString("Category"));
					task.setDate(df.format(result.getDate("Date")));
					task.setComplete(result.getBoolean("Complete"));
					task.setImage(result.getString("Image"));
					tasks.add( task );
				}
			
			} catch ( SQLException ex ) {
				Logger.LogSQLException(ex);
			} catch ( Exception ex ) {
				Logger.LogException(ex);
			}			
			
			return tasks;
	 }

     @Override
     public void Add(TaskEntity task) {
    	 task.setRowKey( task.getId() );

 		try {
			String configString = Configuration.getConnectionString() + "?user=" + 
					Configuration.getMySQLUsername() + "&password=" + Configuration.getMySQLPassword();
			Class.forName("com.mysql.jdbc.Driver");
			java.sql.Connection conn = DriverManager.getConnection( configString );
			PreparedStatement ps = conn.prepareStatement(
					"INSERT INTO Task (`Id`, `Name`, `Category`, `Date`, `Complete`, `Image`)" +
					" VALUES (?, ?, ?, STR_TO_DATE(?, '%m/%d/%Y'), ?, ?)");

			ps.setString(1, task.getId());
			ps.setString(2, task.getName());
			ps.setString(3, task.getCategory());
			ps.setString(4, task.getDate());
			ps.setBoolean(5, task.getComplete());
			ps.setString(6, task.getImage());
			
			ps.executeUpdate();
			
		} catch (SQLException ex) {
			Logger.LogSQLException(ex);
		} catch ( Exception ex ) {
			Logger.LogException(ex);
		}
     }

     @Override
     public void SetComplete(String taskId, boolean status) {
  		try {
			String configString = Configuration.getConnectionString() + "?user=" + 
					Configuration.getMySQLUsername() + "&password=" + Configuration.getMySQLPassword();
			Class.forName("com.mysql.jdbc.Driver");
			java.sql.Connection conn = DriverManager.getConnection( configString );
 			Statement st = conn.createStatement();
 			try {
 				String sql = "UPDATE Task SET Complete=" + status + " WHERE Id=" + taskId + ";";
 				st.executeUpdate(sql);
 			} catch (SQLException ex) {
 				Logger.LogSQLException(ex);
 			}
 			
 		} catch ( Exception ex ) {
 			Logger.LogException(ex);
 		}	
      }
     

     @Override
     public void Delete(String taskId) {    	 
 		try {
			String configString = Configuration.getConnectionString() + "?user=" + 
					Configuration.getMySQLUsername() + "&password=" + Configuration.getMySQLPassword();
			Class.forName("com.mysql.jdbc.Driver");
			java.sql.Connection conn = DriverManager.getConnection( configString );
			Statement st = conn.createStatement();
			try {
				String sql = "DELETE FROM Task WHERE Id=" + taskId + ";";
				st.executeUpdate(sql);
			} catch (SQLException ex) {
				Logger.LogSQLException(ex);
			}
			
		} catch ( Exception ex ) {
			Logger.LogException(ex);
		}	
     }
}
