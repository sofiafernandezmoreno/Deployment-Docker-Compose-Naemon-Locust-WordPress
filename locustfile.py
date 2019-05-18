#!/usr/bin/python


from locust import HttpLocust, TaskSet, task

class UserBehavior(TaskSet):
    def on_start(self):
      self.login()    
    def login(self):
        self.client.post("/cgi-bin/login.cgi",{"username":"thrukadmin","password":"thrukadmin"})
    
    @task(4)
    def host(self):
        self.client.get("#cgi-bin/status.cgi?hostgroup=all&amp;style=hostdetail")
    @task(2)
    def index(self):
        self.client.get("/")
class WebsiteUser(HttpLocust):
    task_set = UserBehavior
    min_wait = 5000
    max_wait = 9000
