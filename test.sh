#!/usr/bin/env bash

source up.sh

docker compose --env-file crs.env exec -it victim-1 sh -c "ip r"
docker compose --env-file crs.env exec -it victim-2 sh -c "ip r"
docker compose --env-file crs.env exec -it victim-1 sh -c "ping -c 1 www.cuc.edu.cn"
docker compose --env-file crs.env exec -it victim-1 sh -c "ping -c 1 www.baidu.com"
sleep 5 && docker compose --env-file crs.env logs --tail 30 gw
docker compose --env-file crs.env exec -it victim-2 sh -c "ping -c 1 ccs.cuc.edu.cn"
docker compose --env-file crs.env exec -it victim-2 sh -c "ping -c 1 www.qq.com"
sleep 5 && docker compose --env-file crs.env logs --tail 30 gw

source down.sh

