# MemSQL Cluster using Docker

The project creates a Docker based cluster of MemSQL, it will allow you to create a HA cluster with as many nodes as you want.

There are a few configuration steps needed in order to create the cluster the first time.

- `memsqlbase`: Contains the configuration files to create the MemSQL base image using ubuntu flavor linux.
- `memsqlha`: HA Cluster with 1 Aggregator and 2 Leaves.
- `memsqlha4`: HA Cluster with 1 Aggregator, 1 Child Aggregator, 4 Leaves.
- `memsqlha67`: HA Cluster with 1 Aggregator and 2 Leaves forcing version 6.7

