#!/usr/bin/python

# get_img.py ipAddr 
# Permet l'acquisition d'une image sur la camera définie par ipAddr
# La camera dépose l'image sur le serveur FTP du Pi pour construction du timelapse

import sys
import requests
import time
from requests.auth import HTTPDigestAuth

user="root"
passw="_bulck38_"

if len(sys.argv) > 1:

	print "Get one image from camera %s  " %sys.argv[1]

	url = "http://%s/axis-cgi/virtualinput/activate.cgi?schemaversion=1&port=1" %sys.argv[1]
	r=requests.get(url, auth=HTTPDigestAuth(user, passw))
	print r.text

	time.sleep(2)

	url = "http://%s/axis-cgi/virtualinput/deactivate.cgi?schemaversion=1&port=1" %sys.argv[1]
	r=requests.get(url, auth=HTTPDigestAuth(user, passw))
	print r.text

	print "Ok"
else:

	print "Passer l'adresse de la camera en argument"



