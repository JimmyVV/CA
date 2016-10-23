#!/bin/bash

echo "First you need to configure your domain name ";

if [ -z "$1" ]; then
      echo  -e "Your default Domain Name is www.example.com \nplease keep it";
      domainName="www.example.com";
else
      domainName=$1;
      echo -e "Now, your DomainName is $1 \nplease keep it";
fi
# wait for user to keep DomainName
sleep 1.5;

echo -e "\n\nbegin to create root pair";

ls | grep -v index.sh | xargs rm -rf;

################### create CA ###################

mkdir certs crl newcerts private;
chmod 700 private;
touch index.txt;
echo 1024 > serial;
wget -O openssl.cnf \
 https://gist.githubusercontent.com/JimmyVV/3e6922207beebea3536b086af7e6d766/raw/bff94b8aa52495bd6834dbcaf504dcb73cf26469/openssl.cnf

openssl genrsa -aes256 -out private/ca.key.pem 4096;
chmod 400 private/ca.key.pem;
openssl req -config openssl.cnf \
      -key private/ca.key.pem \
      -new -x509 -days 7300 -sha256 -extensions v3_ca \
      -out certs/ca.cert.pem
chmod 444 certs/ca.cert.pem;
# verify above certificate, and this procedure coule be omited
# openssl x509 -noout -text -in certs/ca.cert.pem;


################### create intermediate certificate ###################
mkdir intermediate;
cp openssl.cnf intermediate/openssl.cnf
cd intermediate;
mkdir certs crl csr newcerts private;
chmod 700 private;
touch index.txt;
echo 1024 > serial;
echo 1024 > crlnumber;
# back to ca's directory
cd ../;
# create intermediate private key
openssl genrsa -aes256 \
      -out intermediate/private/intermediate.key.pem 4096;
chmod 400 intermediate/private/intermediate.key.pem;

# use CSR negotiation
openssl req -config intermediate/openssl.cnf -new -sha256 \
      -key intermediate/private/intermediate.key.pem \
      -out intermediate/csr/intermediate.csr.pem;

# create intermediate certificate (or public key)
openssl ca -config openssl.cnf -extensions v3_intermediate_ca \
      -days 1825 -notext -md sha256 \
      -in intermediate/csr/intermediate.csr.pem \
      -out intermediate/certs/intermediate.cert.pem;
chmod 444 intermediate/certs/intermediate.cert.pem;

## verify the intermediate certificate[ could be omit ]
# openssl x509 -noout -text  -in intermediate/certs/intermediate.cert.pem;
## then the next message should be OK[ could be omit ]
# openssl verify -CAfile certs/ca.cert.pem intermediate/certs/intermediate.cert.pem;

# cp ca & intermediate certificates into ca-chain file
cat intermediate/certs/intermediate.cert.pem \
      certs/ca.cert.pem > intermediate/certs/ca-chain.cert.pem;
chmod 444 intermediate/certs/ca-chain.cert.pem;

################### create client and server certificate ###################
# in ca directory

# replace openssl.cnf's [common Name]
sed -i '' -e 's/FE/'"$domainName"'/g' intermediate/openssl.cnf
# create client private key
openssl genrsa -aes256 \
      -out intermediate/private/$domainName.key.pem 2048;
chmod 400 intermediate/private/$domainName.key.pem;
# create CSR
openssl req -config intermediate/openssl.cnf \
      -key intermediate/private/$domainName.key.pem \
      -new -sha256 -out intermediate/csr/$domainName.csr.pem;
# create client certificate
openssl ca -config intermediate/openssl.cnf \
      -extensions server_cert -days 375 -notext -md sha256 \
      -in intermediate/csr/$domainName.csr.pem \
      -out intermediate/certs/$domainName.cert.pem;
chmod 444 intermediate/certs/$domainName.cert.pem;
# verify above keys
# openssl x509 -noout -text -in intermediate/certs/$domainName.cert.pem;
openssl verify -CAfile intermediate/certs/ca-chain.cert.pem \
      intermediate/certs/$domainName.cert.pem;
