module.exports = TaskEntity;

function TaskEntity()
{
    this.RowKey = new Date().getTime() / 1000;
    this.Name = '';
    this.Category = '';
    this.Complete = false;
    this.Date = '';
    this.Image = '';
}

TaskEntity.properties = {
    Name:{
        type:"String",
        description:"Task Name"
    },

    Category:{
        type:"String",
        description:"Task Category"
    },

    Complete:{
        type:"Boolean",
        description:"Task Complete Status"
    },

    Date:{
        type:"String",
        description:"Task Planned Completion Date"
    },

    Image:{
        type:"Boolean",
        description:"Image URL Path"
    }
}