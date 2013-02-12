package com.fs180.sample.azure;

import java.sql.SQLException;

public class Logger {
	public static void LogException(Exception ex)
	{
		ex.printStackTrace();
	}

	public static void LogSQLException(SQLException ex)
	{
		System.out.println( "SQLException: " + ex.getMessage() );
		System.out.println( "SQLState    : " + ex.getSQLState() );
		System.out.println( "VenderError : " + ex.getErrorCode() );
	}
}
