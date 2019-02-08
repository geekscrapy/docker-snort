#!/bin/bash

if [ ! -f ./customintel.sh ]; then
	touch customintel.sh
fi

bash customintel.sh > /etc/snort/rules/customintel.rules

if [ -z "$1" ]; then
  echo "No Oink code given... Not downloading rules. Run with \"docker exec snortweb bash update-rules.sh <oinkcode>\""
fi

# Add the oink code to the config file and tell PulledPork to download new rules
sed -i 's/<PPORK_OINKCODE>/'"$1"'/g' /etc/snort/pulledpork.conf
/usr/sbin/pulledpork.pl -c /etc/snort/pulledpork.conf -v -EP
# Now remove the oink code
sed -i 's/'"$1"'/<PPORK_OINKCODE>/g' /etc/snort/pulledpork.conf

# Now test snort :)
snort -c /etc/snort/snort.conf -T
