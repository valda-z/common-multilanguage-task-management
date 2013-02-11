
from threading import Event
from threading import Thread
from azure.servicebus import *

class TaskQueueProcessor(Thread):

    def __init__(self):
        super(TaskQueueProcessor, self).__init__()
        self.stopRequest = Event()
        Thread.__init__(self)
        self.sb = ServiceBusService(service_namespace='<NAMESPACE>', account_key='<KEY>', issuer='owner')
        self.sb.create_topic('tasks')

    def run(self):
        while not self.stopRequest.isSet():
            msg = self.sb.receive_subscription_message('tasks', 'alltasks', peek_lock=False, timeout=10)
            #timeout is the time the method will block before timing out, then we simply check if we should stop or go back to waiting on message
            #No-Op/Timeout will return with msg but body will be None
            if not msg.body is None:
                print "Brokered Message Received: Body= " + msg.body
                if "action" in msg.custom_properties:
                    print "\t Property Action=" + msg.custom_properties['action']
                if "sample" in msg.custom_properties:
                    print "\t Property Client Language=" + msg.custom_properties['sample']

if __name__=="__main__":

    t = TaskQueueProcessor()
    t.start()

    inp = raw_input("Hit Enter When Ready To Exit: \n")
    t.stopRequest.set()
    print("Waiting For Thread...")
    t.join()

    print("Done!")
    exit()
