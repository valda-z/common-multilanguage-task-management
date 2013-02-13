package com.fs180.sample.azure;

import java.io.Serializable;

import com.microsoft.windowsazure.services.table.client.*;

public class TaskEntity extends TableServiceEntity implements Serializable {
	private static final long serialVersionUID = 1L;
	public TaskEntity() {
        this.partitionKey = "p1";
        this.rowKey = new Double(new java.util.Date().getTime() / 1000.0).toString();
        id = this.rowKey;
    }
	
	public String getId() {
		return id;
	}
	
	public void setId( String id ) {
		this.id = id;
	}

	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getCategory() {
		return category;
	}
	public void setCategory(String category) {
		this.category = category;
	}
	public String getDate() {
		return date;
	}
	public void setDate(String date) {
		this.date = date;
	}
	public Boolean getComplete() {
		return complete;
	}
	public void setComplete(Boolean complete) {
		this.complete = complete;
	}
	public String getImage() {
		return image;
	}
	public void setImage(String image) {
		this.image = image;
	}

	private String name;
	private String category;
	private String date;
	private Boolean complete;
	private String image;
	private String id;

}
