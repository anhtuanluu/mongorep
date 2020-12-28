#!/bin/bash

set -e
(
if lsof -Pi :27017 -sTCP:LISTEN -t >/dev/null ; then
    echo "Please terminate the local mongod on 27017"
    exit 1
fi
)

echo "Starting docker ."
docker-compose up -d --build

echo -e "\nConfiguring the MongoDB ReplicaSet.\n"
docker-compose exec mongo_one /usr/bin/mongo --eval '''
config = {
  "_id" : "my-mongo-set",
  "members" : [
    {
      "_id" : 0,
      "host" : "mongo1:27017"
    },
    {
      "_id" : 1,
      "host" : "mongo2:27017"
    },
    {
      "_id" : 2,
      "host" : "mongo3:27017"
    }
  ]
}
rs.initiate(config);
rs.conf();'''

docker-compose exec mongo_two /usr/bin/mongo --eval '''
rs.secondaryOk()
'''
