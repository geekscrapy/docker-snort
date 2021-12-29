FROM ubuntu:16.04

## Env
ARG DAQ_VER=daq-2.0.7

## PulledPork Env
ARG PPORK_VERSION=0.7.4

## Snort Env
ARG SNORT_VER=2.9.18.1

## LUAJIT Env
ARG LUAJIT_VER=2.0.5

## Install Dependencies
RUN apt-get update && apt-get -y install \
    wget \
    build-essential \
    libtool \
    automake \
    gcc \
    flex \
    bison \
    libnet1 \
    libnet1-dev \
    libpcre3 \
    libpcre3-dev \
    autoconf \
    libcrypt-ssleay-perl \
    libwww-perl \
    git \
    zlib1g \
    zlib1g-dev \
    libssl-dev \
    libmysqlclient-dev \
    imagemagick \
    wkhtmltopdf \
    libyaml-dev \
    libxml2-dev \
    libxslt1-dev \
    openssl \
    libreadline6-dev \
    unzip \
    libcurl4-openssl-dev \
    libapr1-dev \
    libaprutil1-dev \
    supervisor \
    net-tools \
    gettext-base \
    libdumbnet-dev \
    libpcap-dev \
    python-pip \
    pkg-config \
    python-jinja2 \
    && apt-get clean && rm -rf /var/cache/apt/*

##Install LUAJIT
RUN cd /tmp \
    && wget http://luajit.org/download/LuaJIT-$LUAJIT_VER.tar.gz \
    && tar zxf LuaJIT-$LUAJIT_VER.tar.gz \
    && cd LuaJIT-$LUAJIT_VER \
    && make && make install

## Install DAQ
RUN cd /tmp \
    && wget https://snort.org/downloads/snort/$DAQ_VER.tar.gz \
    && tar zxf $DAQ_VER.tar.gz \
    && cd $DAQ_VER \
    && ./configure \
    && make && make install \
    && ldconfig

## Install SNORT
RUN cd /tmp \
    && wget https://snort.org/downloads/snort/snort-$SNORT_VER.tar.gz \
    && tar zxf snort-$SNORT_VER.tar.gz \
    && cd snort-$SNORT_VER \
    && ./configure --enable-sourcefire \
    && make && make install

## User/group/dir for Snort
RUN groupadd snort \
    && useradd snort -d /var/log/snort -s /sbin/nologin -c SNORT_IDS -g snort \
    && mkdir -p /var/log/snort \
    && chown snort:snort /var/log/snort -R \
    && mkdir -p /etc/snort \
    && cd /tmp/snort-$SNORT_VER \
    && cp -r etc/* /etc/snort/

## Install Pulledpork
RUN cd /tmp \
    && wget https://github.com/shirkdog/pulledpork/archive/v$PPORK_VERSION.tar.gz \
    && tar zxf v$PPORK_VERSION.tar.gz \
    && cd pulledpork-$PPORK_VERSION \
    && cp pulledpork.pl /usr/sbin/ \
    && chmod 755 /usr/sbin/pulledpork.pl \
    && cp -r etc/* /etc/snort/ \
    && cpan install LWP::Protocol::https \
    && cpan install Crypt::SSLeay  \
    && cpan Mozilla::CA IO::Socket::SSL

RUN rm -rf /tmp/*

## Snort
RUN cd /etc/snort \
    && chown -R snort:snort * \
    && mkdir -p /usr/local/lib/snort_dynamicrules \
    && mkdir /etc/snort/rules \
    && touch /etc/snort/rules/so_rules.rules \
    && touch /etc/snort/rules/local.rules \
    && touch /etc/snort/rules/snort.rules \
    && sed -i \
      -e 's#^var RULE_PATH.*#var RULE_PATH /etc/snort/rules#' \
      -e 's#^var SO_RULE_PATH.*#var SO_RULE_PATH $RULE_PATH/so_rules#' \
      -e 's#^var PREPROC_RULE_PATH.*#var PREPROC_RULE_PATH $RULE_PATH/preproc_rules#' \
      -e 's#^var WHITE_LIST_PATH.*#var WHITE_LIST_PATH $RULE_PATH/iplists#' \
      -e 's#^var BLACK_LIST_PATH.*#var BLACK_LIST_PATH $RULE_PATH/iplists#' \
      -e 's/^\(include $.*\)/# \1/' \
      -e '$a\\ninclude $RULE_PATH/local.rules' \
      -e '$a\\ninclude $RULE_PATH/snort.rules' \
      -e 's!^# \(config logdir:\)!\1 /var/log/snort!' \
      /etc/snort/snort.conf

## Install websnort
RUN pip install websnort

# Need to generate these for the first run of PulledPork
RUN touch /etc/snort/rules/local.rules
RUN mkdir -p /etc/snort/rules/iplists/
RUN touch /etc/snort/rules/iplists/black_list.rules
RUN touch /etc/snort/rules/iplists/white_list.rules


###########################################################################
## Edits should be conducted here to limit modification to the upper layers

ARG SNORT_HOME_NET="192.168.0.0/16,172.16.0.0/12,10.0.0.0/8"

## copy pulled pork conf
COPY pulledpork.conf /etc/snort/pulledpork.conf
ARG PPORK_OINKCODE
RUN sed -i -r "s/CHANGE_CODE_HERE/${PPORK_OINKCODE}/g" /etc/snort/pulledpork.conf
#RUN sed -i -e 's|<'PPORK_VERSION'>|'$PPORK_VERSION'|g' /etc/snort/pulledpork.conf

## Rule management
## Enable all rules!!
## RUN echo 'pcre:.' >> /etc/snort/enablesid.conf

## These are noisy. Bad taffic alerts etc
## RUN echo 'preprocessor' >> /etc/snort/disablesid.conf

## Allow lots of flow bits
RUN sed -i 's/^.*config flowbits_size: 64$/config flowbits_size: 2048/' /etc/snort/snort.conf
## Run snort with rule profiling
RUN sed -i 's/#config profile_rules: print all, sort avg_ticks/config profile_rules: print 100, sort avg_ticks_per_nomatch/' /etc/snort/snort.conf
## Disable sensitive data pre proc + rules
RUN sed -i '/preprocessor sensitive_data/s/^/#/' /etc/snort/snort.conf
## Enable portscan detection
RUN sed -i 's/# preprocessor sfportscan/preprocessor sfportscan/' /etc/snort/snort.conf
## Set HOME_NET
RUN sed -i 's#^ipvar HOME_NET any.*#ipvar HOME_NET '"$SNORT_HOME_NET"'#' /etc/snort/snort.conf

###########################################################################

# COPY local rules across and re-run pulledpork
COPY local.rules /etc/snort/rules/local.rules
COPY ip_black_list.rules /etc/snort/rules/iplists/black_list.rules
COPY ip_white_list.rules /etc/snort/rules/iplists/white_list.rules
RUN touch /etc/snort/rules/customintel.rules
COPY disablesid.conf /etc/snort/disablesid.conf

# Add the script that allows the rules to be updated when the container is running
COPY *.sh ./
#RUN if [ ! -z $PPORK_OINKCODE ]; then  bash update-rules.sh "$PPORK_OINKCODE"; fi

EXPOSE 8080
CMD ["websnort"]
