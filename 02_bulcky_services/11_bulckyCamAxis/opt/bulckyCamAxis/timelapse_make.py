#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
    Ce programme télécharge les fichiers présents sur un serveur FTP et les sauvegarde en local.
    Permet la fabrication d'un timelapse pour la camera definie par ipAddr
    a partir des images recuperees via get_img.py (pour cette camera)
    La sequence obtenue est laissee sur le FTP local pour futur upload via cloud_send.py
    
    python /opt/bulckyCamAxis/timelapse_make.py -d /home/bulcky/FTP/files/192.168.1.101_16-09-17/ -r
    
"""

# timelapse_make.py ipAddr 

# Les options d'avconv (utilisé pour faire la convertion) (https://libav.org/documentation/avconv.html)
# -r 10  : force le framerate a 10images par secondes
# -i %s%s.jpg : specifies the input file(s). %4d means any 4 decimal numbers
# -r 10 :  creates a clip with 10 frames per seconds
# -vcodec libx264 : -vcodec specifies the video codec to be used (H.264 in this case)
# -crf 20 : Entre 0 (lossless) et 51 . On utilise des valeurs en 18 et 28 : http://slhck.info/articles/crf
# -g 15 : set the group of picture (GOP) size 
# /home/bulcky/FTP/files/upldReady/%s.mp4"

# autres options 
# crop= specifies which area of the images will be cropped
# scale= indicates how much scaling must take place (in the above example iw:ih indicates that the output width and height will be that of the in width and in height)
# Pas besoin de scale car les images sont défà au format full HD

import glob
import os
from os import listdir, stat
from os.path import isfile, join
import sys
from optparse import OptionParser
import shutil

def main():
    # On crée le parser pour les parametres en entrée
    usage = "usage: %prog [options]"
    parser = OptionParser(usage=usage)

    parser.add_option("-r", "--remove", dest="remove",
                      action="store_true", default=False,
                      help="supprime les fichiers")
    parser.add_option("-d", "--directory", dest="directory",
                      action="store", type="string",
                      help="Adresse du dossier")

    (options, args) = parser.parse_args()

    # Le dossier doit être transmit
    if not options.directory :
        parser.error("options -d or --directory is mandatory")

    # On liste les dossiers présents 
    listFolder = [f for f in listdir(options.directory) if not isfile(join(options.directory, f))]
    
    # On eneleve deux dossiers
    if "save" in listFolder:
        listFolder.remove("save")
    if "upldReady" in listFolder:
        listFolder.remove("upldReady")

    # S'il y a un dossier
    if listFolder:
        
        for folderI in listFolder:
        
            directoyrName = options.directory + "/" + folderI + "/"
            directoyrNameSansSlash = options.directory + "/" + folderI
        
            # On lance la création de la vidéo
            fileBaseName = os.path.basename(os.path.normpath(directoyrName))
            
            # Exemple avconv -r 10 -i 192.168.1.100-%5d.jpg -vcodec libx264 -crf 28 -g 15 192.168.1.100.mp4
            # -b 1024k -g 15
            cmd = "avconv -r 10 -i " + directoyrName + "%5d.jpg -r 10 -vcodec libx264 -b 2048k -g 15 /home/bulcky/FTP/files/upldReady/" + fileBaseName + ".mp4"
            print cmd
            os.system(cmd)

            # On supprime les images
            if options.remove :
                print "Suppression du dossier ..."
                os.system("rm -R " + directoyrName) 
                #shutil.rmtree(directoyrNameSansSlash)

if __name__ == '__main__':
    main()