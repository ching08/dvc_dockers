import pytest,os,json,requests
import consul
#import ipdb
from retrying import retry
from time import time


consul_ip=os.getenv('CONSUL')

class Test_consul:
    def test_consul_registered(self):
        global start_time ,consul_ip

        start_time=time()
        service_data=consul_get_service('consul')

        ## if ever comes here. consul is working


    def test_consul_services_exists(self):
        url='http://%s:8500/v1/agent/services' % (consul_ip)
        print url
        ## check API
        r=requests.get(url,timeout=10)
        print(r.json())
        assert r.status_code == 200 , "expecting %s get 200. but got %s" % (url, r.status_code)



class Test_rabbmitmq:

    def test_rabbitmq_registered(self):
        global start_time,ip,port
        start_time=time()
        ## get ip/port from consul
        ip,port=consul_get_service('rabbitmq')



    def test_rabbitmq_vhosts_exists(self):
        global ip,port
        url="http://%s:15672/api/vhosts" % (ip)
        print url
        ## check API
        r=requests.get(url,auth=requests.auth.HTTPBasicAuth('guest', 'guest'),timeout=10)
        print(r.json())
        assert r.status_code == 200 , "expecting %s get 200. but got %s" % (url, r.status_code)

    
class Test_couchbase:
    def test_couchbase_registered(self):
        global start_time, ip , port
        start_time=time()
        ## get ip/port from consul
        ip,port=consul_get_service('couchbase')

    def test_couchbase_bucket_exists(self):
        global start_time, ip , port

        url='http://%s:8091/pools/default/buckets/dvcbucket' % (ip)
        print url
        ## check API
        r=requests.get(url,timeout=10)
        print(r.json())
        assert r.status_code == 200 , "expecting %s get 200. but got %s" % (url, r.status_code)


################

@retry(stop_max_delay=300000,wait_fixed=5000,wrap_exception=True)
def consul_get_service(serviceId):
    global start_time ,consul_ip
    end_time=time()
    print("-( %.2f secs ) Re-Trying to connect to consul to get serviceId %s" % (end_time-start_time, serviceId))
    cl=consul.Consul(host=consul_ip,port=8500)
    try:
        x,data=cl.catalog.service(serviceId)
        sdata=data[0]
        print(json.dumps(sdata,indent=2))
        ip=sdata['ServiceAddress']
        port=sdata['ServicePort']
        print("-OK : serviceId %s : %s %s " % (serviceId,ip,port))
    except Exception as e:
        print("consul_get_service failed %s" % str(e))
        raise

    return(ip,port)
