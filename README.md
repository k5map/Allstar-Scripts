# Allstar Scripts

This is a collection of script files for Allstar ASL v3.

## Download Script file

My preference is to put all of my script files in the /usr/local/sbin folder since it is one of the directories included in the path of the user.

To get the script file downloaded onto your node just use this command:
```
sudo wget https://raw.githubusercontent.com/K5MAP/xxx/refs/heads/main/<filename>.sh
```

## Make script file executable

Once a file has been downloaded, additional commands must be executed in order for the script to run.  Enter the following commands:
```
sudo su
cd /usr/local/sbin  [substitute the directory where you want to store the script]
chmod +x <filename>.sh
chown root:root <filename>.sh
```

## Make script file executable

If you want the script to run on a schedule, a crontab job must be created.  To open this crontab editor go to the command like and execute this command:
```
sudo crontab -e
```
You can use the website of https://crontab.guru/ for more details on your crontab entries.

## List of scripts and their author

* node_connections.sh -- authored by K5MAP
* reboot_server.sh -- authored by [KD5FMU](https://github.com/KD5FMU/)
* shutdown_server.sh -- authored by [KD5FMU](https://github.com/KD5FMU/)
* sysMonitor.sh -- authored by K5MAP

## Contribute

Don't hesitate to report any issues, or suggest improvements; just visit the [issues page](https://github.com/k5map/BalloonTelemetry/issues).

73 DE K5MAP
