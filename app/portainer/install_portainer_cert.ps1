# eliminate self-signed cert warnings for Portainer by installing the portainer cert
Import-Certificate -FilePath "portainer_ca.crt" -CertStoreLocation Cert:\LocalMachine\Root
