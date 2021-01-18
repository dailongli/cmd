# update system
sudo apt-get update
sudo apt-get -y upgrade

# install dependencies
sudo apt-get -y install git build-essential libssl-dev

# download srs
if [ -d "./srs" ]
then
	echo "srs already exists"
else
	echo "clone srs..."
	git clone https://gitee.com/winlinvip/srs.oschina.git srs
fi


pushd srs/trunk
./configure --full --use-sys-ssl --without-utest
make
sudo make install


# create autostart script
sudo ln -sf /usr/local/srs/etc/init.d/srs /etc/init.d/srs
sudo cp -f /usr/local/srs/usr/lib/systemd/system/srs.service /usr/lib/systemd/system/srs.service
sudo systemctl daemon-reload
sudo systemctl enable srs
sudo systemctl start srs

popd
rm -rf srs
echo "srs install finish."