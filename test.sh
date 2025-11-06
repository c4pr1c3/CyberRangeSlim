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

source up-30.sh

# pick one container from each scaled service and test routes
docker compose --env-file crs.env exec -it victim-net-1 sh -c "ip r"
docker compose --env-file crs.env exec -it victim-net-2 sh -c "ip r"
docker compose --env-file crs.env exec -it victim-net-3 sh -c "ip r"

# cross-subnet connectivity tests: ping between nets
docker compose --env-file crs.env exec -it victim-net-1 sh -c "ping -c 1 $(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker compose --env-file crs.env ps -q victim-net-2 | head -n1)) || true"
docker compose --env-file crs.env exec -it victim-net-2 sh -c "ping -c 1 $(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker compose --env-file crs.env ps -q victim-net-3 | head -n1)) || true"
docker compose --env-file crs.env exec -it victim-net-3 sh -c "ping -c 1 $(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker compose --env-file crs.env ps -q victim-net-1 | head -n1)) || true"

# access outer network: ping/curl attacker via outer IP (through gw NAT)
ATTACKER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker compose --env-file crs.env ps -q attacker) 2>/dev/null)
docker compose --env-file crs.env exec -it victim-net-1 sh -c "ping -c 1 $ATTACKER_IP || true"
docker compose --env-file crs.env exec -it victim-net-2 sh -c "curl -s -o /dev/null -w '%{http_code}\\n' http://$ATTACKER_IP || true"
docker compose --env-file crs.env exec -it victim-net-3 sh -c "traceroute -m 5 $ATTACKER_IP || true"

sleep 5 && docker compose --env-file crs.env logs --tail 100 gw

source down.sh

