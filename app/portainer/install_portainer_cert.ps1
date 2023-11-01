# eliminate self-signed cert warnings for Portainer by installing the portainer cert
Import-Certificate -FilePath "app\portainer\portainer_ca.crt" -CertStoreLocation Cert:\LocalMachine\Root
