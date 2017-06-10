set -x 

#export RABBITMQ_LOG_BASE=/var/log/rabbitmq/
nohup /bin/sh -e /usr/lib/rabbitmq/bin/rabbitmq-server > /var/log/rabbitmq/rabbitmq.log 2>&1 &

echo "sleep 60 secs.."
sleep 60


rabbitmqctl add_user tachyon tachyon
rabbitmqctl set_user_tags tachyon administrator
rabbitmqctl set_permissions -p / tachyon ".*" ".*" ".*"




## register consul
echo "Registering to consul"
consul_ip=$(getent hosts consul | awk '{print $1}')
dockerhost_ip=$(getent hosts dockerhost | awk '{print $1}')


cat > rabbitmq.json <<EOL
{
    "id": "rabbitmq",
    "name": "rabbitmq",
    "tags": [
      "rabbitmq"
    ],
    "address": "$dockerhost_ip",
    "port": 5672
  }

EOL

cat > rabbitmqTest.json <<EOL
{
    "id": "rabbitmqTest",
    "name": "rabbitmqTest",
    "tags": [
      "rabbitmqTest"
    ],
    "address": "$dockerhost_ip",
    "port": 5672
  }

EOL
curl -v http://$consul_ip:8500/v1/agent/service/deregister/rabbitmq || true
curl -v http://$consul_ip:8500/v1/agent/service/register -d @rabbitmq.json
curl -v http://$consul_ip:8500/v1/agent/service/deregister/rabbitmqTest || true
curl -v http://$consul_ip:8500/v1/agent/service/register -d @rabbitmqTest.json



echo "showing logs "
tail -n 1000  -f  /var/log/rabbitmq/rabbitmq.log
