#!/bin/bash

set -e 
dir=`dirname $0`
cd $dir

function usage {
            echo "usage: $0"
            echo "                      bulckypi    <version>|version ?jenkins?"
            echo "                      bulckyface  <version>|version ?jenkins?"
            echo "                      bulckyraz   <version>|version ?jenkins?"
            echo "                      bulckytime  <version>|version ?jenkins?"
            echo "                      bulckyconf  <version>|version ?jenkins?"
            echo "                      bulckydoc   <version>|version ?jenkins?"
            echo "                      bulckycam   <version>|version ?jenkins?"
            echo "                      apt-gen"
            echo "                      clean"
            exit 1
}


#Print usage informations if a parameter is missing
if [ "$2" == "" ] && [ "$1" != "clean" ] && [ "$1" != "apt-gen" ]; then
    usage
fi

if [ "$2" == "version" ]; then
    if [ "$1" == "bulckypi" ]; then
        VERSION=`cat ../../../02_bulcky_services/01_bulckyPi/VERSION`
    elif [ "$1" == "bulckyface" ] || [ "$1" == "bulckydoc" ]; then
        VERSION=`cat ../../02_src/VERSION`
    elif [ "$1" == "bulckyraz" ]; then
        VERSION=`cat ../../../02_bulcky_services/05_bulckyRAZ/VERSION`
    elif [ "$1" == "bulckytime" ]; then
        VERSION=`cat ../../../02_bulcky_services/07_bulckyTime/VERSION`
    elif [ "$1" == "bulckyconf" ]; then
        VERSION=`cat ../../../02_bulcky_services/02_bulckyConf/VERSION`
    elif [ "$1" == "bulckycam" ]; then
        VERSION=`cat ../../../02_bulcky_service/09_bulckyCam/VERSION`
    fi
else
    VERSION=$2
fi


# Remove git pull when using jenkins
if [ "$3" == "up" ]; then
    (cd ../../../ && git pull && cd 01_software/02_src/bulcky/main/bulcky.wiki/ && git pull && cd ../../../02_bulcky_services/01_bulckyPi/ && git pull)
fi

revision=`date +%y%m%d%H%M`

