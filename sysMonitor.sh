#!/bin/bash 
# 
# EXAMPLE Script to send email or SMS message if 
# CPU temperature, Disk space or Memory exceeds
# a threashold.
# The ssmtp package must be installed and configured
# prior to running this script
# Mike - K5MAP  2/5/2024 

# Log file info
SCRIPT_LOG=/tmp/sysMonitor.log
echo -n "[`date`] " >  $SCRIPT_LOG
echo "Script started... " >> $SCRIPT_LOG
LOG_MSG=" "

# Maximum CPU Temperature in Degrees C 
MAXTEMP="45" 

# Maximum Disk usage
MAXDISKUSE="80" 

# Destination SMS number and address – CHANGE THIS! 
# If more than one destination MUST use comma between email addresses
To="abc@xxx.com" 
From="xxx@foo.com"

# How often to alert if temperature is exceeded - Default 10 Minutes
ALERT_INTERVAL="5m" 
SLEEP_INTERVAL="10m"

function send_email() { 
   # echo -e "Subject: Warning CPU High Temp\nTo: $RECEIVER\n\nWarning CPU Temperature $CTEMP C at server $HOSTNAME" | sendmail -t 
   # echo -e "To:${To} \nSubject:Warning CPU Temp\n\nWarning CPU Temperature ${CTEMP}C at $HOSTNAME" | sendmail -f "${From}" -t
   echo -e "To:${To} \nSubject:${Subject}\n\n${Body}" | sendmail -f "${From}" -t
   # logger "???"
   echo -n "[`date`] " >>  $SCRIPT_LOG
   echo $LOG_MSG >> $SCRIPT_LOG
} 

while : 
do 
   ##############################################################################################
   # Check disk space
   df -Ph | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5,$1 }' | while read output;
   do
      echo -n "$output - "
      used=$(echo $output | awk '{print $1}' | sed s/%//g)
      partition=$(echo $output | awk '{print $2}')
      if [ $used -ge $MAXDISKUSE ]; then
         echo "The partition \"$partition\" has used $used% exceeding threashold at $(date)"
         LOG_MSG="Partition \"$partition\" has used $used% exceeding threashold"
	     Subject="Warning!!!"
	     Body="Partition \"$partition\" on $(hostname) has used $used% exceeding threashold"
		 send_email
      else
         echo "Disk space usage is under threshold"
      fi
   done

   ##############################################################################################
   # Check CPU temp
   PTEMP=`cat /sys/class/thermal/thermal_zone0/temp` 
   CTEMP=`expr $PTEMP / 1000`
   echo -n "CPU Temp: $CTEMP"
   echo -n "C / " 
   FTEMP=`expr 9 '*' $CTEMP / 5 + 32` 
   echo -n "$FTEMP" 
   echo "F" 
   if [ $CTEMP -gt $MAXTEMP ] ; then 
      echo "Sending temperature warning message - CPU ${CTEMP}C / ${FTEMP}F" 
      LOG_MSG="Sending temperature warning message - CPU ${CTEMP}C / ${FTEMP}F"
	  Subject="Warning!!!"
	  Body="Warning CPU Temperature ${CTEMP}C / ${FTEMP}F at $HOSTNAME"
      send_email
      while [ $CTEMP -gt $MAXTEMP ] 
      do 
         sleep $ALERT_INTERVAL 
         if [ $CTEMP -le $MAXTEMP ] ;  then 
            echo "CPU Temp Normal ${CTEMP}C / ${FTEMP}F" 
            LOG_MSG="Alert cleared -- CPU ${CTEMP}C / ${FTEMP}F"
	        Subject="Alert Cleared"
	        Body="CPU Temp Normal ${CTEMP}C at $HOSTNAME"
            send_email
            break 
         else 
            echo "Sending temperature warning message - CPU ${CTEMP}C / ${FTEMP}F" 
            LOG_MSG="Sending temperature warning message - CPU ${CTEMP}C / ${FTEMP}F"
            Subject="Warning!!!"
            Body="Warning CPU Temperature ${CTEMP}C / ${FTEMP}F at $HOSTNAME"
            send_email
         fi 
      done 
   fi 
   sleep $SLEEP_INTERVAL
   
done
