= Couchbase Docker Image

This directory shows how to build a custom Couchbase Docker image that:

. Setups memory for Index and Data
. Configures the Couchbase server with Index, Data, and Query service
. Sets up username and password credentials : Administrator/password
. create dvcbucket 
. create primary index for dvcbucket

== Build the Image

```console
docker build -t dvc_couchbase .
```




