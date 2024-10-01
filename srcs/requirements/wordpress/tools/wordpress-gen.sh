#!/bin/sh

mkdir -p ~/data
cd ~/data
curl -O https://wordpress.org/wordpress-6.6.2.tar.gz
tar -xf wordpress-6.6.2.tar.gz
rm -rf *tar.gz
echo "<?php echo phpinfo();?>" > ./wordpress/test.php