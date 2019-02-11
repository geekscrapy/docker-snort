# docker-snort
 
Includes Snort + PulledPork + WebSnort (exposes port 8080)

The project is to assit in initial stage triage of a potentially malicious pcap. It runs all the rules it can against a pcap attempting to highlight sessions of interest.

*Processing of the PCAP does take a while due to the number of rules being utilised!*

Thanks to:
- Cisco / Sourcefire / Snort team for Snort
- PulledPork project: https://github.com/shirkdog/pulledpork
- WebSnort project for the Snort frontend: https://github.com/shendo/websnort

## To use:

*NB* Oink code required if not using customintel.sh script. Can be obtained from: https://www.snort.org/oinkcodes

### 1. Build with either (2nd option doesn't require git clone);
 
    docker build -t snortweb . --build-arg PPORK_OINKCODE=<your-oink-code-from-snort.org>
    docker build -t snortweb . --build-arg PPORK_OINKCODE=<your-oink-code-from-snort.org> https://github.com/geekscrapy/docker-snort.git
    
### 2. Run with:

    docker run -P8080:8080 snortweb
    
Once running, visit http://localhost:8080/

### 3. Update the rules:

    docker exec snortweb bash update-rules.sh <oink_code>

### 4. (optional) Custom intel rules (customintel.sh):

This custom script enables rules to be pulled from any source when update-rules.sh is run.
Create a scipt named customintel.sh in the current directory before building, or, alternativley the script can be created/modified once the container has been created
    
Requirements:
- The customintel.sh script must output rules to stdout - output is inserted into ```/etc/snort/rules/customintel.rules``` which is loaded by snort

### Additional whitelists/blacklists: 
To update local.rules, white_list.rules or black_list.rules, modify the file and build the image.

### Options
The following variables can be added to customise the build (values shown are the defaults):
 
| Option                   | Build argument                                                 |
|--------------------------|----------------------------------------------------------------|
| PulledPork Oink code:    | ```PPORK_OINKCODE=<your-oink-code-from-snort.org>```           |
| Snort version:           | ```SNORT_VER=2.9.11.1```                                       |
| DAQ version:             | ```DAQ_VER=daq-2.0.6```                                        |
| PulledPork version:      | ```PPORK_VERSION=0.7.3```                                      |
| Snort HOME_NET variable: | ```SNORT_HOME_NET="192.168.0.0/16,172.16.0.0/12,10.0.0.0/8"``` |
