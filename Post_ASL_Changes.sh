#!/bin/bash
#
# This script will make changes to Allstar node setup after the following apps have been installed:
#    - ASL v3, Supermon, Skywarn Plus
#
# ***NOTE***:  this script must be run as root or use 'sudo'
#
# Mike - K5MAP, 1/1/2025


# References
#	https://cheatography.com/davechild/cheat-sheets/regular-expressions/
#	https://learnbyexample.github.io/gnu-bre-ere-cheatsheet/
#	https://docs.linuxfoundation.org/v2/security-service/manage-false-positives/regular-expressions-cheat-sheet
#
# EXAMPLES:
# sed -i.bak xxxx  -- creates bak file before modifying original file
# sed '/^$/ d' -- deletes lines which begin and end with space
# sed '/^#/ d' -- deletes comment lines which start with #
# sed '/bash/ i "# insert this" ' -- inserts string "xx" in line before line identified by search
# sed '/bash/ a "# insert this" ' -- inserts string "xx" in line after line identified by search
# sed /s+/usr/sbin/+/var/local+' -- uses deliminitor '+' instead of '/'
# sed -n '/:[[:digit:]]:/ p' -- identifies any lines with single digit surrounded by :
# sed 's/^\([[:digit:]]*\.\)\([[:digit:]]*\.\)\([[:digit:]]*\.\)\([[:digit:]]* \).*/NETWORK_PREFIX:\1\2\3 HOST_ID:\4/' 
#   - the line above identifies IP address w.x.y.z at the beginning of the line and breaks out w.x.y from z

# Uncomment and change tailmessagetime and tailsquashedtime
# sed -i '/tailmessagetime=/s/^#//; s/tailmessagetime=.*/tailmessagetime=600000/' $CONF_FILE
# sed -i '/tailsquashedtime=/s/^#//; s/tailsquashedtime=.*/tailsquashedtime=30000/' $CONF_FILE


# program vars
AST_RESTART=false
# RPT_file="/etc/asterisk/rpt.conf"
RPT_file="/home/asl/Test/rpt.conf"
# SM_Common_file="/var/www/html/supermon/common.inc"
SM_Common_file="/home/asl/Test/common.inc"
# ASL_BACKUP_file="/var/asl-backups/asl-backup-files"
SWP_DTMF=";\n; SkyDescribe DTMF Commands \n\
841 = cmd,/usr/local/bin/SkywarnPlus/SkyDescribe.py 1 ; SkyDescribe the 1st alert \n\
842 = cmd,/usr/local/bin/SkywarnPlus/SkyDescribe.py 2 ; SkyDescribe the 2nd alert \n\
843 = cmd,/usr/local/bin/SkywarnPlus/SkyDescribe.py 3 ; SkyDescribe the 3rd alert \n\
844 = cmd,/usr/local/bin/SkywarnPlus/SkyDescribe.py 4 ; SkyDescribe the 4th alert \n\
845 = cmd,/usr/local/bin/SkywarnPlus/SkyDescribe.py 5 ; SkyDescribe the 5th alert \n\
846 = cmd,/usr/local/bin/SkywarnPlus/SkyDescribe.py 6 ; SkyDescribe the 6th alert \n\
847 = cmd,/usr/local/bin/SkywarnPlus/SkyDescribe.py 7 ; SkyDescribe the 7th alert \n\
848 = cmd,/usr/local/bin/SkywarnPlus/SkyDescribe.py 8 ; SkyDescribe the 8th alert \n\
849 = cmd,/usr/local/bin/SkywarnPlus/SkyDescribe.py 9 ; SkyDescribe the 9th alert \n"
ASL_BACKUP_file="/home/asl/Test/asl-backup-files"
ASL_BACKUP_lines="\n\
# Asterisk customizations \n\
/var/lib/asterisk/sounds \n\
\n\
# SkywarnPlus 
/usr/local/bin/SkywarnPlus/config.yaml \n\
/usr/local/bin/SkywarnPlus/SOUNDS/*.wav \n\
\n\
# Supermon \n\
/var/www/html/supermon \n\
\n\
# Misc directories \n\
/usr/local/sbin \n\
/opt \n\
/var/spool/cron/crontabs \n\
/etc/cron.d \n\
\n"

##########################
# rpt.conf file
##########################
echo "Update rpt.conf file to enable selected DTMF commands..."
read -p "Proceed with change (y/N)? " yn
yn="${yn:-N}"    # set default value
if [[ "$yn" == "Y" || "$yn" == "y" ]]; then
   sed -i.bak -e 's/^; 806 =/806 =/' -e 's/^; 808 =/808 =/' -e 's/^; 811 =/811 =/' -e 's/^; 813 =/813 =/' -e 's/^; 815 =/815 =/' -e 's/^; 816 =/816 =/' -e 's/^; 818 =/818 =/' $RPT_file
   AST_RESTART=true
fi

echo "Update rpt.conf file for Supermon logging..."
read -p "Proceed with change (y/N)? " yn
yn="${yn:-N}"    # set default value
if [[ "$yn" == "Y" || "$yn" == "y" ]]; then
   sed -i.bak -e '/;connpgm/ i connpgm=/usr/local/sbin/supermon/smlogger 1' -e '/;discpgm/ i discpgm=/usr/local/sbin/supermon/smlogger 0' $RPT_file
   AST_RESTART=true
fi
echo ""


##########################
# common.inc file
##########################
echo "Update common.inc for Supermon logging..."
read -p "Proceed with change (y/N)? " yn
yn="${yn:-N}"    # set default value
if [[ "$yn" == "Y" || "$yn" == "y" ]]; then
   sed -i.bak '/$ASTERISK_LOG/s/messages/messages.log/' $SM_Common_file
fi
echo ""


##########################
# SkywarnPlus
##########################
echo "Update rpt.conf adding SkyDescrible DTMF commands..."
read -p "Proceed with change (y/N)? " yn
yn="${yn:-N}"    # set default value
if [[ "$yn" == "Y" || "$yn" == "y" ]]; then
   # search for '818 =' then add after
   sed -i.bak "/818 =/a $SWP_DTMF" $RPT_file
   # AST_RESTART=true
fi
echo ""


##########################
# asl-backup-files file
##########################
echo "Update asl-backup-files to include additional directories..."
read -p "Proceed with change (y/N)? " yn
yn="${yn:-N}"    # set default value
if [[ "$yn" == "Y" || "$yn" == "y" ]]; then
   # append lines to the end of the file
   echo -e $ASL_BACKUP_lines >> $ASL_BACKUP_file
fi
echo ""


if [ "$AST_RESTART" = true ]; then
   echo "Restart asterisk..."
   sudo astres.sh
fi


echo ""
echo "All configurations changes are completed"
