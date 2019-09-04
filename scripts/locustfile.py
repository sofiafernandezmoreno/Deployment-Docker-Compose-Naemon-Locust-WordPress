from locust import HttpLocust, TaskSet, task

def login(l):
    l.client.post("/wp-login.php", {"username":"naemon", "password":"naemon"})

def logout(l):
    l.client.post("/wp-login.php?loggedout=true", {"username":"naemon", "password":"naemon"})


class UserBehavior(TaskSet):
    def on_start(self):
        login(self)

    def on_stop(self):
        logout(self)
    @task(2)
    def root(self):
        self.client.get('/')
    @task(1)
    def host(self):
        self.client.get('/?p=1')
 
class WebsiteUser(HttpLocust):
    task_set = UserBehavior
    min_wait = 5000
    max_wait = 9000


