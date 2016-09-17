#!/usr/bin/python
# -*- coding: utf-8 -*-

# Envoi du contenu du repertoire local ftpLocalPath (Rep FTP local du Pi)
# au serveur FTP web



import glob
import ftplib
import os

ftpLocalPath = "/home/bulcky/FTP/files/upldReady/*.*"

host="ftp.greenbox-botanic.com"
user="SLF_GLH@pyagreen.com"
passw="_lepotager12_"


filesToUpld = []

fileToUpld = glob.glob(ftpLocalPath)

session = ftplib.FTP(host,user,passw)

for x in fileToUpld:
    print "STOR "+ os.path.basename(x)
    file = open(x,'rb')
    session.storbinary("STOR "+ os.path.basename(x), file)     
    file.close()                                    
    os.system("rm %s"%(x))


                 
print "session quit"
session.quit()