case "$1" in
      "bulckypi")
	   debug="$3"
           if [ -d /tmp/bulcky ]; then
               rm -Rf /tmp/bulcky/*
           fi
           mkdir -p /tmp/bulcky/bulckypi
           cp -R ./conf-package/DEBIAN-bulckypi /tmp/bulcky/bulckypi/DEBIAN

           mkdir -p /tmp/bulcky/bulckypi/opt/bulckypi
           mkdir -p /tmp/bulcky/bulckypi/etc/init.d
           mkdir -p /tmp/bulcky/bulckypi/etc/bulckypi

           cp -R ../../../02_bulcky_services/01_bulckyPi/* /tmp/bulcky/bulckypi/opt/bulckypi/
           rm -f /tmp/bulcky/bulckypi/opt/bulckypi/VERSION
           cp -R ../../../02_bulcky_services/01_bulckyPi/_conf/01_defaultConf_RPi /tmp/bulcky/bulckypi/etc/bulckypi/

           cp -R ../../../02_bulcky_services/01_bulckyPi/_conf/01_defaultConf_RPi  /tmp/bulcky/bulckypi/etc/bulckypi/
           cp -R ../../../02_bulcky_services/01_bulckyPi/_conf/conf.xml  /tmp/bulcky/bulckypi/etc/bulckypi/

           cp ../../../02_bulcky_services/04_bulckypi_service/etc/init.d/bulckypi /tmp/bulcky/bulckypi/etc/init.d/bulckypi

           sed -i "s/Version: .*/Version: `echo $VERSION`-r`echo $revision`/g" /tmp/bulcky/bulckypi/DEBIAN/control
           find /tmp/bulcky/ -name ".git*"|xargs rm -Rf 
	
	   if [ "$debug" ==  "true" ]; then
                sed -i "3i\set -x" /tmp/bulcky/bulckypi/DEBIAN/postinst
                sed -i "3i\set -x" /tmp/bulcky/bulckypi/DEBIAN/postrm
                sed -i "3i\set -x" /tmp/bulcky/bulckypi/DEBIAN/preinst
                sed -i "3i\set -x" /tmp/bulcky/bulckypi/DEBIAN/prerm
           fi
           cd /tmp/bulcky/ && dpkg-deb --build bulckypi
           mv bulckypi.deb /var/lib/jenkins/workspace/bulcky_createPackage/01_software/01_install/02_bulcky/Output/bulckypi-armhf_`echo $VERSION`-r`echo $revision`.deb
      ;;
      "bulckyface")
	       debug="$3"

           if [ -d /tmp/bulcky ]; then
               rm -Rf /tmp/bulcky/*
           fi

           mkdir -p /tmp/bulcky/bulckyface/var/www
           cp -R ./conf-package/DEBIAN-bulckyface /tmp/bulcky/bulckyface/DEBIAN

           cp -R ../../02_src/bulcky /tmp/bulcky/bulckyface/var/www/bulcky
		   cp -R ../../02_src/mobile /tmp/bulcky/bulckyface/var/www/mobile
           rm -Rf /tmp/bulcky/bulckyface/var/www/bulcky/main/bulcky.wiki

           cp conf-package/lgpl3.txt /tmp/bulcky/bulckyface/var/www/bulcky/LICENSE
           mkdir -p /tmp/bulcky/bulckyface/var/www/bulcky/sql_install
           cp ../01_sql/*.sql /tmp/bulcky/bulckyface/var/www/bulcky/sql_install/

           cat > /tmp/bulcky/bulckyface/var/www/bulcky/sql_install/my-extra.cnf << "EOF" 
[client]
user="root"
password="bulcky"
EOF
           sed -i "s/\`VERSION\` = '.*/\`VERSION\` = '`echo $VERSION`-r`echo $revision`' WHERE \`configuration\`.\`id\` =1;/" /tmp/bulcky/bulckyface/var/www/bulcky/sql_install/update_sql.sql

           #replacement of the old version number by the new one in VERSION file
           sed -i "s/'[0-9]\+\.[0-9]\+\.[0-9]\+'/'`echo $VERSION`-r`echo $revision`'/" /tmp/bulcky/bulckyface/var/www/bulcky/sql_install/bulcky_fr.sql

           sed -i "s/Version: .*/Version: `echo $VERSION`-r`echo $revision`/g" /tmp/bulcky/bulckyface/DEBIAN/control
           sed -i "s/'[0-9]\+\.[0-9]\+\.[0-9][0-9]\+'/'`echo $VERSION`-r`echo $revision`'/" /tmp/bulcky/bulckyface/var/www/bulcky/main/libs/lib_configuration.php
           sed -i "s/^$GLOBALS.*\"cultibox\"/\$GLOBALS['MODE']=\"cultipi\"/g" /tmp/bulcky/bulckyface/var/www/bulcky/main/libs/config.php 

           find /tmp/bulcky/bulckyface/ -name ".git*"|xargs rm -Rf

           if [ "$debug" ==  "true" ]; then
                sed -i "3i\set -x" /tmp/bulcky/bulckyface/DEBIAN/postinst
                sed -i "3i\set -x" /tmp/bulcky/bulckyface/DEBIAN/postrm
                sed -i "3i\set -x" /tmp/bulcky/bulckyface/DEBIAN/preinst
                sed -i "3i\set -x" /tmp/bulcky/bulckyface/DEBIAN/prerm
           fi

           cd /tmp/bulcky/ && dpkg-deb --build bulckyface

           mv bulckyface.deb /var/lib/jenkins/workspace/bulcky_createPackage/01_software/01_install/02_bulcky/Output/bulckyface-armhf_`echo $VERSION`-r`echo $revision`.deb
      ;;  
      "cultiraz")
	   debug="$3"

           if [ -d /tmp/bulcky ]; then
            rm -Rf /tmp/bulcky/*
           fi
           mkdir -p /tmp/bulcky/cultiraz
           cp -R ./conf-package/DEBIAN-cultiraz /tmp/bulcky/cultiraz/DEBIAN

           mkdir -p /tmp/bulcky/cultiraz/opt/cultiraz
           mkdir -p /tmp/bulcky/cultiraz/etc/init.d

           cp -R ../../../04_CultiPi/01_Software/05_cultiRAZ/* /tmp/bulcky/cultiraz/opt/cultiraz/
           rm -f /tmp/bulcky/cultiraz/opt/cultiraz/VERSION

           cp ../../../04_CultiPi/01_Software/06_cultiRAZ_service/etc/init.d/cultiraz /tmp/bulcky/cultiraz/etc/init.d/cultiraz

           sed -i "s/Version: .*/Version: `echo $VERSION`-r`echo $revision`/g" /tmp/bulcky/cultiraz/DEBIAN/control
           find .//tmp/bulcky/cultiraz/ -name ".git*"|xargs rm -Rf
	
           if [ "$debug" ==  "true" ]; then
                sed -i "3i\set -x" /tmp/bulcky/cultiraz/DEBIAN/postinst
                sed -i "3i\set -x" /tmp/bulcky/cultiraz/DEBIAN/postrm
                sed -i "3i\set -x" /tmp/bulcky/cultiraz/DEBIAN/preinst
                sed -i "3i\set -x" /tmp/bulcky/cultiraz/DEBIAN/prerm
           fi

           cd .//tmp/bulcky/ && dpkg-deb --build cultiraz
           mv cultiraz.deb ../../05_cultipi/Output/cultiraz-armhf_`echo $VERSION`-r`echo $revision`.deb
      ;;
      "cultitime")
	   debug="$3"

           if [ -d /tmp/bulcky ]; then
            rm -Rf /tmp/bulcky/*
           fi
           mkdir -p /tmp/bulcky/cultitime
           cp -R ./conf-package/DEBIAN-cultitime /tmp/bulcky/cultitime/DEBIAN

           mkdir -p /tmp/bulcky/cultitime/opt/cultitime
           mkdir -p /tmp/bulcky/cultitime/etc/init.d

           cp -R ../../../04_CultiPi/01_Software/07_cultiTime/* /tmp/bulcky/cultitime/opt/cultitime/
           rm -f /tmp/bulcky/cultitime/opt/cultitime/VERSION

           cp ../../../04_CultiPi/01_Software/08_cultiTime_service/etc/init.d/cultitime /tmp/bulcky/cultitime/etc/init.d/cultitime

           sed -i "s/Version: .*/Version: `echo $VERSION`-r`echo $revision`/g" /tmp/bulcky/cultitime/DEBIAN/control
           find .//tmp/bulcky/cultitime/ -name ".git*"|xargs rm -Rf

           if [ "$debug" ==  "true" ]; then
                sed -i "3i\set -x" /tmp/bulcky/cultitime/DEBIAN/postinst
                sed -i "3i\set -x" /tmp/bulcky/cultitime/DEBIAN/postrm
                sed -i "3i\set -x" /tmp/bulcky/cultitime/DEBIAN/preinst
                sed -i "3i\set -x" /tmp/bulcky/cultitime/DEBIAN/prerm
           fi

           cd .//tmp/bulcky/ && dpkg-deb --build cultitime

           mv cultitime.deb ../../05_cultipi/Output/cultitime-armhf_`echo $VERSION`-r`echo $revision`.deb
      ;;
      "culticonf")
	   debug="$3"

           if [ -d /tmp/bulcky ]; then
            rm -Rf /tmp/bulcky/*
           fi
           mkdir -p /tmp/bulcky/culticonf
           mkdir -p /tmp/bulcky/culticonf/etc/cron.daily
           mkdir -p /tmp/bulcky/culticonf/etc/cron.hourly
           mkdir -p /tmp/bulcky/culticonf/etc/logrotate.d
           mkdir -p /tmp/bulcky/culticonf/etc/default
           mkdir -p /tmp/bulcky/culticonf/etc/culticonf
           mkdir -p /tmp/bulcky/culticonf/root
           mkdir -p /tmp/bulcky/culticonf/home/cultipi

           cp -R ./conf-package/DEBIAN-culticonf /tmp/bulcky/culticonf/DEBIAN
           cp -R ../../../04_CultiPi/01_Software/02_cultiConf/usr /tmp/bulcky/culticonf/

           cp ../../../04_CultiPi/01_Software/02_cultiConf/etc/logrotate.d/cultipi /tmp/bulcky/culticonf/etc/logrotate.d/
           cp ../../../04_CultiPi/01_Software/02_cultiConf/etc/cron.daily/cultipi /tmp/bulcky/culticonf/etc/cron.daily/ 
           cp ../../../04_CultiPi/01_Software/02_cultiConf/etc/cron.hourly/cultipi /tmp/bulcky/culticonf/etc/cron.hourly/
           cp ../../../04_CultiPi/01_Software/02_cultiConf/etc/default/culticron /tmp/bulcky/culticonf/etc/default/
           cp ../../../04_CultiPi/01_Software/02_cultiConf/root/.bash_aliases /tmp/bulcky/culticonf/root/
           cp ../../../04_CultiPi/01_Software/02_cultiConf/home/cultipi/.bash_aliases /tmp/bulcky/culticonf/home/cultipi/
           cp -R ../../../04_CultiPi/01_Software/02_cultiConf/etc/culticonf/* /tmp/bulcky/culticonf/etc/culticonf/

           sed -i "s/Version: .*/Version: `echo $VERSION`-r`echo $revision`/g" /tmp/bulcky/culticonf/DEBIAN/control
           find .//tmp/bulcky/culticonf/ -name ".git*"|xargs rm -Rf

           if [ "$debug" ==  "true" ]; then
                sed -i "3i\set -x" /tmp/bulcky/culticonf/DEBIAN/postinst
                sed -i "3i\set -x" /tmp/bulcky/culticonf/DEBIAN/postrm
                sed -i "3i\set -x" /tmp/bulcky/culticonf/DEBIAN/preinst
                sed -i "3i\set -x" /tmp/bulcky/culticonf/DEBIAN/prerm
           fi

           cd .//tmp/bulcky/ && dpkg-deb --build culticonf

           mv culticonf.deb ../../05_cultipi/Output/culticonf-armhf_`echo $VERSION`-r`echo $revision`.deb
      ;;
      "cultidoc")
	   debug="$3"

           if [ -d /tmp/bulcky ]; then
            rm -Rf /tmp/bulcky/*
           fi
           mkdir -p /tmp/bulcky/cultidoc
           mkdir -p /tmp/bulcky/cultidoc/var/www/cultibox/main

           cp -R ./conf-package/DEBIAN-cultidoc /tmp/bulcky/cultidoc/DEBIAN
           cp -R ../../02_src/cultibox/main/cultibox.wiki /tmp/bulcky/cultidoc/var/www/cultibox/main/

           sed -i "s/Version: .*/Version: `echo $VERSION`-r`echo $revision`/g" /tmp/bulcky/cultidoc/DEBIAN/control
           find .//tmp/bulcky/cultidoc/ -name ".git*"|xargs rm -Rf

           if [ "$debug" ==  "true" ]; then
                sed -i "3i\set -x" /tmp/bulcky/cultidoc/DEBIAN/postinst
                sed -i "3i\set -x" /tmp/bulcky/cultidoc/DEBIAN/postrm
                sed -i "3i\set -x" /tmp/bulcky/cultidoc/DEBIAN/preinst
                sed -i "3i\set -x" /tmp/bulcky/cultidoc/DEBIAN/prerm
           fi

           cd .//tmp/bulcky/ && dpkg-deb --build cultidoc

           mv cultidoc.deb ../../05_cultipi/Output/cultidoc-armhf_`echo $VERSION`-r`echo $revision`.deb
      ;;
      "culticam")
	  debug="$3"

           if [ -d /tmp/bulcky ]; then
            rm -Rf /tmp/bulcky/*
           fi
           mkdir -p /tmp/bulcky/culticam
           cp -R ./conf-package/DEBIAN-culticam /tmp/bulcky/culticam/DEBIAN

           mkdir -p /tmp/bulcky/culticam/opt/culticam

           cp -R ../../../04_CultiPi/01_Software/09_cultiCam/* /tmp/bulcky/culticam/opt/culticam/
           rm -f /tmp/bulcky/culticam/opt/culticam/VERSION
           cp -R ../../../04_CultiPi/01_Software/10_cultiCam_service/* /tmp/bulcky/culticam/

           sed -i "s/Version: .*/Version: `echo $VERSION`-r`echo $revision`/g" /tmp/bulcky/culticam/DEBIAN/control
           find .//tmp/bulcky/culticam/ -name ".git*"|xargs rm -Rf

           if [ "$debug" ==  "true" ]; then
                sed -i "3i\set -x" /tmp/bulcky/culticam/DEBIAN/postinst
                sed -i "3i\set -x" /tmp/bulcky/culticam/DEBIAN/postrm
                sed -i "3i\set -x" /tmp/bulcky/culticam/DEBIAN/preinst
                sed -i "3i\set -x" /tmp/bulcky/culticam/DEBIAN/prerm
           fi

           cd .//tmp/bulcky/ && dpkg-deb --build culticam

           mv culticam.deb ../../05_cultipi/Output/culticam-armhf_`echo $VERSION`-r`echo $revision`.deb
      ;;
      "apt-gen")
           cultipi="`ls -t Output/cultipi*|head -1`"
           cp $cultipi repository/binary/
          
           cultibox="`ls -t Output/cultibox*|head -1`"
           cp $cultibox repository/binary/

           cultiraz="`ls -t Output/cultiraz*|head -1`"
           cp $cultiraz repository/binary/

           cultitime="`ls -t Output/cultitime*|head -1`"
           cp $cultitime repository/binary/

           culticonf="`ls -t Output/culticonf*|head -1`"
           cp $culticonf repository/binary/

           cultidoc="`ls -t Output/cultidoc*|head -1`"
           cp $cultidoc repository/binary/

           culticam="`ls -t Output/culticam*|head -1`"
           cp $culticam repository/binary/

           cd repository
           dpkg-scanpackages binary /dev/null | gzip -9c > binary/Packages.gz

           rm binary/culti*.deb
      ;;
      "clean")
           if [ -d /tmp/bulcky ]; then
            rm -Rf /tmp/bulcky/*
           fi
      ;;
      *)
            usage
      ;;
esac
