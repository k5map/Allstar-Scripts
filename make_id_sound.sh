#!/bin/bash
#
# This script will create a voice callsign ID file for Allstar
#
# Mike - K5MAP, 1/1/2025

# program vars
LETTERS="/var/lib/asterisk/sounds/letters"
DIGITS="/var/lib/asterisk/sounds/digits"
WORDS="/var/lib/asterisk/sounds"

echo "$LETTERS/w.gsm"
echo "$DIGITS/5.gsm"
echo "$WORDS/repeater.gsm"

cat "$LETTERS/w.gsm" "$DIGITS/5.gsm" "$LETTERS/n.gsm" "$LETTERS/c.gsm" "$WORDS/repeater.gsm" "$WORDS/houston.gsm" > /tmp/myid.gsm

