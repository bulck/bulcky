# Ce script permet de v�rifier le statut du bouton Reset 
# Il faut que Wiring Pi soit install� : http://wiringpi.com/download-and-install/

# Ce script est divis� en deux parties
# Les 10 premi�res secondes permettent de r�initialiser le RPi et de revenir en mode usine
# Pass� ce delais l'appuie sur le bouton permet de faire un Reset de la configuration uniquement (pas des paquets)

# Initialisation : 
puts  "[clock format [clock seconds] -format "%b %d %H:%M:%S"] : bulckyRAZ : Initialisation des pins du GPIO"
# Le bouton est branch� sur la pin 13 sur GPIO. Wirring Pi l'appel 2, le BCM 27
# La pin est en entr�e (la commande suivante marche aussi : gpio mode 2 in)
exec gpio -g mode 27 in

# La LED est branch�e sur la pin 15 du GPIO. Wirring pi l'appel 3, le BCM 22
# La pin est en sortie
exec gpio -g mode 22 out
set compteur 0

# Les 10 premi�res secondes on fait clignoter la LED toutes les secondes pour 
# indiquer cet �tat
set ::startTime [clock seconds]
set ::endTime   [expr $startTime + 10]
set firstLoopFinish 0
set endReset 0




#======== PROCEDURES ========= #

# Proc�dures firstLoop permet de v�rifier si le retour en usise doit �tre appliqu�
# et l'applique le cas �ch�ant
proc firstLoop {} {
    if { $::startTime < $::endTime} {
        set ::startTime [clock seconds]

		#Si on est dans les 10 premi�res secondes
        # On regarde l'�tat du switch
        set pinValue [exec gpio -g read 27]
        
        if {$pinValue == 1} {
            # On force la LED � �tre allum�e
            exec gpio -g write 22 0
           
            incr ::compteur
            
            # On attend un appui de trois secondes au minimum
            # La boucle est rappel� toutes les 50ms
            # 3000 / 50 --> 60
            if {$::compteur > 60} {        
                puts  "[clock format [clock seconds] -format "%b %d %H:%M:%S"] : bulckyRAZ : RAZ usine du Bulcky demand�e"
               
                # On fait clignoter la LED 10 fois
                for {set i 0} {$i < 11} {incr i} {
                    exec gpio -g write 22 0
                    after 200
                    exec gpio -g write 22 1
                    after 200
                    update
                }
                
              
                resetPackages 
                set ::compteur 0
                resetConf
                vwait endReset  
                set endReset 0

                # On fait clignoter la LED 10 fois
                for {set i 0} {$i < 11} {incr i} {
                    exec gpio -g write 22 0
                    after 200
                    exec gpio -g write 22 1
                    after 200
                    update
                }

                # On rappel la proc�dure au bout de 10 secondes pour �viter un double effacage:
                after 10000 firstLoop
            } else {
                # On rappel toute les 50ms si le bouton a �t� appuy�:
                after 50 firstLoop
            }           
        } else {
            set ::compteur 0
            
            # L'�tat de la LED correspond au nb de seconde modulo 2
            exec gpio -g write 22 [expr [clock seconds] % 2]
            
            # On la rappel toute les 50ms si le bouton n'a pas �t� appuy�:
            after 50 firstLoop
        }
    } else {
        # On casse la premi�re boucle
        set ::firstLoopFinish 1
    
    }
}



