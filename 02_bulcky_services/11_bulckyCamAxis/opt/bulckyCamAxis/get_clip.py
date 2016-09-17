#!/usr/bin/python
# -*- coding: utf-8 -*-

# get_clip.py ipAddr S
# Permet l'acquisition d'un clip de S secondes sur la camera definie par ipAddr
# La camera depose le clip video sur le serveur FTP du Pi

import sys
import requests
import time
from requests.auth import HTTPDigestAuth
from optparse import OptionParser

def main():
    # On cré le parser pour les parametres en entrée
    usage = "usage: %prog [options]"
    parser = OptionParser(usage=usage)

    parser.add_option("-i", "--ip", dest="ip",
                      action="store", type="string",
                      help="Adresse IP de la caméra")
    parser.add_option("-u", "--user", dest="user",
                      action="store", type="string",
                      help="Nom d'utilisateur")
    parser.add_option("-p", "--password", dest="passw",
                      action="store", type="string",
                      help="Mot de passe")
    parser.add_option("-t", "--temps", dest="passw",
                      action="store", type="string",
                      help="Temps d'acquisition")

    (options, args) = parser.parse_args()
    
    # On vérifie les arguments qui doivent être transmit
    if not options.ip :
        parser.error("options -i or --ip is mandatory")
    if not options.user :
        parser.error("options -u or --user is mandatory")
    if not options.passw :
        parser.error("options -p or --password is mandatory")
    if not options.temps :
        parser.error("options -t or --temps is mandatory")
        
    print "Get a " + options.temps + " secondes clip from camera " + options.ip

    url = "http://" + options.ip + "/axis-cgi/virtualinput/activate.cgi?schemaversion=1&port=2"
    r=requests.get(url, auth=HTTPDigestAuth(options.user, options.passw))
    print r.text

    time.sleep(int(options.temps))

    url = "http://" + options.ip + "/axis-cgi/virtualinput/deactivate.cgi?schemaversion=1&port=2"
    r=requests.get(url, auth=HTTPDigestAuth(options.user, options.passw))
    print r.text

    print "Ok"

        
if __name__ == '__main__':
    main()