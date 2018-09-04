# docker-snort
 
Includes Snort + PulledPork + WebSnort (exposes port 8080)
 
# Build with:
 
    docker build -t snort:1.0 . --build-arg PPORK_OINKCODE=<your-oink-code-from-snort.org> --build-arg DOWNLOAD_RULES="Yes please"
    
# Run with:

    docker run -P8080:8080 snort:1.0

 
# Rule updates:
 
To get PulledPork to download and update rules, just define ```--build-arg DOWNLOAD_RULES="anything-you-like"```
To just update local.rules/white_list.rules/black_list.rules, just modify the file!


# Options
The following variables can be added to customise the build (values shown are the defaults):
 
### Required:
PulledPork Oink code:    ```PPORK_OINKCODE=<your-oink-code-from-snort.org>```
 
### Optional:
Snort version:          ```SNORT_VER=2.9.11.1```

DAQ version:            ```DAQ_VER=daq-2.0.6```

PulledPork version:     ```PPORK_VERSION=0.7.3```

Snort HOME_NET variable:```SNORT_HOME_NET="192.168.0.0/16,172.16.0.0/12,10.0.0.0/8"```

Force rule update:       ```DOWNLOAD_RULES=""```
