#!/usr/bin/python
# -*- coding: utf-8 -*-

"""
    Envoi du contenu du repertoire local ftpLocalPath (Rep FTP local du Pi) au serveur FTP web

    python /opt/bulckyCamAxis/cloud_send.py -f FTPHOST -u USERNAME -p PASSWORD
    
"""


import glob
import ftplib
import os
from optparse import OptionParser

def main():
    # On cré le parser pour les parametres en entrée
    usage = "usage: %prog [options]"
    parser = OptionParser(usage=usage)

    parser.add_option("-f", "--ftphost", dest="ftphost",
                      action="store", type="string",
                      help="Adresse IP de la caméra")
    parser.add_option("-u", "--user", dest="user",
                      action="store", type="string",
                      help="Adresse IP de la caméra")
    parser.add_option("-p", "--password", dest="passw",
                      action="store", type="string",
                      help="Adresse IP de la caméra")

    (options, args) = parser.parse_args()

    ftpLocalPath = "/home/bulcky/FTP/files/upldReady/*.*"
    
    # Filename paramater must be provided
    if not options.ftphost :
        parser.error("options -f or --ftphost is mandatory")
    if not options.user :
        parser.error("options -u or --user is mandatory")
    if not options.passw :
        parser.error("options -p or --password is mandatory")

    filesToUpld = []

    fileToUpld = glob.glob(ftpLocalPath)

    for x in fileToUpld:
        print "Envoi " +  x + "vers FTP " + os.path.basename(x)
        os.system("curl -u " + options.user + ":" + options.passw + " -T " + x + " ftp://" + options.ftphost + "/002/" + os.path.basename(x))
        print "suppression fichier"
        os.system("rm " + x)

    print "session quit"
    session.quit()

if __name__ == '__main__':
    main()