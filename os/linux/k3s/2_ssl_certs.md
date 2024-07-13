# SSL Certs for Homelab - The Self-Managed CA and Self-Signed Route

Ensure `cert-manager` is installed. Some reference yaml files available [here](https://github.com/ChristianLempa/boilerplates/tree/main/kubernetes/certmanager).

We first need a self signed issuer resource instantiated in k8s. This issuer resource effectively represents a CA.

`secretName` refers to a Kubernetes secret named andrews-homelab-root-ca of type `tls`. Provision that first in Rancher UI or CLI:

```bash
kubectl create secret tls homelab-ca-key-pair --cert=rootCA.crt --key=rootCA.key --namespace cert-manager
```

 Some say to use `default` namespace, but I could only get this to work in the `cert-manager` namespace. It's easier to use cert files via Rancher UI.

Next up, provision your `ClusterIssuer`:

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: homelab-ca-clusterissuer
spec:
  ca:
    secretName: andrews-homelab-root-ca
```

[Issuers](https://cert-manager.io/docs/concepts/issuer/) are scoped to a namespace. `ClusterIssuers` are required if you will be issuing Certificate objects out to different namespaces and services.

---

Next, let's get a Certificate resource provisioned:

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: nginx-test-certificate
  namespace: ab-scratch-resources-only
spec:
  secretName: nginx-test-certificate-secret
  issuerRef:
    name: homelab-ca-clusterissuer
    kind: ClusterIssuer
  dnsNames:
   - nginx-hello.homelab
```

---
 These aren't too useful unless you get a web page served over HTTPS and your browser handshakes successfully, so let's use this opportunity to provision an ingress controller as a reverse proxy so we can get a test service stood up, but also use that as a jumping off point for any new services you choose to deploy.

Traefik should already be installed on your k3s cluster, so all we really need to do is add a new Ingress resource.

Verify with `kubectl get pods -n kube-system`;

If needed:

```bash
helm repo add traefik https://helm.traefik.io/traefik
helm repo update
helm install traefik traefik/traefik --namespace traefik --create-namespace
```

If needed, the latest Traefik config template can always be found [here](https://artifacthub.io/packages/helm/traefik/traefik).

And if the service is available:
`kubectl get svc -n kube-system`

---

Let's get a cert resource defined so we can assign it to our service:

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ngxinx-test-cert
  namespace: ab-scratch-resources-only
spec:
  secretName: homelab-cert-tls
  duration: 24h
  renewBefore: 12h
  commonName: homelab
  dnsNames:
    - nginx-hello.homelab
  issuerRef:
    name: homelab-ca-clusterissuer
    kind: ClusterIssuer
```

Copy in [nginx-deployment](nginx-deployment.yaml) and deploy it:
`kubectl apply -f nginx-deployment.yaml`

And finally, the ingress resource which will reference both:

 ```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ngxinx-ingress
  namespace: ab-scratch-resources-only
  annotations:
    cert-manager.io/cluster-issuer: homelab-ca-clusterissuer
    traefik.ingress.kubernetes.io/router.entrypoints: websecure
spec:
  tls:
  - hosts:
    - nginx-hello.homelab
    secretName: ngxinx-test-cert
  rules:
  - host: nginx-hello.homelab
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-service
            port:
              number: 80
 ```
