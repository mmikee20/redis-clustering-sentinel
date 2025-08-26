# redis-clustering-sentinel
Build a 3-Node Redis Cluster with Sentinel Locally
============================================================

This hands-on learning task aims to deepen understanding of Redis clustering, high availability mechanisms, and container orchestration using Docker Compose. It introduces Redis Sentinel to provide automated failover and monitoring in case a master node fails.

You will also gain practical experience in:

Setting up Redis in cluster and Sentinel mode

Managing stateful containers and volumes

Configuring static IP Docker networks

Executing Redis cluster bootstrapping with CLI

Observing failover behavior using Sentinel

Objectives
Set up a functional 3-node Redis Cluster with Sentinel using Docker Compose. The cluster should be initialized with 3 Redis nodes (1 master + 2 replicas) and 3 Sentinel nodes that monitor the Redis master and handle automatic failover.

Requirements
Use official redis:7 image.

Create 3 Redis nodes: redis-node1, redis-node2, redis-node3.

Create 3 Sentinel nodes: sentinel1, sentinel2, sentinel3.

Redis nodes must:

Use a mounted config file located in nodeX/redis.conf

Be configured for clustering with persistence enabled

Sentinel nodes must:

Monitor the same master

Use a shared name (mymaster)

Use a Docker bridge network with static IPs.

Redis Config (nodeX/redis.conf)


port 6379
cluster-enabled yes
cluster-config-file nodes.conf
cluster-node-timeout 5000
appendonly yes
Sentinel Config (sentinelX/sentinel.conf)


port 26379
sentinel monitor mymaster redis-node1 6379 2
sentinel down-after-milliseconds mymaster 5000
sentinel failover-timeout mymaster 10000
sentinel parallel-syncs mymaster 1
Docker Compose File


version: '3.8'

services:
  redis-node1:
    image: redis:7
    container_name: redis-node1
    command: ["redis-server", "/usr/local/etc/redis/redis.conf"]
    volumes:
      - ./node1/conf/redis.conf:/usr/local/etc/redis/redis.conf
      - ./node1/data:/data
    ports:
      - "7001:6379"
    networks:
      redis-net:
        ipv4_address: 172.25.0.11

  redis-node2:
    image: redis:7
    container_name: redis-node2
    command: ["redis-server", "/usr/local/etc/redis/redis.conf"]
    volumes:
      - ./node2/conf/redis.conf:/usr/local/etc/redis/redis.conf
      - ./node2/data:/data
    ports:
      - "7002:6379"
    networks:
      redis-net:
        ipv4_address: 172.25.0.12

  redis-node3:
    image: redis:7
    container_name: redis-node3
    command: ["redis-server", "/usr/local/etc/redis/redis.conf"]
    volumes:
      - ./node3/conf/redis.conf:/usr/local/etc/redis/redis.conf
      - ./node3/data:/data
    ports:
      - "7003:6379"
    networks:
      redis-net:
        ipv4_address: 172.25.0.13

  sentinel1:
    image: redis:7
    container_name: sentinel1
    command: ["redis-server", "/usr/local/etc/redis/sentinel.conf", "--sentinel"]
    volumes:
      - ./sentinel1/sentinel.conf:/usr/local/etc/redis/sentinel.conf
    ports:
      - "26381:26379"
    networks:
      redis-net:
        ipv4_address: 172.25.0.21

  sentinel2:
    image: redis:7
    container_name: sentinel2
    command: ["redis-server", "/usr/local/etc/redis/sentinel.conf", "--sentinel"]
    volumes:
      - ./sentinel2/sentinel.conf:/usr/local/etc/redis/sentinel.conf
    ports:
      - "26382:26379"
    networks:
      redis-net:
        ipv4_address: 172.25.0.22

  sentinel3:
    image: redis:7
    container_name: sentinel3
    command: ["redis-server", "/usr/local/etc/redis/sentinel.conf", "--sentinel"]
    volumes:
      - ./sentinel3/sentinel.conf:/usr/local/etc/redis/sentinel.conf
    ports:
      - "26383:26379"
    networks:
      redis-net:
        ipv4_address: 172.25.0.23

networks:
  redis-net:
    driver: bridge
    ipam:
      config:
        - subnet: 172.25.0.0/24
Cluster Creation (Manual Step)
After starting the containers:



docker exec -it redis-node1 redis-cli --cluster create \
  172.25.0.11:6379 172.25.0.12:6379 172.25.0.13:6379 \
  --cluster-replicas 1
Learning Resources
Redis Cluster Overview: Scale with Redis Cluster 

Redis Sentinel: High availability with Redis Sentinel 

Docker Compose Reference: Compose file reference 

Docker Networking Guide: Networking 

Redis Docker Hub: redis - Official Image | Docker Hub
