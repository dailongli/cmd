# update system
apt-get update
apt-get -y upgrade

# download nginx and uncompress
curl http://nginx.org/download/nginx-1.18.0.tar.gz -o nginx-1.18.0.tar.gz | tar -xz