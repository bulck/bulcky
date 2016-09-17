#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
    Ce programme télécharge les fichiers présents sur un serveur FTP et les sauvegarde en local.
    Permet la fabrication d'un timelapse pour la camera definie par ipAddr
    a partir des images recuperees via get_img.py (pour cette camera)
    La sequence obtenue est laissee sur le FTP local pour futur upload via cloud_send.py
    
    python /opt/bulckyCamAxis/timelapse_make.py -i 192.168.1.100 -d
    
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
import sys
from optparse import OptionParser


def main():
    # On cré le parser pour les parametres en entrée
    usage = "usage: %prog [options]"
    parser = OptionParser(usage=usage)

    parser.add_option("-i", "--ip", dest="ip",
                      action="store", type="string",
                      help="Adresse IP de la caméra")
    parser.add_option("-d", "--delete", dest="delete",
                      action="store_false", default=False,
                      help="supprime les fichiers")

    (options, args) = parser.parse_args()

    # L'adresse IP doit être transmise
    if not options.ip :
        parser.error("options -i or --ip is mandatory")

    timelapseFiles = []

    print "Prepare all images from camera " + options.ip
    
    # Le répertoire qui contient les images 
    jpgLocalPath = "/home/bulcky/FTP/files/" + options.ip + "*.jpg"

    # On liste les images présentes
    timelapseFiles = glob.glob(jpgLocalPath)
    
    # On les tries par ordre alphabétique
    timelapseFiles.sort()
    
    
    # On renomme les images pour qu'elles aient le bon format
    # mv /home/bulcky/FTP/files/192.168.1.100_17-09-16-14-50-06.jpg /home/bulcky/FTP/files/192.168.1.100-00001.jpg
    i=1
    for fileName in timelapseFiles:
        newFilename = fileName[:36] + "-" + str(i).zfill(5) + fileName[-4:]
        cmdToExecute = "mv " + fileName + " " + newFilename
        i=i+1
        # On ne copie que les fichiers qui ont un nom différent
        if newFilename != fileName :
            print(cmdToExecute)
            os.system(cmdToExecute)

    print "List Ok"

    # On lance la création de la vidéo
    fileBaseName = os.path.basename(fileName)
    cmd = "avconv -r 10 -i " + fileName[:36] + "-%5d.jpg -r 10 -vcodec libx264 -crf 28 -g 15 /home/bulcky/FTP/files/upldReady/" + fileBaseName[:22] + ".mp4"
    print cmd
    os.system(cmd)

    # On supprime les images
    if options.delete :
        print "TimeLapse done removing files..."
        timelapseFiles = glob.glob(jpgLocalPath)
        for fileName in timelapseFiles:
            os.system("rm %s"%(fileName))


if __name__ == '__main__':
    main()