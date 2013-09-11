Guardian Status App
=====================================

Shows the status of autoscaling groups in an AWS account.

![Status app in action](screenshot.png)

Configuration
-------------

Compile a distribution using ```sbt dist```
scp the ```dist/status-app-1.0.tar.gz``` onto your destination server
Ensure the server has java installed (```apt-get install java```)
unzip on the target server (```/src/status-app-1.0``` for us)
in that directory run ```./start &```

Additional Config
-----------------

We recommend running on a box behind an apache.

First install the requirements.

```
sudo apt-get update
sudo apt-get install apache2 openjdk-7-jre-headless
```

You'll need a file in ~/.gu/statusapp.conf that has contents something like
```
accessKey=<AWS ACCESSKEY>
secretKey=<AWS SECRETKEY>
elasticsearchHost=localhost
proxyHost=proxy
proxyPort=3128
```

You may want to create an apache site in /etc/apache/sites-available/status-app like:
```
<VirtualHost *:80>
  ServerName status.cp.dev-theguardian.com
  ProxyPass / http://127.0.0.1:9000/
</VirtualHost>
```
Then enable the site and the proxy module in apache using
```
a2ensite status-app
a2enmod proxy
a2enmod proxy_http
```

Best of luck
