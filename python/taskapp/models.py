from django.db import models

# Create your models here.

class Task(models.Model):
    PartitionKey = 'p1'
    RowKey = models.CharField(max_length=60)
    Name = models.CharField(max_length=60)
    Category = models.CharField(max_length=60)
    Date = models.DateTimeField(auto_now_add=True)
    Complete = models.BooleanField(default=False)
    Image = models.CharField(max_length=60)
