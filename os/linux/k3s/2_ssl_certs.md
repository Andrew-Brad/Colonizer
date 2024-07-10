# SSL Certs for Homelab - The Self-Managed CA and Self-Signed Route

Ensure `cert-manager` is installed. Some reference yaml files available [here](https://github.com/ChristianLempa/boilerplates/tree/main/kubernetes/certmanager).

We first need a self signed issuer resource instantiated in k8s. This issuer resource effectively represents a CA.

`secretName` refers to a Kubernetes secret named andrews-homelab-root-ca of type `tls`. Provision that first in Rancher UI or CLI:

```bash
kubectl create secret tls homelab-ca-key-pair --cert=rootCA.crt --key=rootCA.key --namespace default
```

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ca-clusterissuer
spec:
  ca:
    secretName: andrews-homelab-root-ca
    namespace: default

```

[Issuers](https://cert-manager.io/docs/concepts/issuer/) are scoped to a namespace. `ClusterIssuers` are required if you will be issuing cvrrts to different namespace.