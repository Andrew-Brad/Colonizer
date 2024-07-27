# Backup & Restore

## [k3s docs on backup and restore](https://docs.k3s.io/datastore/backup-restore)

Two scripts are in this repo to assist. Inspect the backup/restore directories inside each of them to ensure they point to the correct k3s directory.

If you passed in a custom `--data-dir` then update both accordingly:

See [backup_k3s.sh](backup_k3s.sh) for backup.
See [restore_k3s.sh](restore_k3s.sh) for restore.

## Important! Also backup your token

Fromn the k3s docs:

```
If you do not use the same token value when restoring, the snapshot will be unusable, as the token is used to encrypt confidential data within the datastore itself.
```

You may need `sudo` or `sudo -i` for these.

To get it:
`tail /mnt/ab-nvme-ssd/k3s-data/server/token`

Given the token `12345abcdef`:

`echo "12345abcdef" > /mnt/ab-nvme-ssd/k3s-data/server/token`
