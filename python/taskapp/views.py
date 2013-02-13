# Create your views here.
import time
import uuid
from azure.servicebus import Message, ServiceBusService
from django.shortcuts import *
from azure.storage import *
from taskproject.settings import *

#View to display the task list and handle adding a new task
def index(request): #Define our function, accept a request
    table_service = TableService(account_name=STORAGE_ACCOUNT_NAME, account_key=STORAGE_ACCOUNT_KEY)

    #Handle Task Create
    if request.method == 'POST':
        task = Entity()
        task.PartitionKey = 'p1'
        task.RowKey = str(time.time())
        task.Name = request.POST.get('itemname')
        task.Category = request.POST.get('category')
        task.Date = request.POST.get('date')
        task.Complete = False

        #If there is an attachment save it to BLOB storage and add the name to the Task entity
        if 'upload' in request.FILES:
            #Create a filename using GUID and the uploaded file extension
            fileName = str(uuid.uuid1()) + '.' + os.path.splitext(request.FILES['upload'].name)[1]
            file = request.FILES['upload'].read()

            blob_service = BlobService(account_name=STORAGE_ACCOUNT_NAME, account_key=STORAGE_ACCOUNT_KEY)
            blob_service.put_blob('images', fileName, file, x_ms_blob_type='BlockBlob')
            task.Image = fileName
        else:
            task.Image = ''

        table_service.insert_entity('tasks', task)
        sendMessage('add', task.Name)


    #Get the full list of tasks and render the view
    tasks = table_service.query_entities('tasks', "PartitionKey eq 'p1'")
    return render(request, 'base.html', {'tasks':tasks, 'attachmentBaseUrl': BLOB_ATTACHMENT_PATH})

#Delete a task from the task list
def deleteTask(request, taskId):

    table_service = TableService(account_name=STORAGE_ACCOUNT_NAME, account_key=STORAGE_ACCOUNT_KEY)

    #Get Task before deleting
    task = table_service.get_entity('tasks', 'p1', taskId)

    #If we cannot find the task just return back to the list view
    if task is None:
        return redirect('taskapp.views.index')

    #Delete the Task from table storage
    table_service.delete_entity('tasks', 'p1', taskId)
    sendMessage('delete', task.Name)

    #Delete Attachment if there is one associated with the task
    if hasattr(task, 'Image') and task.Image != '':
        blob_service = BlobService(account_name=STORAGE_ACCOUNT_NAME, account_key=STORAGE_ACCOUNT_KEY)
        blob_service.delete_blob('images', task.Image)

    return redirect('taskapp.views.index')

#Mark a task complete or not
def markComplete(request, taskId, isComplete):
    table_service = TableService(account_name=STORAGE_ACCOUNT_NAME, account_key=STORAGE_ACCOUNT_KEY)
    task = table_service.get_entity('tasks', 'p1', taskId)

    #If we cannot find the task just return back to the list view
    if task is None:
        return redirect('taskapp.views.index')

    task.Complete = (isComplete == 'True' or isComplete == 'true');
    table_service.update_entity('tasks', 'p1', taskId, task)
    return redirect('taskapp.views.index')

def sendMessage(action, message):
    #If Service bus feature is disabled just return
    if not SB_ENABLED:
        return

    msg = Message(message, custom_properties={'sample':'python', 'action':action})
    sb = ServiceBusService(service_namespace=SB_NAMESPACE, account_key=SB_KEY, issuer=SB_ISSUER)
    sb.send_topic_message(SB_TOPIC, msg)

