#!/bin/bash

if [ -z "$1" ]; then
  echo "No Oink code given... Run with \"docker exec snortweb bash update-rules.sh <oinkcode>\""
  exit 1
fi

# Add the oink code to the config file and tell PulledPork to download new rules
sed -i 's/<PPORK_OINKCODE>/'"$1"'/g' /etc/snort/pulledpork.conf
/usr/sbin/pulledpork.pl -c /etc/snort/pulledpork.conf -v -EP
# Now remove the oink code
sed -i 's/'"$1"'/<PPORK_OINKCODE>/g' /etc/snort/pulledpork.conf

# Now test snort :)
snort -c /etc/snort/snort.conf -T
