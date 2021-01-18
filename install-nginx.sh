# update system
sudo apt-get update
sudo apt-get -y upgrade

# install dependencies
sudo apt-get -y install build-essential libpcre3-dev zlib1g-dev libssl-dev

# download nginx and uncompress
if [ -d "./nginx-1.18.0" ]
then
	echo "nginx 1.18.0 already exists"
else
	echo "downloading nginx-1.18.0.tar.gz ..."
	curl http://nginx.org/download/nginx-1.18.0.tar.gz | tar -xz
fi

# build nginx with ssl and httpv2 support
cd nginx-1.18.0
./configure --with-http_ssl_module --with-http_v2_module
make
sudo make install


# create autostart script
sudo touch /lib/systemd/system/nginx.service 
sudo bash -c 'cat > /lib/systemd/system/nginx.service' << EOF
[Unit]
Description=A high performance web server and a reverse proxy server
After=network.target

[Service]
Type=forking
PIDFile=/usr/local/nginx/logs/nginx.pid
ExecStartPre=/usr/local/nginx/sbin/nginx -t -q -g 'daemon on; master_process on;'
ExecStart=/usr/local/nginx/sbin/nginx -g 'daemon on; master_process on;'
ExecReload=/usr/local/nginx/sbin/nginx -g 'daemon on; master_process on;' -s reload
ExecStop=-/sbin/start-stop-daemon --quiet --stop --retry QUIT/5 --pidfile /usr/local/nginx/logs/nginx.pid
TimeoutStopSec=5
KillMode=mixed

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable nginx.service
sudo systemctl start nginx.service

# logrotate
sudo touch /etc/logrotate.d/nginx
sudo bash -c 'cat > /etc/logrotate.d/nginx' << EOF
/usr/local/nginx/logs/access.log {
        daily
        missingok
        rotate 12
        compress
        notifempty
}
/usr/local/nginx/logs/error.log {
        daily
        missingok
        rotate 12
        compress
        notifempty
}
EOF

rm -rf nginx-1.18.0
echo "nginx install finish."