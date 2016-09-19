#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
    Ce programme permet de renommer les images d'un dossier pour qu'elles aient le bon format pour être encodée en vidéo
    
    Les images sont aussi déplacées dans un dossier par jour et par caméra : 192.168.1.100_16-09-08
    
    python /opt/bulckyCamAxis/timelapse_rename_img.py -d /home/bulcky/FTP/files
    
"""

import glob
import os
from os import listdir, stat
from os.path import isfile, join
import sys
from optparse import OptionParser
import datetime

def main():
    # On crée le parser pour les parametres en entrée
    usage = "usage: %prog [options]"
    parser = OptionParser(usage=usage)

    parser.add_option("-d", "--directory", dest="folderin",
                      action="store", type="string",
                      help="Adresse du dossier")

    (options, args) = parser.parse_args()

    # Le dossier d'entrée doit être envoyé
    if not options.folderin :
        parser.error("options -d or --directory is mandatory")

    # On liste les images 
    timelapseFiles = [f for f in listdir(options.folderin) if isfile(join(options.folderin, f))]

    # On les tries par ordre alphabétique
    timelapseFiles.sort()

    now = datetime.datetime.now()
    jourActuel = now.strftime("%d")

    # On renomme les images pour qu'elles aient le bon format :
    # mv /home/bulcky/FTP/files/192.168.1.100_17-09-16-14-50-06.jpg /home/bulcky/FTP/files/192.168.1.100-00001.jpg
    # On ajoute la date et l'heure sur les images :
    # convert 192.168.1.100_17-09-16-14-00-07.jpg -fill "#00000080" -draw "rectangle 1270,920,1880,1030" -fill "#ffffffe0" -pointsize 70 -annotate +1300+1000 "18/09/2016 17:00" D:\result.jpg
    i=1
    IPsaved = ""
    JOURsaved = ""
    for fileName in timelapseFiles:

        # On divise le nom du fichier 
        # Par exemple : "192.168.1.100_17-09-16-14-00-07.jpg" 
        # donne ['192', '168', '1', '100', '17', '09', '16', '14', '00', '07', 'jpg']
        dividedName = fileName.replace('_', '-').replace('.', '-').split('-')

        # Si l'élement -6 est est 192 , c'est que le fichier a déjà été formaté 
        if dividedName[-6] == "192" :
            continue

        # On récupère la date 
        annee = dividedName[-5]
        mois = dividedName[-6]
        jour = dividedName[-7]
        heure = dividedName[-4]
        minute = dividedName[-3]

        # On crée la chaine de date pour l'affichage dans imagemagick
        IP = dividedName[-11] + "." + dividedName[-10] + "." + dividedName[-9] + "." + dividedName[-8]
        dateStr = jour + "/" + mois + "/20" + annee + " " + heure + ":" + minute
        dateFolder = IP + "_" + annee + "-" + mois + "-" + jour
        
        # Si l'adresse IP est différente, on recommence l'indexation à 1
        if IP != IPsaved :
            i=1
            IPsaved = IP
            
        # Si le jour est différent, on recommence l'indexation à 1
        if jour != JOURsaved :
            i=1
            JOURsaved = jour            

        # On calcul le nouveau nom du fichier 
        newFilename = str(i).zfill(5) + "." + dividedName[-1]

        # On vérifie si le dossier de destination existe, sinon on le crée :
        if not os.path.exists(options.folderin + "/" + dateFolder) : 
            os.mkdir(options.folderin + "/" + dateFolder)

        cmdAddRectangle = " -fill '#00000080' -draw 'rectangle 1270,920,1880,1030' "
        cmdAddText      = " -fill '#ffffffe0' -pointsize 70 -annotate +1300+1000 '" + dateStr + "' "

        # Pour convertir les images avec imagemagick :
        # cmdToExecute = "convert " + options.folderin + "/" + fileName + cmdAddRectangle + cmdAddText  + options.folderin + "/" + dateFolder + "/" + newFilename

        # Pour juste déplacer et renommer l'image :
        cmdToExecute = "mv " + options.folderin + "/" + fileName + " " + options.folderin + "/" + dateFolder + "/" + newFilename

        # On lance la commande
        print(cmdToExecute)
        os.system(cmdToExecute)

        i=i+1

    print "Conversion Deplacement terminee"


if __name__ == '__main__':
    main()