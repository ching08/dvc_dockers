set -x 
couchbase_ip=$(getent hosts couchbase | awk '{print $1}')
rabbitmq_ip=$(getent hosts rabbitmq | awk '{print $1}')


cat > /consul/config/rabbitmq.json <<EOL
{
  "service": {
    "name": "rabbitmq",
    "tags": [
      "rabbitmq"
    ],
    "address": "$rabbitmq_ip",
    "port": 5672
  }
}
EOL


cat > /consul/config/rabbitmqTest.json <<EOL
{
  "service": {
    "name": "rabbitmqTest",
    "tags": [
      "rabbitmq"
    ],
    "address": "$rabbitmq_ip",
    "port": 5672
  }
}
EOL



cat > /consul/config/couchbase.json <<EOL
{
  "service": {
    "name": "couchbase",
    "tags": [
      "couchbase"
    ],
    "address": "$couchbase_ip",
    "port": 11210
  }
}
EOL


cat > /consul/config/couchbaseTest.json <<EOL
{
  "service": {
    "name": "couchbaseTest",
    "tags": [
      "couchbase"
    ],
    "address": "$couchbase_ip",
    "port": 11210
  }
}
EOL



cat /consul/config/*

consul agent -data-dir=/consul/data -config-dir=/consul/config -dev -client 0.0.0.0




