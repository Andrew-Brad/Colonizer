#Stop running containers
docker stop teamcity-server teamcity-agent
#Execute the docker backup for the necessary volumes and dump to a directory monitored by your backup software
#https://docs.docker.com/storage/volumes/#backup-restore-or-migrate-data-volumes
docker run --rm --volumes-from teamcity-server -v $(pwd):/backup ubuntu tar cvf /backup/backup.tar /data/teamcity_server/datadir
#Start the containers back up
docker start teamcity-server teamcity-agent