proc checkAndUpdate {} {
    # On lit la valeur de la pin
    set pinValue [exec gpio -g read 27]
   
    # Si la valeur est 1 , alors on modifie les fichier de conf
    if {$pinValue == 1} {
       
        incr ::compteur
       
        # On force la LED � �tre allum�e
        exec gpio -g write 22 0
       
        if {$::compteur > 40} {
            puts  "[clock format [clock seconds] -format "%b %d %H:%M:%S"] : bulckyRAZ : RAZ de la configuration du Bulcky demand�e"
           
            # On fait clignoter la LED 5 fois
            for {set i 0} {$i < 6} {incr i} {
                exec gpio -g write 22 0
                after 200
                exec gpio -g write 22 1
                after 200
                update
            }
         
            set ::compteur 0  
	        resetConf

            # On rappel la proc�dure au bout de 10 secondes pour �viter un double effacage:
            after 10000 checkAndUpdate
        } else {
            # On rappel la proc�dure toute les 50ms si le bouton a �t� appuy�:
            after 50 checkAndUpdate
        }
    } else {
        set ::compteur 0
        
        # L'�tat de la LED correspond au nb de seconde / 2 modulo 2
        exec gpio -g write 22 [expr ([clock seconds] / 2) % 2]
        
        # On la rappel toute les 50ms si le bouton n'a pas �t� appuy�
        after 50 checkAndUpdate
    }
}


proc resetConf {} {
    #RAZ de la configuration r�seau:
    set RC [catch {exec /bin/cp /etc/network/interfaces.BASE /etc/network/interfaces} msg]
    if {$RC != 0} {puts  "[clock format [clock seconds] -format "%b %d %H:%M:%S"] : bulckyRAZ : Erreur lors du RAZ de la configuration r�seau : $msg"}

    # Remise en place du mot de passe d'origine pour lighttpd:
    set RC [catch {
        if { [file exists /etc/lighttpd/lighttpd.conf.base] == 1} {
            exec mv /etc/lighttpd/lighttpd.conf /etc/lighttpd/lighttpd.conf.https
            exec mv /etc/lighttpd/lighttpd.conf.base /etc/lighttpd/lighttpd.conf
        }
    } msg]

    if {$RC != 0} {puts  "[clock format [clock seconds] -format "%b %d %H:%M:%S"] : bulckyRAZ : Erreur lors du RAZ de la configuration de lighttpd: $msg"}

    set RC [catch {
        if { [file exists /etc/lighttpd/.passwd.BASE] == 1} {
            exec /bin/cp /etc/lighttpd/.passwd.BASE /etc/lighttpd/.passwd
        }
    } msg]

    if {$RC != 0} {puts  "[clock format [clock seconds] -format "%b %d %H:%M:%S"] : bulckyRAZ : Erreur lors du RAZ du mot de passe lighttpd : $msg"}


    #On red�mare le r�seau:
    set RC [catch {
        exec /usr/sbin/service networking restart
    } msg]

     # On fait clignoter la LED 5 fois 
    for {set i 0} {$i < 6} {incr i} {
       exec gpio -g write 22 0
       after 200
       exec gpio -g write 22 1
       after 200
       update
    }
    set endReset 1
}
    

proc resetPackages {} {
    #RAZ des packages:
    set RC [catch {
       #Purge all packages except bulckyRAZ
       exec dpkg --purge bulckyface bulckytime bulckyconf bulckycam bulckydoc bulckypi
   } msg]

   set RC [catch {
       #Install all packages except bulckyRAZ
       exec dpkg -i /home/bulcky/packages/bulckypi.deb 
       exec dpkg -i /home/bulcky/packages/bulckyiface.deb
       exec dpkg -i /home/bulcky/packages/bulckytime.deb
       exec dpkg -i /home/bulcky/packages/bulckycam.deb
       exec dpkg -i /home/bulcky/packages/bulckidoc.deb
       exec dpkg -i /home/bulcky/packages/bulckiconf.deb
   } msg]

   if {$RC != 0} {puts  "[clock format [clock seconds] -format "%b %d %H:%M:%S"] : bulckyRAZ : Erreur dans l'installation des logiciels : $msg"}

}
#================================#


puts  "[clock format [clock seconds] -format "%b %d %H:%M:%S"] : bulckyRAZ : V�rification de la remise en �tat usine du Bulcky"
firstLoop
vwait firstLoopFinish

puts  "[clock format [clock seconds] -format "%b %d %H:%M:%S"] : bulckyRAZ : V�rification de l'effacement de la configuration du Bulcky"

# Proc�dure utilis�e pour v�rifier l'�tat de la pin et faire les MAJ si n�c�ssaire:
checkAndUpdate

# On attend ind�finiment
vwait forever





