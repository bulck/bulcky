#!/usr/bin/python
# timelapse_make.py ipAddr 
# Permet la fabrication d'un timelapse pour la camera definie par ipAddr
# a partir des images recuperees via get_img.py (pour cette camera)
# La sequence obtenue est laissee sur le FTP local pour futur upload
# via cloud_send.p

import glob
import os
import sys

timelapseFiles = []

if len(sys.argv) > 1:

	jpgLocalPath = "/home/bulcky/FTP/files/%s*.jpg"%sys.argv[1]
	print "Prepare all images from camera %s  " %sys.argv[1]

	timelapseFiles = glob.glob(jpgLocalPath)
	i=1

	for x in timelapseFiles:
		print("mv %s %s%5.5d.jpg"%(x,x[:-12],i) )
		os.system("mv %s %s%5.5d.jpg"%(x,x[:-12],i) )
		i=i+1
										 
					 
	print "List Ok"
	
	fileBaseName = os.path.basename(x)
	cmd = "avconv -r 10 -i %s%s.jpg -r 10 -vcodec libx264 -crf 20 -g 15 /home/bulcky/FTP/files/upldReady/%s.mp4"%(x[:-12],'%5d',fileBaseName[:-13])
	print cmd
	os.system(cmd)

	print "TimeLapse done removing files..."
	
	timelapseFiles = glob.glob(jpgLocalPath)
	for x in timelapseFiles:
		os.system("rm %s"%(x))
	
	
else:

	print "Passer l'adresse de la camera en argument"
