#!/bin/bash

# Variables
BACKUP_DIR="/home/warden/k3s-backups"
DB_DIR="/mnt/ab-nvme-ssd/k3s-data/server/db"
K3S_SERVICE="k3s"
TIMESTAMP=$(date +"%Y%m%d%H%M%S")
BACKUP_PATH="${BACKUP_DIR}/k3s-backup-${TIMESTAMP}.tar.gz"

# Create backup directory if it doesn't exist
mkdir -p ${BACKUP_DIR}

# Logging
echo "Starting k3s backup process..."
echo "Backup directory: ${BACKUP_DIR}"
echo "Database directory: ${DB_DIR}"

# Stop k3s service
echo "Stopping k3s service..."
sudo systemctl stop ${K3S_SERVICE}

# Verify k3s service stop
if [ $? -eq 0 ]; then
    echo "k3s service stopped successfully."
else
    echo "Error: Failed to stop k3s service."
    exit 1
fi

# Check if the database directory exists
if [ ! -d "${DB_DIR}" ]; then
    echo "Error: Database directory ${DB_DIR} does not exist."
    sudo systemctl start ${K3S_SERVICE}
    exit 1
fi

# Check write permission for backup directory
if [ ! -w "${BACKUP_DIR}" ]; then
    echo "Error: No write permission to backup directory ${BACKUP_DIR}."
    sudo systemctl start ${K3S_SERVICE}
    exit 1
fi

# Create a tarball of the database directory
echo "Creating backup tarball..."
tar -czvf ${BACKUP_PATH} -C ${DB_DIR} .

# Verify the tarball creation
if [ $? -eq 0 ]; then
    echo "Backup successfully created at ${BACKUP_PATH}"
else
    echo "Error: Failed to create the backup tarball."
    sudo systemctl start ${K3S_SERVICE}
    exit 1
fi

# Start k3s service
echo "Starting k3s service..."
sudo systemctl start ${K3S_SERVICE}

# Verify k3s service start
if [ $? -eq 0 ]; then
    echo "k3s service started successfully."
else
    echo "Error: Failed to start k3s service."
    exit 1
fi

echo "k3s backup process completed."
