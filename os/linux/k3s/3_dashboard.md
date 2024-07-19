# Homelab Dashboard

Now for some fun. Let's get a dashboard online. We'll be getting [Homepage](https://gethomepage.dev/latest/) running.

https://gethomepage.dev/latest/installation/k8s/

```bash
helm repo add jameswynn https://jameswynn.github.io/helm-charts
```

Make a `values.yaml` file and adjust this config here as desired:

```yaml
config:
  bookmarks:
    - Developer:
        - Github:
            - abbr: GH
              href: https://github.com/
  services:
    - My First Group:
        - My First Service:
            href: http://localhost/
            description: Homepage is awesome

    - My Second Group:
        - My Second Service:
            href: http://localhost/
            description: Homepage is the best

    - My Third Group:
        - My Third Service:
            href: http://localhost/
            description: Homepage is 😎
  widgets:
    # show the kubernetes widget, with the cluster summary and individual nodes
    - kubernetes:
        cluster:
          show: true
          cpu: true
          memory: true
          showLabel: true
          label: "k3s Homelab Cluster"
        nodes:
          show: false
          cpu: false
          memory: false
          showLabel: false
    - search:
        provider: duckduckgo
        target: _blank
  kubernetes:
    mode: cluster
  settings:

# The service account is necessary to allow discovery of other services
serviceAccount:
  create: true
  name: homepage

# This enables the service account to access the necessary resources
enableRbac: true

ingress:
  main:
    enabled: true
    annotations:
      # Example annotations to add Homepage to your Homepage!
      gethomepage.dev/enabled: "true"
      gethomepage.dev/name: "Homepage"
      gethomepage.dev/description: "Dynamically Detected Homepage"
      gethomepage.dev/group: "Dynamic"
      gethomepage.dev/icon: "homepage.png"
    hosts:
      - host: dashboard.homelab
        paths:
          - path: /
            pathType: Prefix
```

Then, `helm install homepage jameswynn/homepage -f values.yaml`.

At this point, it is accessible over `http`. Let's enforce `https`.

Provision a new ingress resource:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: homepage-ingress
  namespace: default
  annotations:
    cert-manager.io/cluster-issuer: homelab-ca-clusterissuer
    traefik.ingress.kubernetes.io/router.entrypoints: websecure
spec:
  tls:
  - hosts:
    - dashboard.homelab
    secretName: homepage-cert-tls
  rules:
  - host: dashboard.homelab
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: homepage
            port:
              number: 3000
```

And `kubectl apply -f homepage-ingress.yaml`.
Verify:
`kubectl get ingress homepage-ingress -n default`
`kubectl describe ingress homepage-ingress -n default`
