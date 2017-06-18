#!/bin/bash

ping -c1 8.8.8.8  &> /dev/null
     if [ $? != 0 ]
     then
     {
       echo -e "\e[1;31mCheck your Internet connection\e[0m"
     }
     else
     {
       echo "-----------Ready for installation----------------------------------------------------------------------------"
       echo "-----------Updating the source list--------------------------------------------------------------------------"
       sudo apt-get update  > /dev/null
        if [ $? == 0 ]
        then
        {
        dname=$(sed -E 's/^((ftp|www)\.)?([^.]*)\..*/\3/' <<< "$HOSTNAME")
        IP="127.0.0.1"
        sudo -- sh -c -e "echo '$IP $dname' >> /etc/hosts";

# Add Ondrej Repository with PHP5
sudo add-apt-repository -y ppa:ondrej/php
sudo apt-get update

echo "---------------------------------------------------------------------------------------------------------"
           echo "----------------------------PART 2 STARTED----------------------------------------------------------------"
	   echo "-----------------------------Lets start with Installaton--------------------------------------------------"
 	   dbpass=(root)
	   #add the packages name that you want to install or check in below array
	   package=( mysql-server nginx php5.6 php5.6-curl php5.6-mcrypt php5.6-readline git-core php5.6-xdebug php5-fpm php5.6-mysql php5.6-gd libssh2-php vim curl lynx screen nmap tree wget python3 python3-pip python-software-properties build-essential libssl-dev libffi-dev python-dev)
	   for var in "${package[@]}"
           do
	    dpkg-query -W "${var}" > /tmp/wordpress-install.log 2> /tmp/wordpress-install-error.log

   	      if [ $? == 0 ]
              then
               {
           echo "${var} is installed"
        }
      else
       {
        if [ ${var} == "mysql-server" ]
       then
       {
        echo "installing mysql-server now"
        echo "It will take time to install"
        sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $dbpass"
        sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $dbpass"
        sudo apt-get -y install mysql-server >> /tmp/wordpress-install.log 2>> /tmp/wordpress-install-error.log
            if [ $? == 0 ]
            then
            {
                echo -e "-----------\e[1;32m ${var} was installed succesfully.\e[0m------------------------------------------"
                echo "-------------------------------------------------------------------------------------------------------"
            }
           else
            {
               echo -e "\e[1;31m--ERROR--- There was problem while installing ${var}----\e[0m"
               exit 1
            }
           fi

      }
     fi
        echo "${var} is not installed"
        echo "${var} is installing right now "
        sudo apt-get install ${var} -y  >> /tmp/filelog 2>> /tmp/error.log
         if [ $? == 0 ]
          then
          {
            echo -e "-----------\e[1;32m${var} was installed succesfully.\e[0m------------------------------------------------"
            echo "------------------------------------------------------------------------------------------------------------"
          }
         else
          {
            echo -e "\e[1;31m--ERROR--- There was problem while installing ${var}----\e[0m"
            exit 1
          }
         fi
         }
        fi
      done
echo "-----------------------PART 2 completed succesfully----------------------------------------------------------------------"
echo "-------------------------------------------------------------------------------------------------------------------------"


cat << EOF | sudo tee -a /etc/php5/mods-available/xdebug.ini
xdebug.scream=1
xdebug.cli_color=1
xdebug.show_local_vars=1
EOF

curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

echo "-----------------------PART 3 STARTED-------------------------------------------------------------------------------------"
#Create a MySQL Database and User for WordPress
CON=$dname\_db
DBCON=$(echo $CON | sed -e 's/\./_/g' -e 's/-/_/g' -e 's/ /_/g')
DBHOST=localhost
DBNAME=$DBCON
DBUSER=wordpress
DBPASSWD=test123
echo -e "\n--- Setting up our MySQL user and db --------------------------------------------------------------------------------\n"
mysql -uroot -p$dbpass -e "CREATE DATABASE $DBNAME" >> /tmp/wordpress-mysql.log 2>> /tmp/wordpress-mysql-error.log
if [ $? == 0 ]
    then
     {
          echo -e "\n--- \e[1;32m Successfully created the database\e[0m \e[1;36m $DBNAME \e[0m---------------------------------\n"
     }
    else
     {
        echo -e "\e[1;31munable to create the database please check the error log /tmp/wordpress-mysql-error.log\e[0m"
        exit 1
     }
fi
mysql -uroot -p$dbpass -e "CREATE USER $DBNAME@$DBHOST IDENTIFIED BY '$DPASSWD';" >> /tmp/wordpress-mysql.log 2>> /tmp/wordpress-mysql-error.log
if [ $? == 0 ]
    then
     {
        echo -e "\n--- \e[1;32m Successfully created the user\e[0m \e[36m$DBNAME\e[0m \e[32mwith password \e[0m \e[1;36m $DBPASSWD \e[0m ---\n"
     }
    else
     {
        echo -e "\e[1;31munable to create username and password please check the error log /tmp/wordpress-mysql-error.log\e[0m"
     }
 fi
mysql -uroot -p$dbpass -e "grant all privileges on $DBNAME.* to '$DBUSER'@'localhost' identified by '$DBPASSWD'" >> /tmp/wordpress-mysql.log 2>> /tmp/wordpress-mysql-error.log
if [ $? == 0 ]
    then
     {
          echo -e "\n--- \e[32mSuccessfully granted the permission for the users\e[0m ------------------------------\n"
     }
    else
     {
        echo -e "\e[1;31munable to graant the permission \e[0m"
     }
fi
mysql -uroot -p$dbpass -e FLUSH PRIVILEGES >> /tmp/wordpress-mysql.log 2>> /tmp/wordpress-mysql-error.log
echo  "-------------------------------- Successfully setup the Database Part ------------------------------------------"
echo "----------------------------------Part 3 completed Succesfully---------------------------------------------------"
echo "-----------------------------------------------------------------------------------------------------------------"



echo "------------------------------------------------------------------------------------------------------------------"
echo "----------------------------Installation of Wordpress-------------------------------------------------------------"
echo "----------------------------PART 4 STARTED------------------------------------------------------------------------"
#download wordpress
echo "Downloading the wordpress..........."
ls lates* >> /tmp/wordpress-setup.log 2>> /tmp/wordpress-setup-error.log
if [ $? == 0 ]
    then
     {
          sudo mv latest.* /tmp/
     }
fi
sudo wget https://wordpress.org/latest.tar.gz >> /tmp/wordpress-setup.log 2>> /tmp/wordpress-setup-error.log
if [ $? == 0 ]
    then
     {
          echo -e "\n--- \e[32mDownloaded the Wordpress Successfully\e[0m------------------------------------------------"
     }
    else
     {
        echo -e "\e[1;31m unable to Download Wordpress\e[0m"
        exit 1
     }
fi
echo "......UnZip ....Configure of wp-config.php......--------------------------------------------------------------------"

#unzip wordpress
tar -zxvf latest.tar.gz >> /tmp/wordpress-setup.log 2>> /tmp/wordpress-setup-error.log
#change dir to wordpress
cd wordpress >> /tmp/wordpress-setup.log 2>> /tmp/wordpress-setup-error.log
#copy file to backup file to config file
cp wp-config-sample.php wp-config.php >> /tmp/wordpress-setup.log 2>> /tmp/wordpress-setup-error.log
#set database details with perl find and replace
perl -pi -e "s/database_name_here/$DBNAME/g" wp-config.php >> /tmp/wordpress-setup.log 2>> /tmp/wordpress-setup-error.log
perl -pi -e "s/username_here/$DBUSER/g" wp-config.php >> /tmp/wordpress-setup.log 2>> /tmp/wordpress-setup-error.log
perl -pi -e "s/password_here/$DBPASSWD/g" wp-config.php >> /tmp/wordpress-setup.log 2>> /tmp/wordpress-setup-error.log

#set WP salts
perl -i -pe'
  BEGIN {
    @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
    push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
    sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
  }
  s/put your unique phrase here/salt()/ge
' wp-config.php >> /tmp/wordpress-setup.log 2>> /tmp/wordpress-setup-error.log


echo "----------------------------PART 4 Completed Successfully------------------------------------------------------------"
echo "---------------------------------------------------------------------------------------------------------------------"

sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5.6/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php5.6/apache2/php.ini
sed -i "s/disable_functions = .*/disable_functions = /" /etc/php5.6/cli/php.ini

echo "----------------------------PART 5 Setup of NGINX--------------------------------------------------------------------"
echo "--------------------Nginx Configurations-----------------------------------------------------------------------------"
cd ..
sudo mkdir -p /var/www/$dname
sudo cp  -r wordpress/* /var/www/$dname/
sudo chown -R www-data:www-data /var/www/$dname /tmp/wordpress-setup.log 2>> /tmp/wordpress-setup-error.log
sudo chmod -R 755 /var/www/$dname /tmp/wordpress-setup.log 2>> /tmp/wordpress-setup-error.log
(
cat <<EOF
server {
        listen 80 default_server;
        listen [::]:80 default_server ipv6only=on;
        root /var/www/$dname;
        index index.php index.html index.htm;
        server_name $dname;
        location / {
                # try_files \$uri \$uri/ =404;
                try_files \$uri \$uri/ /index.php?q=\$uri&\$args;
        }
        error_page 404 /404.html;
        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
                root /usr/share/nginx/html;
        }
        location ~ \.php$ {
                try_files \$uri =404;
                fastcgi_split_path_info ^(.+\.php)(/.+)$;
                fastcgi_pass unix:/var/run/php5-fpm.sock;
                fastcgi_index index.php;
                include fastcgi_params;
        }
}
EOF
) >  /etc/nginx/sites-available/$dname.conf

sudo ln -s /etc/nginx/sites-available/$dname.conf /etc/nginx/sites-enabled/
sudo service nginx restart  >> /tmp/wordpress-setup.log 2>> /tmp/wordpress-setup-error.log
 if [ $? == 0 ]
       then
        {
         echo -e "-----------\e[32mNginx was succesfully configured.\e[0m--------------------------------------------"
         echo "------------------------------------------------------------------------------------------------------"
        }
      else
       {
         echo -e "\e[1;31m--There was problem while configuring Ngnix please check log /tmp/wordpress-setup-error.log-------\e[0m"
         exit
       }
      fi
sudo service php5-fpm restart >> /tmp/wordpress-setup.log 2>> /tmp/wordpress-setup-error.log
 if [ $? == 0 ]
       then
        {
         echo -e "-----------\e[32mphp5-fpm was succesfully restarted\e[0m--------------------------------------------"
         echo "-------------------------------------------------------------------------------------------------------"
        }
      else
       {
         echo -e "\e[1;31m--There was problem while restarting ph5.6-fpm please check log /tmp/wordpress-setup-error.log-------\e[0m"
         exit
       }
      fi
 sudo rm -rf wordpress
 sudo rm -rf latest.tar.gz
echo "-----------------------------------------PART 5 Completed succesfully--------------------------------------------"
echo "-----------------------------------------------------------------------------------------------------------------"
echo -e "-----------------OPEN THE BROWSER AND TYPE  \e[36mhttp://$dname/wp-admin/install.php\e[0m---------------------"
echo -e "-----------------Make sure that ANY OTHER WEB SERVER IS NOT LISTENING ON PORT 80------------------------------"
echo "-----------------------------------------------------------------------------------------------------------------"

        }
        else
        {
         echo -e "\e[1;31m---------can't update the source list--------\e[0m"
         exit 1
        }
       fi
     }
     fi
