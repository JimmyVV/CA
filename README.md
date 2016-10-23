
If you want to test TLS/SSL handshake locally, maybe you want to buy one certificate for your website. But in fact, there is some way to help you quickly achieve this target. That is to create your own certificate authority(CA). And `openssl` is a free and open-source cryptographic library. If you want to know more, please refer to [OpenSSL Certificate Authority][1]. This is a tidy shell script which is a collection of all procedure and do some optimization.
## Installation
```
# first, use wget
$ wget -O index.sh https://raw.githubusercontent.com/JimmyVV/CA/master/index.sh
# second, use curl
$ curl -o index.sh https://raw.githubusercontent.com/JimmyVV/CA/master/index.sh

# please don't change the 'index.sh' name, because it will be used in later code.
```
## Usage
First, you should choose one directory, no matter where it is.

Second, you need to run the the `index.sh` script. Because it is executable, so you could run it directly.
```
$ ./index.sh
# or supply one argument -- domainName
# I provide custom domainName
$ ./index.sh www.villainhr.com
```
And then, you need to input you domainName, password and some other information. When you input some certificate's information, you'd better use default value.
Here is it.

![upload_img_信息录入][2]

In fact, the procedure is tedious. There are so much information you need to input. But, you need to pay more attention to the password which should be the same all the time.
After above procedures, your directory structure may be like this.
```
├── certs
│   └── ca.cert.pem
├── crl
├── index.sh
├── index.txt
├── index.txt.attr
├── index.txt.attr.old
├── index.txt.old
├── intermediate
│   ├── certs
│   ├── crl
│   ├── crlnumber
│   ├── csr
│   ├── index.txt
│   ├── newcerts
│   ├── openssl.cnf
│   ├── private
│   └── serial
├── newcerts
│   ├── 1024.pem
│   └── 1025.pem
├── openssl.cnf
...
```
And now, there are three important keys.
```
intermediate/certs/ca-chain.cert.pem
intermediate/certs/www.villainhr.com.cert.pem
intermediate/private/www.villainhr.com.key.pem

# if you run index.sh directly without any argument, 
# then these keys are
intermediate/certs/ca-chain.cert.pem
intermediate/certs/www.example.com.cert.pem
intermediate/private/www.example.com.key.pem
```
You just finish all the things you need to create custom CA.

## Deployment
In order to make CA valid, you should add `ca-chain.cert.pem` to your own computer by clicking it and choose to trust it.

![CA_证书添加][3]

## Test
You can run any server you like to test `https`. Here, I will use NodeJs. 
```
const https = require('https');
const fs = require('fs');

// if you use some argument to run index.sh, you need to change below parameters.
// eg: ./index.sh www.villainhr.com
// I should change into www.villainhr.com
const options = {
  key: fs.readFileSync('private/www.example.com.key.pem'),
  cert: fs.readFileSync('certs/www.example.com.cert.pem'),
  passphrase: 'yourPassword' // inputting the password you set
};

https.createServer(options, (req, res)=>{
  res.writeHead(200);
  res.end('https is working');
}).listen(8080, function(){
  console.log('success!please open https://www.example.com:8080');
});
```
When you see this cute and green lock, that means you get it!
And my own certificate is like this:

![own_certificate_证书][4]

## Author

 - [JimmyVV][5]

## License
**MIT**


  [1]: https://jamielinux.com/docs/openssl-certificate-authority/index.html
  [2]: http://static.zybuluo.com/jimmythr/qxzij2naiuzsp4mq9yjf1u7m/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202016-10-23%2014.13.56.png
  [3]: http://static.zybuluo.com/jimmythr/brxjhchd3697dt72nn1v3cus/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202016-10-23%2014.38.50.png
  [4]: http://static.zybuluo.com/jimmythr/j6brkcu73b3sufa3mix0itz7/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202016-10-23%2013.27.30.png
  [5]: https://github.com/JimmyVV