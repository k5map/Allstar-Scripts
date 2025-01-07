#!/usr/bin/env python3
# 
# This script reads the password from the Asterisk manager.conf file
# or allows the user to enter a new password.  Then updates both 
# Supermon and Allmon3 configuration files
#
# ***NOTE*** - this script must be run as 'root' or using sudo
#
import configparser
from subprocess import run
from shlex import split

NODENO = "504360"
NEW_PSWD = "N"
PSWD = "-"
MGRFILE = "/etc/asterisk/manager.conf"
ALLMON_FILE = "/var/www/html/supermon/allmon.ini"
ALLMON3_FILE = "/etc/allmon3/allmon3.ini"
HTP_FILE = "/var/www/html/supermon/.htpasswd"

# prompt to see if creating new or updating
NEW_PSWD = input("Would you like to set a new web admin password [y/N]? ") or "N"
if NEW_PSWD == "y" or NEW_PSWD == "Y":
    while PSWD == "-":
        PSWD = input("Enter new web admin password (no special chars): ") or "-"
        # check PSWD for special chars, if so prompt for new password again
        CHECK = False
        for char in PSWD:
            if not char.isalnum() or char.isspace():
                CHECK = True
        if CHECK == True:
            PSWD = "-"
    # update .htpasswd with -c (create new file) and -b (password in command)
    # run(split('sudo htpasswd -c -b HTP_FILE admin PSWD'))
    run(f"sudo htpasswd -c -b {HTP_FILE} admin {PSWD}", shell=True, check=True)
    print("htpasswd has been updated with new password...")
print(" ")


# read current manager password or update with new password
config = configparser.ConfigParser()
if NEW_PSWD == "n" or NEW_PSWD == "N":
    # read current manager password
    config.read(MGRFILE)
    PSWD = config.get('admin','secret')
    print(f"Current manager.conf admin password = {PSWD} '\n'")
else:
    # set manager password with new password
    config.read(MGRFILE)
    config.set('admin', 'secret', PSWD)
    with open(MGRFILE, 'w') as configFile:
        config.write(configFile)
    print('manager.conf admin password has been updated\n')


# update Supermon config
edit = configparser.ConfigParser()
edit.read(ALLMON_FILE)
edit.set(NODENO, 'passwd', PSWD)
with open(ALLMON_FILE, 'w') as configFile:
    edit.write(configFile)
print('Supermon password has been updated')


# update Allmon3 config
edit = configparser.ConfigParser()
edit.read(ALLMON3_FILE)
edit.set(NODENO, 'pass', PSWD)
with open(ALLMON3_FILE, 'w') as configFile:
    edit.write(configFile)
print('Allmon3 password has been updated')

print("\n")
