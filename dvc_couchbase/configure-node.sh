set -x
set -m

/entrypoint.sh couchbase-server &

echo "Sleep 30 secs"
sleep 30

# Setup index and memory quota
curl -v  http://127.0.0.1:8091/pools/default -d memoryQuota=500 -d indexMemoryQuota=500


# Setup services
curl -v http://127.0.0.1:8091/node/controller/setupServices -d services=kv%2Cn1ql%2Cindex

# Setup credentials
curl -v http://127.0.0.1:8091/settings/web -d port=8091 -d username=Administrator -d password=password

# Setup Memory Optimized Indexes
curl -i -u Administrator:password -X POST http://127.0.0.1:8091/settings/indexes -d 'storageMode=memory_optimized'

# Load travel-sample bucket
#curl -v -u Administrator:password -X POST http://127.0.0.1:8091/sampleBuckets/install -d '["travel-sample"]'

echo "Type: $TYPE"


## update hostname 
#curl -v  -u Administrator:password http://127.0.0.1:8091/node/controller/rename -d hostname=127.0.0.1



# create dvcbucket
curl -u Administrator:password -d name=dvcbucket -d ramQuotaMB=100  -d replicaNumber=1 -d authType=sasl -d saslPassword='' -d flushEnabled=1 -bucketType=couchbase   http://localhost:8091/pools/default/buckets


curl -u Administrator:password -d name=dvcbucketTest -d ramQuotaMB=100  -d replicaNumber=1 -d authType=sasl -d saslPassword='' -d flushEnabled=1 -bucketType=couchbase   http://localhost:8091/pools/default/buckets

# create cmbucket
curl -u Administrator:password -d name=cmbucket -d ramQuotaMB=100  -d replicaNumber=1 -d authType=sasl -d saslPassword='' -d flushEnabled=1 -bucketType=couchbase   http://localhost:8091/pools/default/buckets


curl -u Administrator:password -d name=cmbucketTest -d ramQuotaMB=100  -d replicaNumber=1 -d authType=sasl -d saslPassword='' -d flushEnabled=1 -bucketType=couchbase   http://localhost:8091/pools/default/buckets



#create primary index ( this failed query service)
echo "Sleep 60 secs.."
sleep 60
curl -v http://localhost:8093/query/service -d 'statement=create primary index on dvcbucket USING GSI&creds=[{"user":"admin:Administrator", "pass":"password"}]'

curl -v http://localhost:8093/query/service -d 'statement=create primary index on dvcbucketTest USING GSI&creds=[{"user":"admin:Administrator", "pass":"password"}]'

curl -v http://localhost:8093/query/service -d 'statement=create primary index on cmbucket USING GSI&creds=[{"user":"admin:Administrator", "pass":"password"}]'

curl -v http://localhost:8093/query/service -d 'statement=create primary index on cmbucketTest USING GSI&creds=[{"user":"admin:Administrator", "pass":"password"}]'




## register consul
consul_ip=$(getent hosts consul | awk '{print $1}')
dockerhost_ip=$(getent hosts dockerhost | awk '{print $1}')


cat > couchbase.json <<EOL
{
    "id": "couchbase",
    "name": "couchbase",
    "tags": [
      "couchbase"
    ],
    "address": "$dockerhost_ip",
    "port": 11210
  }

EOL

cat > couchbaseTest.json <<EOL
{
    "id": "couchbaseTest",
    "name": "couchbaseTest",
    "tags": [
      "couchbaseTest"
    ],
    "address": "$dockerhost_ip",
    "port": 11210
  }

EOL
curl -v http://$consul_ip:8500/v1/agent/service/deregister/couchbase || true
curl -v http://$consul_ip:8500/v1/agent/service/register -d @couchbase.json
curl -v http://$consul_ip:8500/v1/agent/service/deregister/couchbaseTest || true
curl -v http://$consul_ip:8500/v1/agent/service/register -d @couchbaseTest.json




if [ "$TYPE" = "WORKER" ]; then
  sleep 15

  #IP=`hostname -s`
  IP=`hostname -I | cut -d ' ' -f1`

  echo "Auto Rebalance: $AUTO_REBALANCE"
  if [ "$AUTO_REBALANCE" = "true" ]; then
    couchbase-cli rebalance --cluster=$COUCHBASE_MASTER:8091 --user=Administrator --password=password --server-add=$IP --server-add-username=Administrator --server-add-password=password
  else
    couchbase-cli server-add --cluster=$COUCHBASE_MASTER:8091 --user=Administrator --password=password --server-add=$IP --server-add-username=Administrator --server-add-password=password
  fi;
fi;

fg 1

