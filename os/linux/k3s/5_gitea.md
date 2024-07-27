# Gitea on k3s

We'll feed in a `values.yaml` for the install process.

```yaml
# values.yaml

gitea:
  config:
    APP_NAME: "Gitea: Git with a cup of tea"
    RUN_MODE: "prod"
    database:
      DB_TYPE: "postgres"
      HOST: "gitea-postgresql.default.svc.cluster.local:5432"
      NAME: "gitea"
      USER: 
        valueFrom:
          secretKeyRef:
            name: gitea-db-secret
            key: postgres-username
      PASSWD: 
        valueFrom:
          secretKeyRef:
            name: gitea-db-secret
            key: postgres-password
      SSL_MODE: "disable"
      PATH: "data/gitea.db"
  ingress:
    enabled: false
    # annotations:
    #   kubernetes.io/ingress.class: "traefik"
    #  cert-manager.io/cluster-issuer: "homelab-ca-clusterissuer" # Update with your own CA issuer if using Cert-Manager
    # hosts:
    #   - host: gitea.homelab
    #     paths:
    #       - path: /
    #         pathType: Prefix
    # tls:
    #   - secretName: gitea-tls
    #     hosts:
    #       - gitea.homelab
  service:
    type: ClusterIP
    http:
      port: 3000
    ssh:
      port: 22

postgresql:
  enabled: true
  postgresqlUsername: 
    valueFrom:
      secretKeyRef:
        name: gitea-db-secret
        key: postgres-username
  postgresqlPassword: 
    valueFrom:
      secretKeyRef:
        name: gitea-db-secret
        key: postgres-password
  postgresqlDatabase: gitea
  persistence:
    enabled: true
    size: 32Gi
  resources:
    requests:
      memory: 256Mi
      cpu: 100m

postgresql-ha:
  enabled: false

```

And accompanying Ingress for Traefik:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: gitea-ingress
  namespace: default
  annotations:
    cert-manager.io/cluster-issuer: homelab-ca-clusterissuer
    traefik.ingress.kubernetes.io/router.entrypoints: websecure
spec:
  tls:
  - hosts:
    - gitea.homelab
    secretName: gitea-cert
  rules:
  - host: gitea.homelab
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: gitea-http
            port:
              number: 3000
```

Helm setup:

```bash
helm repo add gitea-charts https://dl.gitea.io/charts/
helm repo update
helm install gitea gitea-charts/gitea -f gitea-values.yaml --version 10.3.0
```

Verify the install:

```
kubectl get pods
kubectl get svc
kubectl get ingress
```

Todo:
Verify DNS from within the pod:
`kubectl run -i --tty --rm debug --image=busybox --restart=Never -- sh`
`nslookup...`

---

## Backup And Restore

```bash

#!/bin/bash

# Set variables
GITEA_POD=$(kubectl get pods -l app=gitea -o jsonpath="{.items[0].metadata.name}")
BACKUP_DIR="/home/warden/gitea-backups"
BACKUP_FILE="${BACKUP_DIR}/gitea-backup.zip"

# Create backup directory if it doesn't exist
echo "Creating backup directory..."
mkdir -p ${BACKUP_DIR}

# Execute the Gitea dump command inside the pod
echo "Running Gitea dump command inside the pod..."
kubectl exec ${GITEA_POD} -- sh -c 'gitea dump -c /data/gitea/conf/app.ini -f /data/gitea-backup.zip'

# Copy the backup file from the pod to the local machine
echo "Copying backup file from pod to local machine..."
kubectl cp ${GITEA_POD}:/data/gitea-backup.zip ${BACKUP_FILE}

# Clean up the backup file inside the pod
echo "Cleaning up backup file inside the pod..."
kubectl exec ${GITEA_POD} -- rm /data/gitea-backup.zip

echo "Backup completed: ${BACKUP_FILE}"

```

## WARNING! Restore does NOT work! Manual process required

And restore:

```bash
#!/bin/bash

# Set variables
GITEA_POD=$(kubectl get pods -l app=gitea -o jsonpath="{.items[0].metadata.name}")
BACKUP_FILE="/home/warden/gitea-backups/gitea-backup.zip"  # Ensure this path is correct
RESTORE_DIR="/data/restore"  # Using a directory with proper permissions

# Get the database credentials from the secret
DB_USERNAME=$(kubectl get secret gitea-db-secret -o jsonpath="{.data.postgres-username}" | base64 --decode)
DB_PASSWORD=$(kubectl get secret gitea-db-secret -o jsonpath="{.data.postgres-password}" | base64 --decode)
DB_NAME="gitea"  # Replace with your database name

# Create restore directory inside the pod with correct permissions
echo "Creating restore directory inside the pod..."
kubectl exec ${GITEA_POD} -- sh -c "mkdir -p ${RESTORE_DIR} && chmod 777 ${RESTORE_DIR}"

# Copy the backup file to the pod
echo "Copying backup file to the pod..."
kubectl cp ${BACKUP_FILE} ${GITEA_POD}:${RESTORE_DIR}/gitea-backup.zip

# Unzip the backup file inside the pod
echo "Unzipping backup file inside the pod..."
kubectl exec ${GITEA_POD} -- sh -c "unzip ${RESTORE_DIR}/gitea-backup.zip -d ${RESTORE_DIR} && chmod -R 777 ${RESTORE_DIR}"

# Install PostgreSQL client if not available
echo "Checking for PostgreSQL client..."
kubectl exec ${GITEA_POD} -- sh -c "command -v psql || (apk add --no-cache postgresql-client || apt-get update && apt-get install -y postgresql-client)"

# Restore database (PostgreSQL)
echo "Restoring PostgreSQL database..."
kubectl exec -i ${GITEA_POD} -- sh -c "PGPASSWORD=${DB_PASSWORD} psql -U ${DB_USERNAME} -d ${DB_NAME} -f ${RESTORE_DIR}/gitea-db.sql"

# Move restored files to the appropriate locations
echo "Moving restored files to appropriate locations..."
kubectl exec ${GITEA_POD} -- sh -c "mv ${RESTORE_DIR}/data/git/* /data/git/ && mv ${RESTORE_DIR}/data/gitea/conf/* /data/gitea/conf/ && chmod -R 777 /data/git/ /data/gitea/conf/"

# Clean up
echo "Cleaning up..."
kubectl exec ${GITEA_POD} -- rm -r ${RESTORE_DIR}

echo "Restore completed"

```