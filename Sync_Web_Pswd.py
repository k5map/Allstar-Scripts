# 
# This script reads the password from the Asterisk manager.conf file
# then updates both Supermon and Allmon3 configuration files
#
# ***NOTE*** - this script must be run as 'root' or using sudo
#
import configparser

NODENO = "504360"
PSWD = "xxx"
MGRFILE = "/etc/asterisk/manager.conf"
ALLMON_FILE = "/var/www/html/supermon/allmon.ini"
ALLMON3_FILE = "/etc/allmon3/allmon3.ini"

# read current manager password 
config = configparser.ConfigParser()
config.read(MGRFILE)
PSWD = config.get('admin','secret')
# print('admin password = ', PSWD, '\n')

# update Supermon config
edit = configparser.ConfigParser()
edit.read(ALLMON_FILE)
edit.set(NODENO, 'passwd', PSWD)
with open(ALLMON_FILE, 'w') as configFile:
    edit.write(configFile)


# update Allmon3 config
edit = configparser.ConfigParser()
edit.read(ALLMON3_FILE)
edit.set(NODENO, 'pass', PSWD)
with open(ALLMON3_FILE, 'w') as configFile:
    edit.write(configFile)
