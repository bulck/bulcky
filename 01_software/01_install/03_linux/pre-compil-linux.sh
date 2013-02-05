#!/bin/bash

set -e 
dir=`dirname $0`
cd $dir
(cd ../../../ && svn up)
SRC_DIR=../../02_src/joomla
DEST_DIR=../../01_install/01_src/01_xampp

function usage {
            echo "usage: $0"
            echo "                      ubuntu32|ubuntu64 <version> fr|en"
            echo "                      ubuntu32-admin|ubuntu64-admin <version> fr|en"
            echo "                      clean"
            exit 1
}


if [ "$2" == "" ] && [ "$1" != "clean" ]; then
    usage
fi

if [ "$3" == "" ] && [ "$1" != "clean" ]; then
    usage
fi

VERSION=$2
LANGUAGE=$3


case "$1" in
      "ubuntu64"|"ubuntu64-admin" )
            rm -Rf ../01_src/01_xampp/*
            mkdir ../01_src/01_xampp/cultibox
            cp -R ./conf-package/DEBIAN64 ../01_src/01_xampp/cultibox/DEBIAN
            mkdir ../01_src/01_xampp/cultibox/opt
            mkdir -p ../01_src/01_xampp/cultibox/usr/share/applications/
            cp ./conf-package/cultibox.desktop ../01_src/01_xampp/cultibox/usr/share/applications/
            

            if [ "$1" == "ubuntu64" ]; then
                tar zxvfp xampp-linux-1.8.1.tar.gz -C ../01_src/01_xampp/cultibox/opt/
            else
                tar zxvfp xampp-linux-admin-1.8.1.tar.gz -C ../01_src/01_xampp/cultibox/opt/
            fi

            cp -R ../../02_src/joomla ../01_src/01_xampp/cultibox/opt/lampp/htdocs/cultibox
            cat ../../CHANGELOG > ../01_src/01_xampp/cultibox/opt/lampp/VERSION

           cp conf-lampp/httpd.conf ../01_src/01_xampp/cultibox/opt/lampp/etc/
           cp conf-lampp/php.ini ../01_src/01_xampp/cultibox/opt/lampp/etc/
           cp conf-lampp/httpd-xampp.conf ../01_src/01_xampp/cultibox/opt/lampp/etc/extra/
           cp conf-lampp/my.cnf ../01_src/01_xampp/cultibox/opt/lampp/etc/
           cp conf-script/* ../01_src/01_xampp/cultibox/opt/lampp/
           cp ../01_src/03_sd/cultibox.ico ../01_src/01_xampp/cultibox/opt/lampp/
           cp -R ../../01_install/01_src/03_sd ../01_src/01_xampp/cultibox/opt/lampp/sd
           cp -R ../../01_install/01_src/02_sql ../01_src/01_xampp/cultibox/opt/lampp/sql_install
           cp ../../01_install/01_src/03_sd/firm.hex ../01_src/01_xampp/cultibox/opt/lampp/htdocs/cultibox/tmp/
           cp ../../01_install/01_src/03_sd/emetteur.hex ../01_src/01_xampp/cultibox/opt/lampp/htdocs/cultibox/tmp/
           cp ../../01_install/01_src/03_sd/sht.hex ../01_src/01_xampp/cultibox/opt/lampp/htdocs/cultibox/tmp/
           cp ../../01_install/01_src/03_sd/cultibox.ico ../01_src/01_xampp/cultibox/opt/lampp/htdocs/cultibox/tmp/
           cp ../../01_install/01_src/03_sd/cultibox.html ../01_src/01_xampp/cultibox/opt/lampp/htdocs/cultibox/tmp/
            
           cp -R daemon ../01_src/01_xampp/cultibox/opt/lampp/

           if [ "$1" == "ubuntu64-admin" ]; then
                cp conf-lampp/config.inc.php ../01_src/01_xampp/cultibox/opt/lampp/phpmyadmin/
           fi

           #replacement of the old version number by the new one in VERSION file
           if [ "$LANGUAGE" == "fr" ]; then
                sed -i "s/'[0-9]\+\.[0-9]\+\.[0-9]\+'/'`echo $VERSION`'/" ../01_src/01_xampp/cultibox/opt/lampp/sql_install/cultibox_fr.sql
                mv ../01_src/01_xampp/cultibox/opt/lampp/sql_install/cultibox_fr.sql ../01_src/01_xampp/cultibox/opt/lampp/sql_install/cultibox.sql
           fi

           if [ "$LANGUAGE" == "en" ]; then
                sed -i "s/'[0-9]\+\.[0-9]\+\.[0-9]\+'/'`echo $VERSION`'/" ../01_src/01_xampp/cultibox/opt/lampp/sql_install/cultibox_en.sql
                mv ../01_src/01_xampp/cultibox/opt/lampp/sql_install/cultibox_en.sql ../01_src/01_xampp/cultibox/opt/lampp/sql_install/cultibox.sql
           fi
           sed -i "s/Version: .*/Version: `echo $VERSION`-ubuntu/g" ../01_src/01_xampp/cultibox/DEBIAN/control
           sed -i "s/Version=.*/Version=`echo $VERSION`/g" ../01_src/01_xampp/cultibox/usr/share/applications/cultibox.desktop

           find ./../01_src/01_xampp/cultibox/opt/lampp -name ".svn"|xargs rm -Rf
           mv ../01_src/01_xampp/cultibox/opt/lampp ../01_src/01_xampp/cultibox/opt/cultibox

           cd ./../01_src/01_xampp/ && dpkg-deb --build cultibox
           mv cultibox.deb ../../03_linux/Output/cultibox-ubuntu64-`echo $VERSION`_`echo $LANGUAGE`.deb
      ;;
      "ubuntu32"|"ubuntu32-admin")
            rm -Rf ../01_src/01_xampp/*
            mkdir ../01_src/01_xampp/cultibox
            cp -R ./conf-package/DEBIAN ../01_src/01_xampp/cultibox/DEBIAN
            mkdir ../01_src/01_xampp/cultibox/opt
            mkdir -p ../01_src/01_xampp/cultibox/usr/share/applications/
            cp ./conf-package/cultibox.desktop ../01_src/01_xampp/cultibox/usr/share/applications/

            if [ "$1" == "ubuntu32" ]; then
                tar zxvfp xampp-linux-1.8.1.tar.gz -C ../01_src/01_xampp/cultibox/opt/
            else
                tar zxvfp xampp-linux-admin-1.8.1.tar.gz -C ../01_src/01_xampp/cultibox/opt/
            fi

            cp -R ../../02_src/joomla ../01_src/01_xampp/cultibox/opt/lampp/htdocs/cultibox
            cat ../../CHANGELOG > ../01_src/01_xampp/cultibox/opt/lampp/VERSION

           cp conf-lampp/httpd.conf ../01_src/01_xampp/cultibox/opt/lampp/etc/
           cp conf-lampp/php.ini ../01_src/01_xampp/cultibox/opt/lampp/etc/
           cp conf-lampp/httpd-xampp.conf ../01_src/01_xampp/cultibox/opt/lampp/etc/extra/
           cp conf-script/* ../01_src/01_xampp/cultibox/opt/lampp/
           cp conf-lampp/my.cnf ../01_src/01_xampp/cultibox/opt/lampp/etc/
           cp ../01_src/03_sd/cultibox.ico ../01_src/01_xampp/cultibox/opt/lampp/
           cp -R ../../01_install/01_src/03_sd ../01_src/01_xampp/cultibox/opt/lampp/sd
           cp -R ../../01_install/01_src/02_sql ../01_src/01_xampp/cultibox/opt/lampp/sql_install
           cp ../../01_install/01_src/03_sd/firm.hex ../01_src/01_xampp/cultibox/opt/lampp/htdocs/cultibox/tmp/
           cp ../../01_install/01_src/03_sd/emetteur.hex ../01_src/01_xampp/cultibox/opt/lampp/htdocs/cultibox/tmp/
           cp ../../01_install/01_src/03_sd/sht.hex ../01_src/01_xampp/cultibox/opt/lampp/htdocs/cultibox/tmp/
           cp ../../01_install/01_src/03_sd/cultibox.ico ../01_src/01_xampp/cultibox/opt/lampp/htdocs/cultibox/tmp/
           cp ../../01_install/01_src/03_sd/cultibox.html ../01_src/01_xampp/cultibox/opt/lampp/htdocs/cultibox/tmp/

           cp -R daemon ../01_src/01_xampp/cultibox/opt/lampp/

           if [ "$1" == "ubuntu32-admin" ]; then
                cp conf-lampp/config.inc.php ../01_src/01_xampp/cultibox/opt/lampp/phpmyadmin/
           fi

           #replacement of the old version number by the new one in VERSION file
           if [ "$LANGUAGE" == "fr" ]; then
                sed -i "s/'[0-9]\+\.[0-9]\+\.[0-9]\+'/'`echo $VERSION`'/" ../01_src/01_xampp/cultibox/opt/lampp/sql_install/cultibox_fr.sql
                mv ../01_src/01_xampp/cultibox/opt/lampp/sql_install/cultibox_fr.sql ../01_src/01_xampp/cultibox/opt/lampp/sql_install/cultibox.sql
           fi

           if [ "$LANGUAGE" == "en" ]; then
                sed -i "s/'[0-9]\+\.[0-9]\+\.[0-9]\+'/'`echo $VERSION`'/" ../01_src/01_xampp/cultibox/opt/lampp/sql_install/cultibox_en.sql
                mv ../01_src/01_xampp/cultibox/opt/lampp/sql_install/cultibox_en.sql ../01_src/01_xampp/cultibox/opt/lampp/sql_install/cultibox.sql
           fi

           sed -i "s/Version: .*/Version: `echo $VERSION`-ubuntu/g" ../01_src/01_xampp/cultibox/DEBIAN/control
           sed -i "s/Version=.*/Version=`echo $VERSION`/g" ../01_src/01_xampp/cultibox/usr/share/applications/cultibox.desktop

           find ./../01_src/01_xampp/cultibox/opt/lampp -name ".svn"|xargs rm -Rf
           mv ../01_src/01_xampp/cultibox/opt/lampp ../01_src/01_xampp/cultibox/opt/cultibox
           cd ./../01_src/01_xampp/ && dpkg-deb --build cultibox
           mv cultibox.deb ../../03_linux/Output/cultibox-ubuntu-`echo $VERSION`_`echo $LANGUAGE`.deb
      ;;
      "clean")
            rm -Rf ../01_src/01_xampp/*
      ;;
      *)
            usage
      ;;
esac
