#!/bin/bash

set -e 
dir=`dirname $0`
cd $dir

SRC_DIR=../../02_src/joomla
DEST_DIR=../../01_install/01_src/01_xampp

function usage {
            echo "usage: $0"
            echo "                      ubuntu32|ubuntu64 <version> ?jenkins?"
            echo "                      ubuntu32-admin|ubuntu64-admin <version> ?jenkins?"
            echo "                      clean"
            exit 1
}


#Print usage informations if a parameter is missing
if [ "$2" == "" ] && [ "$1" != "clean" ]; then
    usage
fi

VERSION=$2

# Remove svn up when using jenkins
if [ "$3" == "" ]; then
    (cd ../../../ && svn up)
fi


case "$1" in
      "ubuntu64"|"ubuntu64-admin" )
           (cd ../../../02_documentation/02_userdoc/ && tclsh ./parse_wiki.tcl && pdflatex documentation.tex && pdflatex documentation.tex)
           rm -Rf ../01_src/01_xampp/*
           mkdir ../01_src/01_xampp/cultibox
           cp -R ./conf-package/DEBIAN64 ../01_src/01_xampp/cultibox/DEBIAN
           mkdir ../01_src/01_xampp/cultibox/opt
           mkdir -p ../01_src/01_xampp/cultibox/usr/share/applications/
           cp ./conf-package/cultibox.desktop ../01_src/01_xampp/cultibox/usr/share/applications/
            

           if [ "$1" == "ubuntu64" ]; then
               tar zxvfp xampp-linux-1.8.3.tar.gz -C ../01_src/01_xampp/cultibox/opt/
           else
               tar zxvfp xampp-linux-admin-1.8.3.tar.gz -C ../01_src/01_xampp/cultibox/opt/
           fi

           cp -R ../../02_src/joomla ../01_src/01_xampp/cultibox/opt/lampp/htdocs/cultibox
           cp ../../../02_documentation/02_userdoc/documentation.pdf ../01_src/01_xampp/cultibox/opt/lampp/htdocs/cultibox/main/docs/documentation_cultibox.pdf
           cat ../../CHANGELOG > ../01_src/01_xampp/cultibox/opt/lampp/VERSION.txt

           cp conf-lampp/httpd.conf ../01_src/01_xampp/cultibox/opt/lampp/etc/
           cp conf-lampp/php.ini ../01_src/01_xampp/cultibox/opt/lampp/etc/
           cp conf-lampp/httpd-xampp.conf ../01_src/01_xampp/cultibox/opt/lampp/etc/extra/
           cp conf-lampp/my.cnf ../01_src/01_xampp/cultibox/opt/lampp/etc/
           
            cat > ../01_src/01_xampp/cultibox/etc/my-extra.cnf << "EOF" 
[client]
user="root"
password="cultibox"
EOF
           cp conf-script/* ../01_src/01_xampp/cultibox/opt/lampp/
           cp conf-package/cultibox.png ../01_src/01_xampp/cultibox/opt/lampp/
           cp conf-package/lgpl3.txt ../01_src/01_xampp/cultibox/opt/lampp/LICENSE.txt
           cp -R ../../01_install/01_src/03_sd ../01_src/01_xampp/cultibox/opt/lampp/sd
           cp -R ../../01_install/01_src/02_sql ../01_src/01_xampp/cultibox/opt/lampp/sql_install
           sed -i "s/\`VERSION\` = '.*/\`VERSION\` = '`echo $VERSION`-amd64' WHERE \`configuration\`.\`id\` =1;/" ../01_src/01_xampp/cultibox/opt/lampp/sql_install/update_sql.sql
           cp ../../01_install/01_src/03_sd/firm.hex ../01_src/01_xampp/cultibox/opt/lampp/htdocs/cultibox/tmp/
           cp -R ../../01_install/01_src/03_sd/bin ../01_src/01_xampp/cultibox/opt/lampp/htdocs/cultibox/tmp/
           cp ../../01_install/01_src/03_sd/cultibox.ico ../01_src/01_xampp/cultibox/opt/lampp/htdocs/cultibox/tmp/
           cp ../../01_install/01_src/03_sd/cultibox.html ../01_src/01_xampp/cultibox/opt/lampp/htdocs/cultibox/tmp/
           cp -R ../../01_install/01_src/03_sd/cnf ../01_src/01_xampp/cultibox/opt/lampp/htdocs/cultibox/tmp/
           cp -R ../../01_install/01_src/03_sd/logs ../01_src/01_xampp/cultibox/opt/lampp/htdocs/cultibox/tmp/

            
           cp -R daemon ../01_src/01_xampp/cultibox/opt/lampp/

           if [ "$1" == "ubuntu64-admin" ]; then
                cp conf-lampp/config.inc.php ../01_src/01_xampp/cultibox/opt/lampp/phpmyadmin/
           fi

           sed -i "s/'[0-9]\+\.[0-9]\+\.[0-9]\+'/'`echo $VERSION`-amd64'/" ../01_src/01_xampp/cultibox/opt/lampp/sql_install/cultibox_fr.sql
           sed -i "s/'[0-9]\+\.[0-9]\+\.[0-9]\+'/'`echo $VERSION`-amd64'/" ../01_src/01_xampp/cultibox/opt/lampp/sql_install/cultibox_en.sql
           sed -i "s/'[0-9]\+\.[0-9]\+\.[0-9]\+'/'`echo $VERSION`-amd64'/" ../01_src/01_xampp/cultibox/opt/lampp/sql_install/cultibox_fr.sql
           sed -i "s/'[0-9]\+\.[0-9]\+\.[0-9]\+'/'`echo $VERSION`-amd64'/" ../01_src/01_xampp/cultibox/opt/lampp/sql_install/cultibox_de.sql
           sed -i "s/'[0-9]\+\.[0-9]\+\.[0-9]\+'/'`echo $VERSION`-amd64'/" ../01_src/01_xampp/cultibox/opt/lampp/sql_install/cultibox_it.sql
           sed -i "s/'[0-9]\+\.[0-9]\+\.[0-9]\+'/'`echo $VERSION`-amd64'/" ../01_src/01_xampp/cultibox/opt/lampp/sql_install/cultibox_es.sql
           sed -i "s/Version: .*/Version: `echo $VERSION`-ubuntu/g" ../01_src/01_xampp/cultibox/DEBIAN/control
           sed -i "s/Version=.*/Version=`echo $VERSION`/g" ../01_src/01_xampp/cultibox/usr/share/applications/cultibox.desktop

           find ./../01_src/01_xampp/cultibox/opt/lampp -name ".svn"|xargs rm -Rf
           mv ../01_src/01_xampp/cultibox/opt/lampp ../01_src/01_xampp/cultibox/opt/cultibox

           cd ./../01_src/01_xampp/ && dpkg-deb --build cultibox
           
           if [ "$1" == "ubuntu64" ]; then
                mv cultibox.deb ../../03_linux/Output/cultibox-ubuntu-amd64_`echo $VERSION`.deb
           else
                mv cultibox.deb ../../03_linux/Output/cultibox-admin-ubuntu-amd64_`echo $VERSION`.deb
           fi 
      ;;
      "ubuntu32"|"ubuntu32-admin")
            (cd ../../../02_documentation/02_userdoc/ && tclsh ./parse_wiki.tcl && tclsh ./parse_wiki.tcl && pdflatex documentation.tex)
            rm -Rf ../01_src/01_xampp/*
            mkdir ../01_src/01_xampp/cultibox
            cp -R ./conf-package/DEBIAN ../01_src/01_xampp/cultibox/DEBIAN
            mkdir ../01_src/01_xampp/cultibox/opt
            mkdir -p ../01_src/01_xampp/cultibox/usr/share/applications/
            cp ./conf-package/cultibox.desktop ../01_src/01_xampp/cultibox/usr/share/applications/

            if [ "$1" == "ubuntu32" ]; then
                tar zxvfp xampp-linux-1.8.3.tar.gz -C ../01_src/01_xampp/cultibox/opt/
            else
                tar zxvfp xampp-linux-admin-1.8.3.tar.gz -C ../01_src/01_xampp/cultibox/opt/
            fi

            cp -R ../../02_src/joomla ../01_src/01_xampp/cultibox/opt/lampp/htdocs/cultibox
            cp ../../../02_documentation/02_userdoc/documentation.pdf ../01_src/01_xampp/cultibox/opt/lampp/htdocs/cultibox/main/docs/documentation_cultibox.pdf
            cat ../../CHANGELOG > ../01_src/01_xampp/cultibox/opt/lampp/VERSION.txt

           cp conf-lampp/httpd.conf ../01_src/01_xampp/cultibox/opt/lampp/etc/
           cp conf-lampp/php.ini ../01_src/01_xampp/cultibox/opt/lampp/etc/
           cp conf-lampp/httpd-xampp.conf ../01_src/01_xampp/cultibox/opt/lampp/etc/extra/
           cp conf-script/* ../01_src/01_xampp/cultibox/opt/lampp/
           cp conf-lampp/my.cnf ../01_src/01_xampp/cultibox/opt/lampp/etc/
           cp conf-package/cultibox.png ../01_src/01_xampp/cultibox/opt/lampp/
           cp conf-package/lgpl3.txt ../01_src/01_xampp/cultibox/opt/lampp/LICENSE.txt
cat > ../01_src/01_xampp/cultibox/etc/my-extra.cnf << "EOF" 
[client]
user="root"
password="cultibox"
EOF
           cp -R ../../01_install/01_src/03_sd ../01_src/01_xampp/cultibox/opt/lampp/sd
           cp -R ../../01_install/01_src/02_sql ../01_src/01_xampp/cultibox/opt/lampp/sql_install
           sed -i "s/\`VERSION\` = '.*/\`VERSION\` = '`echo $VERSION`-amd64' WHERE \`configuration\`.\`id\` =1;/" ../01_src/01_xampp/cultibox/opt/lampp/sql_install/update_sql.sql
           cp ../../01_install/01_src/03_sd/firm.hex ../01_src/01_xampp/cultibox/opt/lampp/htdocs/cultibox/tmp/
           cp -R ../../01_install/01_src/03_sd/bin ../01_src/01_xampp/cultibox/opt/lampp/htdocs/cultibox/tmp/
           cp ../../01_install/01_src/03_sd/cultibox.ico ../01_src/01_xampp/cultibox/opt/lampp/htdocs/cultibox/tmp/
           cp ../../01_install/01_src/03_sd/cultibox.html ../01_src/01_xampp/cultibox/opt/lampp/htdocs/cultibox/tmp/
           cp -R ../../01_install/01_src/03_sd/cnf ../01_src/01_xampp/cultibox/opt/lampp/htdocs/cultibox/tmp/
           cp -R ../../01_install/01_src/03_sd/logs ../01_src/01_xampp/cultibox/opt/lampp/htdocs/cultibox/tmp/

           cp -R daemon ../01_src/01_xampp/cultibox/opt/lampp/

           if [ "$1" == "ubuntu32-admin" ]; then
                cp conf-lampp/config.inc.php ../01_src/01_xampp/cultibox/opt/lampp/phpmyadmin/
           fi

           #replacement of the old version number by the new one in VERSION file
           sed -i "s/'[0-9]\+\.[0-9]\+\.[0-9]\+'/'`echo $VERSION`-i386'/" ../01_src/01_xampp/cultibox/opt/lampp/sql_install/cultibox_fr.sql
           sed -i "s/'[0-9]\+\.[0-9]\+\.[0-9]\+'/'`echo $VERSION`-i386'/" ../01_src/01_xampp/cultibox/opt/lampp/sql_install/cultibox_en.sql
           sed -i "s/'[0-9]\+\.[0-9]\+\.[0-9]\+'/'`echo $VERSION`-i386'/" ../01_src/01_xampp/cultibox/opt/lampp/sql_install/cultibox_de.sql
           sed -i "s/'[0-9]\+\.[0-9]\+\.[0-9]\+'/'`echo $VERSION`-i386'/" ../01_src/01_xampp/cultibox/opt/lampp/sql_install/cultibox_it.sql
           sed -i "s/'[0-9]\+\.[0-9]\+\.[0-9]\+'/'`echo $VERSION`-i386'/" ../01_src/01_xampp/cultibox/opt/lampp/sql_install/cultibox_es.sql

           sed -i "s/Version: .*/Version: `echo $VERSION`-ubuntu/g" ../01_src/01_xampp/cultibox/DEBIAN/control
           sed -i "s/Version=.*/Version=`echo $VERSION`/g" ../01_src/01_xampp/cultibox/usr/share/applications/cultibox.desktop

           find ./../01_src/01_xampp/cultibox/opt/lampp -name ".svn"|xargs rm -Rf
           mv ../01_src/01_xampp/cultibox/opt/lampp ../01_src/01_xampp/cultibox/opt/cultibox
           cd ./../01_src/01_xampp/ && dpkg-deb --build cultibox

           if [ "$1" == "ubuntu32" ]; then
                mv cultibox.deb ../../03_linux/Output/cultibox-ubuntu-i386_`echo $VERSION`.deb
           else
                mv cultibox.deb ../../03_linux/Output/cultibox-admin-ubuntu-i386_`echo $VERSION`.deb
           fi
      ;;
      "clean")
            rm -Rf ../01_src/01_xampp/*
      ;;
      *)
            usage
      ;;
esac
