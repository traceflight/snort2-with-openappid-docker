FROM centos:7
MAINTAINER Julian Wang <traceflight@outlook.com>

ENV DAQ_VERSION 2.0.6
ENV SNORT_VERSION 2.9.11.1
ENV OPENAPPID_VERSION 8373

# install requirements
RUN yum -y install epel-release libdnet && \
    yum -y install make wget gcc gcc-c++ libdnet libdnet-devel luajit luajit-devel hwloc hwloc-devel openssl openssl-devel zlib-devel pkgconfig libpcap libpcap-devel pcre pcre-devel lzma xz-devel bison flex libnetfilter_queue-devel

# install daq
RUN mkdir -p /home/snort/apps && \
    cd /home/snort/apps && \
    wget https://snort.org/downloads/snort/daq-${DAQ_VERSION}-1.centos7.x86_64.rpm -O daq-${DAQ_VERSION}-1.centos7.x86_64.rpm && \
    yum -y install daq-${DAQ_VERSION}-1.centos7.x86_64.rpm

# install snort
RUN cd /home/snort/apps && \ 
    wget https://snort.org/downloads/snort/snort-${SNORT_VERSION}.tar.gz -O snort-${SNORT_VERSION}.tar.gz && \
    tar -xvzf snort-${SNORT_VERSION}.tar.gz && \
    cd snort-${SNORT_VERSION} && \
    ./configure --enable-sourcefire --enable-open-appid && \
    make && \
    make install && \
    ldconfig

# install openappid 
RUN cd /home/snort/apps && \
    wget https://www.snort.org/downloads/openappid/${OPENAPPID_VERSION} -O snort-openappid.tar.gz && \
    tar -zxvf snort-openappid.tar.gz && \
    mkdir -p /etc/snort/appid/ && \
    cp -R odp /etc/snort/appid/

# other steps
RUN mkdir /etc/snort && \
    mkdir /etc/snort/rules && \
    mkdir /etc/snort/rules/iplists && \
    mkdir /etc/snort/preproc_rules && \
    mkdir /usr/local/lib/snort_dynamicrules && \
    mkdir /etc/snort/so_rules && \
    mkdir /usr/local/lib/thirdparty && \
    touch /etc/snort/rules/iplists/black_list.rules && \
    touch /etc/snort/rules/iplists/white_list.rules && \
    touch /etc/snort/rules/local.rules && \
    touch /etc/snort/sid-msg.map && \
    mkdir /var/log/snort && \
    mkdir /var/log/snort/archived_logs && \
    chmod -R 5775 /etc/snort && \
    chmod -R 5775 /var/log/snort && \
    chmod -R 5775 /var/log/snort/archived_logs && \
    chmod -R 5775 /etc/snort/so_rules && \
    chmod -R 5775 /usr/local/lib/snort_dynamicrules && \
    cd /home/snort/apps/snort-${SNORT_VERSION}/etc && \
    cp *.conf* /etc/snort && \
    cp *.map /etc/snort && \
    cp *.dtd /etc/snort

ADD etc/snort.conf /etc/snort/

# Cleanup.
RUN yum clean all && \
    rm -rf /var/tmp/* && \
    rm -rf /tmp/* && \
    snort -V

