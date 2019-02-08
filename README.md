### docker-snort
 
Includes Snort + PulledPork + WebSnort (exposes port 8080)

To use:

# 1. Build with:
 
    ```docker build -t snortweb . --build-arg PPORK_OINKCODE=<your-oink-code-from-snort.org>```
    
# 2. Run with:

    ```docker run -P8080:8080 snortweb```
    
    Once running, visit http://localhost:8080/

# 3. Update the rules:

    ```docker exec snortweb bash update-rules.sh <oink_code>```

 
# Rule updates: 
To just update local.rules/white_list.rules/black_list.rules, just modify the file and build the image!

# Options
The following variables can be added to customise the build (values shown are the defaults):
 
PulledPork Oink code:    ```PPORK_OINKCODE=<your-oink-code-from-snort.org>```
 
Snort version:          ```SNORT_VER=2.9.11.1```

DAQ version:            ```DAQ_VER=daq-2.0.6```

PulledPork version:     ```PPORK_VERSION=0.7.3```

Snort HOME_NET variable:```SNORT_HOME_NET="192.168.0.0/16,172.16.0.0/12,10.0.0.0/8"```

Force rule update:       ```DOWNLOAD_RULES=1```
