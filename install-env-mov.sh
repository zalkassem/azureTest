sudo apt-get -y update
sudo apt-get -y install unzip
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
sudo systemctl enable mongod
sudo systemctl start mongod
cd /tmp
sudo echo -e "db = connect( 'mongodb://localhost/admin' );\n\ndb.createUser(\n\t{\n\tuser: \"admin\",\n\tpwd: \""$2"\",\n\troles: [\n\t\t\"userAdminAnyDatabase\",\n\t\t\"dbAdminAnyDatabase\",\n\t\t\"readWriteAnyDatabase\",\n\t\t]\n\t}\n)" >load.js
sudo mongosh load /tmp/load.js
sudo systemctl restart mongod
cd /etc
sudo sed -i 's/#security:/security:\n  authorization: enabled/g' mongod.conf
sudo sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/g' mongod.conf
sudo systemctl restart mongod
cd /opt
sudo git clone https://github.com/zalkassem/"$3".git
sudo chown -R $USER:$USER /opt/"$3"
sudo chmod -R +x /opt/"$3"/__scripts
sudo ln -s /opt/"$3"/__scripts/mi-deploy.sh /usr/local/bin/mi-deploy
sudo cp /opt/"$3"/__services/movinin.service /etc/systemd/system
sudo systemctl enable "$3".service
#sudo cp /opt/"$3"/__services/"$3"-backend.service /etc/systemd/system
#sudo systemctl enable "$3"-backend.service
#sudo cp /opt/"$3"/__services/"$3"-frontend.service /etc/systemd/system
#sudo systemctl enable "$3"-frontend.service
myip="$(dig +short myip.opendns.com @resolver1.opendns.com)"
sudo echo -e "NODE_ENV = production\nWC_PORT = 4004\nWC_HTTPS = false\nWC_PRIVATE_KEY = /etc/ssl/"$3".key\nWC_CERTIFICATE = /etc/ssl/"$3".crt\nWC_DB_HOST = 127.0.0.1\nWC_DB_PORT = 27017\nWC_DB_SSL = false\nWC_DB_SSL_KEY = /etc/ssl/"$3".key\nWC_DB_SSL_CERT = /etc/ssl/"$3".crt\nWC_DB_SSL_CA = /etc/ssl/"$3".ca.pem\nWC_DB_DEBUG = true\nWC_DB_APP_NAME = "$3"\nWC_DB_AUTH_SOURCE = admin\nWC_DB_USERNAME = admin\nWC_DB_PASSWORD = "$2"\nWC_DB_NAME = "$3"\nWC_JWT_SECRET = zeiad2023\nWC_JWT_EXPIRE_AT = 86400\nWC_TOKEN_EXPIRE_AT = 86400\nWC_SMTP_HOST = smtp.gmail.com\nWC_SMTP_PORT = 465\nWC_SMTP_USER = z.arab.sy@gmail.com\nWC_SMTP_PASS = "$1"\nWC_SMTP_FROM = z.arab.sy@gmail.com\nWC_ADMIN_EMAIL = z.arab.sy@gmail.com\nWC_CDN_PRODUCTS = /var/www/cdn/"$3"/products\nWC_CDN_TEMP_PRODUCTS = /var/www/cdn/"$3"/temp/products\nWC_BACKEND_HOST = http://"$myip":8002/\nWC_FRONTEND_HOST = http://"$myip":8001/\nWC_DEFAULT_LANGUAGE = en\nWC_DEFAULT_CURRENCY = $">> /opt/"$3"/api/.env
sudo echo -e "NEXT_PUBLIC_WC_API_HOST = http://"$myip":4004\nNEXT_PUBLIC_WC_PAGE_SIZE = 30\nNEXT_PUBLIC_WC_CDN_PRODUCTS = http://"$myip"/cdn/"$3"/products\nNEXT_PUBLIC_WC_CDN_TEMP_PRODUCTS = http://"$myip"/cdn/"$3"/temp/products\nNEXT_PUBLIC_WC_APP_TYPE = backend">> /opt/"$3"/backend/.env
sudo echo -e "REACT_APP_NODE_ENV=production\nREACT_APP_MI_API_HOST=http://"$myip":4004\nREACT_APP_MI_RECAPTCHA_ENABLED=false\nREACT_APP_MI_RECAPTCHA_SITE_KEY=GOOGLE_RECAPTCHA_SITE_KEY\nREACT_APP_MI_DEFAULT_LANGUAGE=en\nREACT_APP_MI_PAGE_SIZE=30\nREACT_APP_MI_PROPERTIES_PAGE_SIZE=15\nREACT_APP_MI_BOOKINGS_PAGE_SIZE=20\nREACT_APP_MI_BOOKINGS_MOBILE_PAGE_SIZE=10\nREACT_APP_MI_CDN_USERS=http://"$myip"/cdn/"$3"/users\nREACT_APP_MI_CDN_PROPERTIES=http://"$myip"/cdn/"$3"/properties\nREACT_APP_MI_AGENCY_IMAGE_WIDTH=60\nREACT_APP_MI_AGENCY_IMAGE_HEIGHT=30\nREACT_APP_MI_PROPERTY_IMAGE_WIDTH=300\nREACT_APP_MI_PROPERTY_IMAGE_HEIGHT=200\nREACT_APP_MI_MINIMUM_AGE=21\nREACT_APP_MI_PAGINATION_MODE=classic">> /opt/"$3"/frontend/.env
sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default-old
sudo echo -e "server {\n\troot /var/www/movinin/frontend;\n\tlisten 80 default_server;\n\tserver_name _;\n\taccess_log /var/log/nginx/"$3".frontend.access.log;\n\terror_log /var/log/nginx/"$3".frontend.error.log;\n\n\tlocation / {\n\t\ttry_files \$uri \$uri/ /index.html =404;\n\t}\n\tlocation /cdn {\n\t\talias /var/www/cdn;\n\t}\n}\n\n\nserver {\n\troot /var/www/movinin/backend;\n\tlisten 3003 default_server;\n\tserver_name _;\n\taccess_log /var/log/nginx/"$3".backend.access.log;\n\terror_log /var/log/nginx/"$3".backend.error.log;\n\n\tindex index.html;\n\n\tlocation / {\n\t\ttry_files \$uri \$uri/ /index.html =404;\n\t}\n}"> /etc/nginx/sites-available/default
sudo nginx -t
sudo systemctl restart nginx.service
sudo systemctl status nginx.service
sudo mkdir /var/www/cdn
sudo mkdir /var/www/cdn/"$3"
cd /tmp
sudo mkdir db
cd db
sudo git clone https://github.com/zalkassem/wexDb.git
cd wexDb/mov
sudo cp -r ./cdn/properties /var/www/cdn/"$3"
sudo cp -r ./cdn/users /var/www/cdn/"$3"
sudo mkdir /var/www/cdn/"$3"/temp
sudo mkdir /var/www/cdn/"$3"/temp/users
sudo mkdir /var/www/cdn/"$3"/temp/properties
mongorestore --verbose --drop --gzip --host=127.0.0.1 --port=27017 --username=admin --password="$2" --authenticationDatabase=admin --nsInclude="movinin.*" --archive=movinin.gz
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow 22/tcp
sudo ufw allow 4004/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 3003/tcp
sudo ufw allow 27017/tcp
sudo ufw allow 465/tcp
