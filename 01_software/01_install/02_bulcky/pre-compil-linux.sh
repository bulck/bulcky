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
        VERSION=`cat ../../../02_bulcky_services/09_bulckyCam/VERSION`
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

           #replacement of the old version number by the new one in VERSION file
           sed -i "s/'[0-9]\+\.[0-9]\+\.[0-9]\+'/'`echo $VERSION`-r`echo $revision`'/" /tmp/bulcky/bulckyface/var/www/bulcky/sql_install/bulcky_fr.sql

           sed -i "s/Version: .*/Version: `echo $VERSION`-r`echo $revision`/g" /tmp/bulcky/bulckyface/DEBIAN/control
           sed -i "s/'[0-9]\+\.[0-9]\+\.[0-9][0-9]\+'/'`echo $VERSION`-r`echo $revision`'/" /tmp/bulcky/bulckyface/var/www/bulcky/main/libs/lib_configuration.php

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
      "bulckyraz")
	       debug="$3"

           if [ -d /tmp/bulcky ]; then
               rm -Rf /tmp/bulcky/*
           fi

           mkdir -p /tmp/bulcky/bulckyraz
           cp -R ./conf-package/DEBIAN-bulckyraz /tmp/bulcky/bulckyraz/DEBIAN

           mkdir -p /tmp/bulcky/bulckyraz/opt/bulckyraz
           mkdir -p /tmp/bulcky/bulckyraz/etc/init.d

           cp -R ../../../02_bulcky_services/05_bulckyRAZ/* /tmp/bulcky/bulckyraz/opt/bulckyraz/
           rm -f /tmp/bulcky/bulckyraz/opt/bulckyraz/VERSION

           cp ../../../02_bulcky_services/06_bulckyRAZ_service/etc/init.d/bulckyraz /tmp/bulcky/bulckyraz/etc/init.d/bulckyraz

           sed -i "s/Version: .*/Version: `echo $VERSION`-r`echo $revision`/g" /tmp/bulcky/bulckyraz/DEBIAN/control
           find /tmp/bulcky/bulckyraz/ -name ".git*"|xargs rm -Rf
	
           if [ "$debug" ==  "true" ]; then
                sed -i "3i\set -x" /tmp/bulcky/bulckyraz/DEBIAN/postinst
                sed -i "3i\set -x" /tmp/bulcky/bulckyraz/DEBIAN/postrm
                sed -i "3i\set -x" /tmp/bulcky/bulckyraz/DEBIAN/preinst
                sed -i "3i\set -x" /tmp/bulcky/bulckyraz/DEBIAN/prerm
           fi

           cd /tmp/bulcky/ && dpkg-deb --build bulckyraz
           mv bulckyraz.deb /var/lib/jenkins/workspace/bulcky_createPackage/01_software/01_install/02_bulcky/Output/bulckyraz-armhf_`echo $VERSION`-r`echo $revision`.deb
      ;;
      "bulckytime")
	   debug="$3"

           if [ -d /tmp/bulcky ]; then
            rm -Rf /tmp/bulcky/*
           fi
           mkdir -p /tmp/bulcky/bulckytime
           cp -R ./conf-package/DEBIAN-bulckytime /tmp/bulcky/bulckytime/DEBIAN

           mkdir -p /tmp/bulcky/bulckytime/opt/bulckytime
           mkdir -p /tmp/bulcky/bulckytime/etc/init.d

           cp -R ../../../02_bulcky_services/07_bulckyTime/* /tmp/bulcky/bulckytime/opt/bulckytime/
           rm -f /tmp/bulcky/bulckytime/opt/bulckytime/VERSION

           cp ../../../02_bulcky_services/08_bulckyTime_service/etc/init.d/bulckytime /tmp/bulcky/bulckytime/etc/init.d/bulckytime

           sed -i "s/Version: .*/Version: `echo $VERSION`-r`echo $revision`/g" /tmp/bulcky/bulckytime/DEBIAN/control
           find /tmp/bulcky/bulckytime/ -name ".git*"|xargs rm -Rf

           if [ "$debug" ==  "true" ]; then
                sed -i "3i\set -x" /tmp/bulcky/bulckytime/DEBIAN/postinst
                sed -i "3i\set -x" /tmp/bulcky/bulckytime/DEBIAN/postrm
                sed -i "3i\set -x" /tmp/bulcky/bulckytime/DEBIAN/preinst
                sed -i "3i\set -x" /tmp/bulcky/bulckytime/DEBIAN/prerm
           fi

           cd /tmp/bulcky/ && dpkg-deb --build bulckytime

           mv bulckytime.deb /var/lib/jenkins/workspace/bulcky_createPackage/01_software/01_install/02_bulcky/Output/bulckytime-armhf_`echo $VERSION`-r`echo $revision`.deb
      ;;
      "bulckyconf")
	   debug="$3"

           if [ -d /tmp/bulcky ]; then
            rm -Rf /tmp/bulcky/*
           fi
           mkdir -p /tmp/bulcky/bulckyconf
           mkdir -p /tmp/bulcky/bulckyconf/etc/cron.daily
           mkdir -p /tmp/bulcky/bulckyconf/etc/cron.hourly
           mkdir -p /tmp/bulcky/bulckyconf/etc/logrotate.d
           mkdir -p /tmp/bulcky/bulckyconf/etc/default
           mkdir -p /tmp/bulcky/bulckyconf/etc/bulckyconf
           mkdir -p /tmp/bulcky/bulckyconf/root
           mkdir -p /tmp/bulcky/bulckyconf/home/bulcky

           cp -R ./conf-package/DEBIAN-bulckyconf /tmp/bulcky/bulckyconf/DEBIAN
           cp -R ../../../02_bulcky_services/02_bulckyConf/usr /tmp/bulcky/bulckyconf/

           cp ../../../02_bulcky_services/02_bulckyConf/etc/logrotate.d/bulcky /tmp/bulcky/bulckyconf/etc/logrotate.d/
           cp ../../../02_bulcky_services/02_bulckyConf/etc/cron.daily/bulcky /tmp/bulcky/bulckyconf/etc/cron.daily/ 
           cp ../../../02_bulcky_services/02_bulckyConf/etc/cron.hourly/bulcky /tmp/bulcky/bulckyconf/etc/cron.hourly/
           cp ../../../04_CultiPi/01_Software/02_bulckyConf/etc/default/bulckycron /tmp/bulcky/bulckyconf/etc/default/
           cp ../../../04_CultiPi/01_Software/02_bulckyConf/root/.bash_aliases /tmp/bulcky/bulckyconf/root/
           cp ../../../04_CultiPi/01_Software/02_bulckyConf/home/bulcky/.bash_aliases /tmp/bulcky/bulckyconf/home/bulcky/
           cp -R ../../../02_bulcky_services/02_bulckyConf/etc/bulckyconf/* /tmp/bulcky/bulckyconf/etc/bulckyconf/

           sed -i "s/Version: .*/Version: `echo $VERSION`-r`echo $revision`/g" /tmp/bulcky/bulckyconf/DEBIAN/control
           find /tmp/bulcky/bulckyconf/ -name ".git*"|xargs rm -Rf

           if [ "$debug" ==  "true" ]; then
                sed -i "3i\set -x" /tmp/bulcky/bulckyconf/DEBIAN/postinst
                sed -i "3i\set -x" /tmp/bulcky/bulckyconf/DEBIAN/postrm
                sed -i "3i\set -x" /tmp/bulcky/bulckyconf/DEBIAN/preinst
                sed -i "3i\set -x" /tmp/bulcky/bulckyconf/DEBIAN/prerm
           fi

           cd /tmp/bulcky/ && dpkg-deb --build bulckyconf

           mv bulckyconf.deb /var/lib/jenkins/workspace/bulcky_createPackage/01_software/01_install/02_bulcky/Output/bulckyconf-armhf_`echo $VERSION`-r`echo $revision`.deb
      ;;
      "bulckydoc")
	   debug="$3"

           if [ -d /tmp/bulcky ]; then
            rm -Rf /tmp/bulcky/*
           fi
           mkdir -p /tmp/bulcky/bulckydoc
           mkdir -p /tmp/bulcky/bulckydoc/var/www/bulcky/main

           cp -R ./conf-package/DEBIAN-bulckydoc /tmp/bulcky/bulckydoc/DEBIAN
           cp -R ../../02_src/bulcky/main/bulcky.wiki /tmp/bulcky/bulckydoc/var/www/bulcky/main/

           sed -i "s/Version: .*/Version: `echo $VERSION`-r`echo $revision`/g" /tmp/bulcky/bulckydoc/DEBIAN/control
           find /tmp/bulcky/bulckydoc/ -name ".git*"|xargs rm -Rf

           if [ "$debug" ==  "true" ]; then
                sed -i "3i\set -x" /tmp/bulcky/bulckydoc/DEBIAN/postinst
                sed -i "3i\set -x" /tmp/bulcky/bulckydoc/DEBIAN/postrm
                sed -i "3i\set -x" /tmp/bulcky/bulckydoc/DEBIAN/preinst
                sed -i "3i\set -x" /tmp/bulcky/bulckydoc/DEBIAN/prerm
           fi

           cd /tmp/bulcky/ && dpkg-deb --build bulckydoc

           mv bulckydoc.deb /var/lib/jenkins/workspace/bulcky_createPackage/01_software/01_install/02_bulcky/Output/bulckydoc-armhf_`echo $VERSION`-r`echo $revision`.deb
      ;;
      "bulckycam")
	       debug="$3"

           if [ -d /tmp/bulcky ]; then
            rm -Rf /tmp/bulcky/*
           fi

           mkdir -p /tmp/bulcky/bulckycam
           cp -R ./conf-package/DEBIAN-bulckycam /tmp/bulcky/bulckycam/DEBIAN

           mkdir -p /tmp/bulcky/bulckycam/opt/bulckycam

           cp -R ../../../02_bulcky_services/09_bulckyCam/* /tmp/bulcky/bulckycam/opt/bulckycam/
           rm -f /tmp/bulcky/bulckycam/opt/bulckycam/VERSION
           cp -R ../../../02_bulcky_services/10_bulckyCam_service/* /tmp/bulcky/bulckycam/

           sed -i "s/Version: .*/Version: `echo $VERSION`-r`echo $revision`/g" /tmp/bulcky/bulckycam/DEBIAN/control
           find /tmp/bulcky/bulckycam/ -name ".git*"|xargs rm -Rf

           if [ "$debug" ==  "true" ]; then
                sed -i "3i\set -x" /tmp/bulcky/bulckycam/DEBIAN/postinst
                sed -i "3i\set -x" /tmp/bulcky/bulckycam/DEBIAN/postrm
                sed -i "3i\set -x" /tmp/bulcky/bulckycam/DEBIAN/preinst
                sed -i "3i\set -x" /tmp/bulcky/bulckycam/DEBIAN/prerm
           fi

           cd /tmp/bulcky/ && dpkg-deb --build bulckycam

           mv bulckycam.deb /var/lib/jenkins/workspace/bulcky_createPackage/01_software/01_install/02_bulcky/Output/bulckycam-armhf_`echo $VERSION`-r`echo $revision`.deb
      ;;
      "apt-gen")
           bulckypi="`ls -t Output/bulckypi*|head -1`"
           cp $bulckypi repository/binary/
          
           bulckyface="`ls -t Output/*|head -1`"
           cp $bulckyface repository/binary/

           bulckyraz="`ls -t Output/bulckyraz*|head -1`"
           cp $bulckyraz repository/binary/

           bulckytime="`ls -t Output/bulckytime*|head -1`"
           cp $bulckytime repository/binary/

           bulckyconf="`ls -t Output/bulckyconf*|head -1`"
           cp $bulckyconf repository/binary/

           bulckydoc="`ls -t Output/bulckydoc*|head -1`"
           cp $bulckydoc repository/binary/

           bulckycam="`ls -t Output/bulckycam*|head -1`"
           cp $bulckycam repository/binary/

           cd repository
           dpkg-scanpackages binary /dev/null | gzip -9c > binary/Packages.gz

           rm binary/bulcky*.deb
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
