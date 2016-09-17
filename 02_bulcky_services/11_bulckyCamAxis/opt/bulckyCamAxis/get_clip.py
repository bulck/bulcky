#!/usr/bin/python
# -*- coding: utf-8 -*-

# get_clip.py ipAddr S
# Permet l'acquisition d'un clip de S secondes sur la camera definie par ipAddr
# La camera depose le clip video sur le serveur FTP du Pi

import sys
import requests
import time
from requests.auth import HTTPDigestAuth

user="root"
passw="_bulck38_"

if len(sys.argv) > 2:

    print "Get a %i secondes clip from camera %s  " %(int(sys.argv[2]) ,sys.argv[1])

    url = "http://%s/axis-cgi/virtualinput/activate.cgi?schemaversion=1&port=2" %sys.argv[1]
    r=requests.get(url, auth=HTTPDigestAuth(user, passw))
    print r.text

    time.sleep(int(sys.argv[2]))

    url = "http://%s/axis-cgi/virtualinput/deactivate.cgi?schemaversion=1&port=2" %sys.argv[1]
    r=requests.get(url, auth=HTTPDigestAuth(user, passw))
    print r.text

    print "Ok"
else:

    print "Passer l'adresse de la camera +  duree en seconde en arguments"

