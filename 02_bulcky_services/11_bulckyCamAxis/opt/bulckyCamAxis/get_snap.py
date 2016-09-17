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

    (options, args) = parser.parse_args()
    
    # On vérifie les arguments qui doivent être transmit
    if not options.ip :
        parser.error("options -i or --ip is mandatory")
    if not options.user :
        parser.error("options -u or --user is mandatory")
    if not options.passw :
        parser.error("options -p or --password is mandatory")

    print "Get one snapshot from camera " + options.ip

    url = "http://" + options.ip + "/axis-cgi/virtualinput/activate.cgi?schemaversion=1&port=3"
    r=requests.get(url, auth=HTTPDigestAuth(options.user, options.passw))
    print r.text

    time.sleep(2)

    url = "http://" + options.ip + "/axis-cgi/virtualinput/deactivate.cgi?schemaversion=1&port=3" 
    r=requests.get(url, auth=HTTPDigestAuth(options.user, options.passw))
    print r.text

        
if __name__ == '__main__':
    main()