# SSL cert authority and public private key gen

## private key of the CA cert. this is the trade secret, if anyone has this they can sign new certs with your CA

```sh
openssl genrsa -aes256 -out ca-private-key.pem 4096
```

phrase: foobar

## then make our corresponding private CA, works for local networks, lacks any higher CA in the chain

## x509 pops out

## attributes are only important insofar as you care about them in the browser

```sh
openssl req -new -x509 -sha256 -days 99999 -key ca-private-key.pem -out local-cert-authority.pem
```

## verify some basic info about the cert

## note that there are x509 attributes that show true if this is a ca

```sh
openssl x509 -in local-cert-authority.pem -text
openssl x509 -in local-cert-authority.pem -purpose -noout -text
```

## now we generate the private key for a given server/dns name/ip

## a passphrase is optional/skipped because you'd be uploading them over trusted connection anyway, and they should live in a trusted cert store

## possible that it causes other complications with server admin etc

## it's more convenient to just use a wildcard cert for all local servers, assuming subdomains/subnetting

## for the purposes of http/browsers, it needs to be for the correct target address in the browser

## if this changes (dns name, ip space) you WILL need to regenerate this

openssl genrsa -out server-private-key.pem 4096

## this next one is for a cert signing request

## this isn't your actual public ssl cert

```sh
openssl req -new -sha256 -subj "/CN=local network" -key server-private-key.pem -out csr-cert.csr
```

## now is your publicly issued cert

## alt names are critical - can use dns names or IPs

## IP ranges not supported, which sucks for 10.x spaces

## subdomains are designed to solve for this, which requires internal dns

## the extfile is a config file to hold these separately (optional)

## there is no defined upper bound in the RFC, so you can shotgun your static IP spaces in here ahead of time

## https://stackoverflow.com/questions/31206200/maximum-number-of-san-subject-alternative-names-allowed

```sh
echo "subjectAltName=DNS:*.local,IP:10.10.0.1" >> extfile.cnf
openssl x509 -req -sha256 -days 99999 -in csr-cert.csr -CA local-cert-authority.pem -CAkey ca-private-key.pem -out ab-local-network-public-cert.pem -extfile extfile.cnf -CAcreateserial
```

## 6 files total, plus the extconfig is 7

## the csr you actually don't need anymore (this would make 5)

## then enumerate your servers/clients and install the CA as needed

## really the final step is a convenience though - combine both public cert and CA cert into one file

## "full chain"

```sh
cat ab-local-network-public-cert.pem > ab-local-network-cert-chain.pem
cat local-cert-authority.pem >> ./ab-local-network-cert-chain.pem
```

## then install this cert chain (2-in-1) on all your devices

## it's a public artifact
