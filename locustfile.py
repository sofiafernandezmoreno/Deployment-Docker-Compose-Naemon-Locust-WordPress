from locust import HttpLocust, TaskSet, task

class UserBehavior(TaskSet):
    @task()
    def on_start(self):
      self.login() 
    @task()   
    def login(self):
        self.client.get("/cgi-bin/login.cgi",{"username":"thrukadmin","password":"thrukadmin"})
    
    @task()
    def host(self):
        self.client.get("#cgi-bin/status.cgi?hostgroup=all&amp;style=hostdetail")
    @task()
    def index(self):
        self.client.get("/")
class WebsiteUser(HttpLocust):
    task_set = UserBehavior
    min_wait = 5000
    max_wait = 9000


