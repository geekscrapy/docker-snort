#!/bin/bash

if [ ! -f ./customintel.sh ]; then
	touch customintel.sh
fi

bash customintel.sh > /etc/snort/rules/customintel.rules

if [ -z "$1" ]; then
  echo "No Oink code given... Not downloading rules. Run with \"docker exec snortweb bash update-rules.sh <oinkcode>\""
fi

/usr/sbin/pulledpork.pl -c /etc/snort/pulledpork.conf -v -EP

# Now test snort :)
snort -c /etc/snort/snort.conf -T
