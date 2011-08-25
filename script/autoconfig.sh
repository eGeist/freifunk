#!/bin/sh
#################################
# Code developed by: eGeist aka #
# Hudson Deleter && Brad Ass    #
#        huddel_&_brass  ;)     #
#################################
# Aufrufe mit: 
# autoconfig-linksys-wrt54gl.sh wireless 
# autoconfig-linksys-wrt54gl.sh network
# autoconfig-linksys-wrt54gl.sh batman-adv
#
#configpath

#CONFP="/etc/config"

###### pfade definieren ######
# grundsaetzliches config verzeichnis
CONFP="$HOME/etc/config" 
# flag verz. fuer ggf noetige bootdurchlaeufe und logs
AUTOLOGP="$HOME/autocfglogs" 

## benoetigte verzeichnisse anlegen 
# Verzeichnis vorhanden ? Nein > Anlegen
if [ ! -d $CONFP ]; then
  mkdir -p $CONFP
fi

if [ ! -d $AUTOLOGP ]; then
        mkdir -p $AUTOLOGP
fi
              
###############################################################################
# Durchlauf schon mal stattgefunden ? NEIN > setze bootflag(n)
# wird nochmal ein boot nach dem 1 bis xten durchlauf benoetigt,
# und das script soll dann diverse configschritte nicht radikal neu
# setzen, kann das hier als einstieg zur weiteren steuerung genutzt werden

BOOTFLAG="bootstep1" # wird nach dem ersten script durchlauf gesetzt.
if [ ! -e $AUTOLOGP/$BOOTFLAG ]; then
	touch $AUTOLOGP/$BOOTFLAG
else {
	# step ggf mittels schleife oder was auch immer erhoehen
	LOOPN="loop2" # hier nur ein festes beispiel
	touch $AUTOLOGP/$LOOPN
}	
fi	 

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
########## definitionsabschnitt fuer ggf. benoetigte funktionen###
# schreibe wertepaare in die datei
function pcfg ()
{
    echo -e "$1\t$2\t$3"|cat>>$CONFP/$DEVCONF
}

# ....
#
#
#
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

################################################################################
# hier spaeter die ablaufsteuerung des scripts
# script ruft sich selbst auf mit den entsprechenden parametern
#
#++++++++++++++++++++++++++++++++++++++++++
# Pruefe : Hat Node connect 2 paul ?      +
# dann mache weiter bei (config_from_paul)+
#++++++++++++++++++++++++++++++++++++++++++
#
# TODO Sicherheit: Pruefen auf zulaessige Werte
# DEVCONF ungleich: wireless,batman-adv,network,...??? ABBRUCH #
#
#
# Zum TESTEN !!!!!!!!!
DEVCONF=$1 
################################################################################

#### main ########------------------------------------------------------------->

case $DEVCONF in
	wireless){
		 #Altlasten beseitigen
		touch   $CONFP/$DEVCONF ; rm $CONFP/$DEVCONF		
		# configfile neu schreiben
		pcfg "#config wifi"
		pcfg "\tconfig" "wifi-device"  	"radio0"
		pcfg "\toption" "type"     	"mac80211"
		pcfg "\toption" "channel"  	"1"
		
		#auslesen mac 
		DV="eth0" # nur zu testzwecken
		MACWIFI=`ifconfig $DV | grep 'Hardware ' | awk '{ print $6 }'`
		
		pcfg "\toption" "mac"		"$MACWIFI # testadresse"
		pcfg "\toption" "hwmode"		"11g"

		pcfg "config" "wifi-iface" 	""
		pcfg "\toption" "device"   	"radio0"
		pcfg "\toption" "network"  	"wlan0"
		pcfg "\toption" "mode"     	"adhoc"
		pcfg "\toption" "ssid"  	"mesh"
		pcfg "\toption" "encryption"	"none"
		pcfg "\toption" "bssid"		"02:ca:ff:ee:ba:be"
	
	# .... sonstige schritte
	
	# abschnitt fehlerfrei durchlaufen ? 
	# TODO fehlerbehandlung muss noch gemacht werden
	# setze stepstatus
	STEP="wirelesscfg-ok"
	touch $AUTOLOGP/$STEP
	};;
	
	network){
		 #Altlasten beseitigen
		touch   $CONFP/$DEVCONF ; rm $CONFP/$DEVCONF		
		# configfile neu schreiben
		pcfg "#### VLAN configuration" 
		pcfg "config switch eth0"
		pcfg "\toption enable   1"
		pcfg "\n"
		pcfg "config switch_vlan eth0_0"
		pcfg "\toption device   \"eth0\""
		pcfg "\toption vlan     0"
		pcfg "\toption ports    \"0 1 2 3 5\""
		pcfg "\n"
		pcfg "\tconfig switch_vlan eth0_1"
		pcfg "\toption device   \"eth0\""
		pcfg "\toption vlan     1"
		pcfg "\toption ports    \"4 5\""
		pcfg "\n"
		pcfg "#### Loopback configuration"
		pcfg "\tconfig interface loopback"
		pcfg "\toption ifname	\"lo\""
		pcfg "\toption proto	static"
		pcfg "\toption ipaddr	127.0.0.1"
		pcfg "\toption netmask	255.0.0.0"
		pcfg "\n"
		pcfg "#### LAN configuration"
		pcfg "\tconfig interface lan"
		pcfg "\toption type 	bridge"
		pcfg "\toption ifname	\"eth0.0\""
		pcfg "\toption proto	static"
		pcfg "\toption ipaddr	192.168.1.1"
		pcfg "\toption netmask	255.255.255.0"
		pcfg "\n"
		pcfg "#### WAN configuration"
		pcfg "config interface	wan"
		pcfg "\toption ifname	\"eth0.1\""
		pcfg "\toption proto	dhcp"
       	
        	# .... sonstige schritte
                # abschnitt fehlerfrei durchlaufen ? 
                # TODO fehlerbehandlung muss noch gemacht werden
              	# setze stepstatus
        	STEP="networkcfg-ok"
        	touch $AUTOLOGP/$STEP
	};;
	
	batman-adv){
		#Altlasten beseitigen
		touch   $CONFP/$DEVCONF ; rm $CONFP/$DEVCONF		
		# configfile neu schreiben
		pcfg "iconfig" "mesh" "bat0"
		pcfg "\toption" "interfaces" "wlan0"
		pcfg "\toption" "aggregated_ogms" ""
		pcfg "\toption" "bonding" ""
		pcfg "\toption" "log_level" ""
		pcfg "\toption" "orig_interval" ""
		pcfg "\toption" "vis_mode" ""
		#pcfg       "\toption" "fragmentation"
		#pcfg       "\toption" "'gw_bandwidth"
		#pcfg       "\toption" "gw_mode"
		#pcfg       "\toption" "gw_sel_class"
	        # .... sonstige schritte
                # abschnitt fehlerfrei durchlaufen ? 
                # TODO fehlerbehandlung muss noch gemacht werden
               	# setze stepstatus
                STEP="batman-advcfg-ok"
                touch $AUTOLOGP/$STEP
	};;

	make_foo){
		#....
		clear; echo "fuck" ; STEP="tzzz-nix-als-dumpfug" ;touch $AUTOLOGP/$STEP	
	};;	
	
	*) exit
	;;
esac