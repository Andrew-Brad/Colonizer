# Gitlab Backup & Restore

<https://docs.gitlab.com/ee/administration/backup_restore/>

## *IMPORTANT**

You can only restore a backup to exactly the same version and type (CE/EE) of GitLab on which it was created.

## Backup

<https://docs.gitlab.com/ee/administration/backup_restore/>

Simply bump my replicas to one, the predefined alpine container does the rest. Files will sync to homelab.

### Object Storage Note

The backup command doesn’t back up blobs that aren’t stored on the file system. If you’re using object storage, be sure to enable backups with your object storage provider.

## Restore

<https://docs.gitlab.com/ee/administration/backup_restore/restore_gitlab.html#restore-for-docker-image-installations>

Steps in the doc:

The restore task can be run from the host:

Stop the processes that are connected to the database:

```bash
sudo docker exec -it 9be6c99e6a4a gitlab-ctl stop puma
sudo docker exec -it 9be6c99e6a4a gitlab-ctl stop sidekiq
```

Verify that the processes are both down before continuing

```bash
sudo docker exec -it 9be6c99e6a4a gitlab-ctl status
```

Run the restore.
NOTE: "_gitlab_backup.tar" is omitted from the name!

```bash
# Ex: 1700330203_2023_11_18_16.3.6_gitlab_backup.tar
sudo docker exec -it 9be6c99e6a4a gitlab-backup restore BACKUP=1700330203_2023_11_18_16.3.6
```

Restart the GitLab container and check Gitlab

```bash
sudo docker restart 9be6c99e6a4a
sudo docker exec -it 9be6c99e6a4a gitlab-rake gitlab:check SANITIZE=true
```
