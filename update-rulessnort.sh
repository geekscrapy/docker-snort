#!/bin/bash
docker exec -ti snortweb bash update-rules.sh > /tmp/update_websnort.log 2>&1
