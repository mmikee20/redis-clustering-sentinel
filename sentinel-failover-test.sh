#!/usr/bin/env bash
set -euo pipefail

echo "Current master per Sentinel:"
docker exec -it sentinel1 redis-cli -p 26379 SENTINEL get-master-addr-by-name mymaster

echo -e "\nStopping current master (redis-node1) to trigger failover..."
docker compose down redis-node1
sleep 3

echo -e "\nNew master per Sentinel:"
docker exec -it sentinel1 redis-cli -p 26379 SENTINEL get-master-addr-by-name mymaster

echo -e "\nBringing redis-node1 back; it should rejoin as a replica..."
docker compose up -d redis-node1
sleep 3
docker exec -it redis-node1 redis-cli INFO replication | egrep 'role|master_host|master_link_status'

echo -e "\nCluster state:"
for n in 1 2 3; do
  echo "redis-node$n:"
  docker exec -it redis-node$n redis-cli INFO replication | egrep 'role|master_host|master_link_status|connected_slaves'
done
