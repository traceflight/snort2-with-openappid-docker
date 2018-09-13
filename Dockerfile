FROM centos:7
MAINTAINER Julian Wang <traceflight@outlook.com>

ENV DAQ_VERSION 2.0.6
ENV SNORT_VERSION 2.9.11.1
ENV OPENAPPID_VERSION 8373

ADD rules /etc/snort/rules
ADD custom /etc/snort/appid/custom

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
    cp -R odp /etc/snort/appid/

# update community rules
RUN cd /home/snort/apps && \
    wget https://snort.org/downloads/community/community-rules.tar.gz -O community-rules.tar.gz && \
    tar -xvf community-rules.tar.gz && \
    cp community-rules/* /etc/snort/rules/rules/

# other steps
RUN mkdir /usr/local/lib/snort_dynamicrules && \
    mkdir /usr/local/lib/thirdparty && \
    touch /etc/snort/sid-msg.map && \
    mkdir /var/log/snort && \
    mkdir /var/log/snort/archived_logs && \
    cd /home/snort/apps/snort-${SNORT_VERSION}/etc && \
    cp *.conf* /etc/snort && \
    cp *.map /etc/snort && \
    cp *.dtd /etc/snort

ADD etc/snort.conf /etc/snort/

# Cleanup.
RUN yum clean all && \
    rm -rf /var/tmp/* && \
    rm -rf /tmp/* && \
    rm -rf /home/snort/apps/*.rpm && \
    rm -rf /home/snort/apps/*.gz && \
    snort -V

