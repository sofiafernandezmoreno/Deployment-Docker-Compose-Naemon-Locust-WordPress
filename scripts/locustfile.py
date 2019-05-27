from locust import HttpLocust, TaskSet, task

class UserBehavior(TaskSet):
    @task(2)
    def root(self):
        self.client.get('/')
    @task(1)
    def host(self):
        self.client.get('/thruk/#cgi-bin/status.cgi?hostgroup=all&style=hostdetail')
class WebsiteUser(HttpLocust):
    task_set = UserBehavior
    min_wait = 5000
    max_wait = 9000


