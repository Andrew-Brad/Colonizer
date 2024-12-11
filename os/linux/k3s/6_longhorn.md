# Longhorn

...was a one-click install through Rancher UI lol

But it does automatically set itself as default. If this is not desired, it can be changed back:
`kubectl patch storageclass longhorn -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'