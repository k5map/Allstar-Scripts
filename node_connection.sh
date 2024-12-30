#!/bin/bash

# Filename: node_connection.sh
# Purpose: This script was written to check if a node is connected to a designated
#          AllStarLink node and connect or disconnect based on the option selected
#
# Based on original script written by Ham Radio Crusader, KD5FMU
# Author: Mike, K5MAP
#
# v1.0 (12-29-2024) - initial release
#
# Assumptions (defined in rpt.conf file):
# *1 (-d) = Disconnect link
# *3 (-c) = Connect to a specific node
# *806 (-A) = Disconnect all links
# *811 (-D) = Disconnect a previously permanently connected node
# *813 (-p) = Permanently connect to a specific node
# *816 (-a) = Reconnect disconnected links with 'disconnect all links'
#
# *** NOTE ***:  options are processed in the order provided


# Make sure we are user root
if [ "$(/usr/bin/whoami)" != "root" ] ; then
  echo "${0##*/} must be run as user \"root\"!"
  exit 1
fi

# Determine your AllStarLink node number
# if command does not identify local node, uncomment & assign MY_NODE then comment the line after MY_NODE=XXXXX
# MY_NODE=XXXXXX
MY_NODE=$( asterisk -rx "rpt localnodes" | sed -n '/[0-9]\{5,6\}/p' | sed -n '1,1p' )
echo "MY_NODE = $MY_NODE"

USAGE () {
    echo
    echo ">> check_connection - Allstar node connection tool <<"
    echo
    echo "Usage: `basename $0` [-c -d -p -D -a -A] | [-h]"
    echo
    echo " Options:  -c = Connect to specified node -- transceive"
    echo "           -m = Disconnect specified node -- monitor only"
    echo "           -d = Disconnect specified node"
    echo "           -p = Permanently connect to specified node"
    echo "           -D = Disconnect a previously permanently connected node"
    echo "           -A = Disconnect ALL links"
    echo "           -a = Reconnect disconnected links using -A option"
    echo "           -h = Display this really useful Help message ;)"
}
[ -z "$1" ] && USAGE

Pwd=`pwd`

for i in "$@"
do
    if [ "$i" == "-c" ]; then
        echo "c = $2"
        asterisk -rx "rpt fun $MY_NODE *3$2"
    fi

    if [ "$i" == "-m" ]; then
        echo "m = $2"
        asterisk -rx "rpt fun $MY_NODE *2$2"
    fi

    if [ "$i" == "-d" ]; then
        echo "d = $2"
        asterisk -rx "rpt fun $MY_NODE *1$2"
    fi

    if [ "$i" == "-p" ]; then
        # SOUNDS=YES; HOMEDIRS=YES
        echo "p = $2"
        asterisk -rx "rpt fun $MY_NODE *813$2"
    fi

    if [ "$i" == "-D" ]; then
        # V="v" # Verbose
        echo "D = $2"
        asterisk -rx "rpt fun $MY_NODE *811$2"
    fi

    if [ "$i" == "-a" ]; then
        echo "a = Yes"
        asterisk -rx "rpt fun $MY_NODE *816"
    fi

    if [ "$i" == "-A" ]; then
        echo "A = Yes"
        asterisk -rx "rpt fun $MY_NODE *806"
    fi

    if [ "$i" == "-h" ]; then
        USAGE; echo; exit 0
    fi
    shift
done

# return to original starting directory
cd $Pwd; echo
