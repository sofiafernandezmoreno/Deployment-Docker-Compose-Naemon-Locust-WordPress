#!/bin/bash

# Run the Locust hatch
if [ $# -eq 0 ]; then
    #locust -H https://localhost:32768 --clients=100 --hatch-rate=5 --no-web
    # locust -f locustfile.py --host=https://localhost:32768 
    locust --host=http://172.17.0.2
#else
    #locust -H https://localhost:32768/thruk/ --clients=$1 --hatch-rate=$2 --no-web
 fi