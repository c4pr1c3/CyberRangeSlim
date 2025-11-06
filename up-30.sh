# scale new victim services
docker compose --env-file crs.env up -d --scale victim-net-1=10 --scale victim-net-2=10 --scale victim-net-3=10

