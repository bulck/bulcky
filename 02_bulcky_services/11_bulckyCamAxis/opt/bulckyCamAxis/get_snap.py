#!/usr/bin/python
# -*- coding: utf-8 -*-

# get_snap.py ipAddr 
# Permet l'acquisition d'une image sur la camera definie par ipAddr
# La camera depose l'image sur le serveur FTP du Pi pour upload direct
# sur le web FTP (l'image ne sert pas a la construction d'un timelapse)

import sys
import requests
import time
from requests.auth import HTTPDigestAuth

user="root"
passw="_bulck38_"

if len(sys.argv) > 1:

    print "Get one snapshot from camera %s  " %sys.argv[1]

    url = "http://%s/axis-cgi/virtualinput/activate.cgi?schemaversion=1&port=3" %sys.argv[1]
    r=requests.get(url, auth=HTTPDigestAuth(user, passw))
    print r.text

    time.sleep(2)

    url = "http://%s/axis-cgi/virtualinput/deactivate.cgi?schemaversion=1&port=3" %sys.argv[1]
    r=requests.get(url, auth=HTTPDigestAuth(user, passw))
    print r.text

    print "Ok"
else:

    print "Passer l'adresse de la camera en argument"
