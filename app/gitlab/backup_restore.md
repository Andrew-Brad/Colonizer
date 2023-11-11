# Gitlab Backup & Restore

<https://docs.gitlab.com/ee/administration/backup_restore/>

## Note!!!

You can only restore a backup to exactly the same version and type (CE/EE) of GitLab on which it was created.

## Backup

<https://docs.gitlab.com/ee/administration/backup_restore/>

### Object Strorage Note

The backup command doesn’t back up blobs that aren’t stored on the file system. If you’re using object storage, be sure to enable backups with your object storage provider.


