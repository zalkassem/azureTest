sudo apt-get -y update
sudo apt-get -y install nginx
echo 'Hello Zeiad from script World' | sudo tee /var/www/html/index.html
sudo service nginx start
sudo apt-get -y install git-all
sudo apt-get install -y ca-certificates curl gnupg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt-get update
sudo apt-get install nodejs -y
curl -fsSL https://pgp.mongodb.com/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg  --dearmor
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org
cd /etc
sudo sed -i 's/#security:/security:\n  authorization: enabled/g' mongod.conf
sudo sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/g' mongod.conf
sudo systemctl enable mongod
sudo systemctl start mongod
cd /opt
sudo git clone https://github.com/zalkassem/wex.git
sudo chown -R $USER:$USER /opt/wexcommerce
sudo chmod -R +x /opt/wexcommerce/__scripts
sudo ln -s /opt/wexcommerce/__scripts/wc-deploy.sh /usr/local/bin/wc-deploy
sudo cp /opt/wexcommerce/__services/wexcommerce.service /etc/systemd/system
sudo systemctl enable wexcommerce.service
sudo cp /opt/wexcommerce/__services/wexcommerce-backend.service /etc/systemd/system
sudo systemctl enable wexcommerce-backend.service
sudo cp /opt/wexcommerce/__services/wexcommerce-frontend.service /etc/systemd/system
sudo systemctl enable wexcommerce-frontend.service
sudo echo -e "NODE_ENV = production\nWC_PORT = 4004\nWC_HTTPS = false\nWC_PRIVATE_KEY = /etc/ssl/wexcommerce.key\nWC_CERTIFICATE = /etc/ssl/wexcommerce.crt\nWC_DB_HOST = 127.0.0.1\nWC_DB_PORT = 27017\nWC_DB_SSL = false\nWC_DB_SSL_KEY = /etc/ssl/wexcommerce.key\nWC_DB_SSL_CERT = /etc/ssl/wexcommerce.crt\nWC_DB_SSL_CA = /etc/ssl/wexcommerce.ca.pem\nWC_DB_DEBUG = true\nWC_DB_APP_NAME = wexcommerce\nWC_DB_AUTH_SOURCE = admin\nWC_DB_USERNAME = admin\nWC_DB_PASSWORD = admin\nWC_DB_NAME = wexcommerce\nWC_JWT_SECRET = zeiad2023\nWC_JWT_EXPIRE_AT = 86400\nWC_TOKEN_EXPIRE_AT = 86400\nWC_SMTP_HOST = smtp.gmail.com\nWC_SMTP_PORT = 465\nWC_SMTP_USER = z.arab.sy@gmail.com\nWC_SMTP_PASS = "$1"\nWC_SMTP_FROM = z.arab.sy@gmail.com\nWC_ADMIN_EMAIL = z.arab.sy@gmail.com\nWC_CDN_PRODUCTS = /var/www/cdn/wexcommerce/products\nWC_CDN_TEMP_PRODUCTS = /var/www/cdn/wexcommerce/temp/products\nWC_BACKEND_HOST = http://"$myip":8002/\nWC_FRONTEND_HOST = http://"$myip":8001/\nWC_DEFAULT_LANGUAGE = en\nWC_DEFAULT_CURRENCY = $">> /opt/wexcommerce/api/.env
sudo echo -e "NEXT_PUBLIC_WC_API_HOST = http://"$myip":4004\nNEXT_PUBLIC_WC_PAGE_SIZE = 30\nNEXT_PUBLIC_WC_CDN_PRODUCTS = http://"$myip"/cdn/wexcommerce/products\nNEXT_PUBLIC_WC_CDN_TEMP_PRODUCTS = http://"$myip"/cdn/wexcommerce/temp/products\nNEXT_PUBLIC_WC_APP_TYPE = backend">> /opt/wexcommerce/backend/.env
sudo echo -e "NEXT_PUBLIC_WC_API_HOST = http://"$myip":4004\nNEXT_PUBLIC_WC_PAGE_SIZE = 30\nNEXT_PUBLIC_WC_CDN_PRODUCTS = http://"$myip"/cdn/wexcommerce/products\nNEXT_PUBLIC_WC_CDN_TEMP_PRODUCTS = http://"$myip"/cdn/wexcommerce/temp/products\nNEXT_PUBLIC_WC_APP_TYPE = frontend">> /opt/wexcommerce/frontend/.env
sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default-old
sudo echo -e "server {\n\tlisten 80 default_server;\n\tserver_name _;\n\taccess_log /var/log/nginx/wexcommerce.frontend.access.log;\n\terror_log /var/log/nginx/wexcommerce.frontend.error.log;\n\n\tlocation / {\n\t\tproxy_pass http://localhost:8001;\n\t\tproxy_http_version 1.1;\n\t\tproxy_set_header Upgrade $http_upgrade;\n\t\tproxy_set_header Connection 'upgrade';\n\t\tproxy_set_header Host $host;\n\t\tproxy_cache_bypass $http_upgrade;\n\t}\n\tlocation /cdn {\n\t\talias /var/www/cdn;\n\t}\n}\n\n\nserver {\n\tlisten 3000 default_server;\n\tserver_name _;\n\taccess_log /var/log/nginx/wexcommerce.backend.access.log;\n\terror_log /var/log/nginx/wexcommerce.backend.error.log;\n\n\tlocation / {\n\t\tproxy_pass http://localhost:8002;\n\t\tproxy_http_version 1.1;\n\t\tproxy_set_header Upgrade $http_upgrade;\n\t\tproxy_set_header Connection 'upgrade';\n\t\tproxy_set_header Host $host;\n\t\tproxy_cache_bypass $http_upgrade;\n\t}\n}"> /etc/nginx/sites-available/default
sudo nginx -t
sudo systemctl restart nginx.service
sudo systemctl status nginx.service
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow 22/tcp
sudo ufw allow 4004/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 3000/tcp
sudo ufw allow 27017/tcp
sudo ufw allow 465/tcp
