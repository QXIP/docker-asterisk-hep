FROM centos:centos6
MAINTAINER Doug Smith <info@laboratoryb.org>
ENV build_date 2015-08-21

RUN yum update -y
RUN yum install kernel-headers gcc gcc-c++ cpp ncurses ncurses-devel libxml2 libxml2-devel sqlite sqlite-devel openssl-devel newt-devel kernel-devel libuuid-devel net-snmp-devel xinetd tar -y

# Get pj project
RUN yum install -y bzip2
RUN mkdir /tmp/pjproject
RUN curl -sf -o /tmp/pjproject.tar.bz2 -L http://www.pjsip.org/release/2.4.5/pjproject-2.4.5.tar.bz2
RUN curl -sf -o /tmp/pjproject.md5 -L http://www.pjsip.org/release/2.4.5/MD5SUM.TXT
RUN md5sum /tmp/pjproject.tar.bz2 | grep $(cat /tmp/pjproject.md5 | grep "tar.bz2" | awk '{print $1}')
RUN tar -xjvf /tmp/pjproject.tar.bz2 -C /tmp/pjproject --strip-components=1
WORKDIR /tmp/pjproject
RUN ./configure --prefix=/usr --libdir=/usr/lib64 --enable-shared --disable-sound --disable-resample --disable-video --disable-opencore-amr 1> /dev/null
RUN make dep 1> /dev/null
RUN make 1> /dev/null
RUN make install
RUN ldconfig
RUN ldconfig -p | grep pj

WORKDIR /

ENV AUTOBUILD_UNIXTIME 123123

# Download asterisk.
# This is an experiment for Asterisk 13
RUN curl -sf -o /tmp/asterisk.tar.gz -L http://downloads.asterisk.org/pub/telephony/certified-asterisk/asterisk-certified-13.1-current.tar.gz
RUN curl -sf -o /tmp/asterisk.md5 -L http://downloads.asterisk.org/pub/telephony/certified-asterisk/asterisk-certified-13.1-current.md5
RUN md5sum /tmp/asterisk.tar.gz | grep $(cat /tmp/asterisk.md5 | awk '{print $1}')

# gunzip asterisk
RUN mkdir /tmp/asterisk
RUN tar -xzf /tmp/asterisk.tar.gz -C /tmp/asterisk --strip-components=1
WORKDIR /tmp/asterisk

# Extra deps.
RUN yum install -y epel-release
RUN yum install -y jansson-devel

# make asterisk.
ENV rebuild_date 2014-10-07
# Configure
RUN ./configure --libdir=/usr/lib64 1> /dev/null
# Remove the native build option
RUN make menuselect.makeopts
# Idea! 
#         menuselect/menuselect --disable BUILD_NATIVE menuselect.makeopts
# from: https://wiki.asterisk.org/wiki/display/AST/Building+and+Installing+Asterisk

# Enable HEP modules
RUN menuselect/menuselect --disable BUILD_NATIVE --enable res_hep --enable res_hep_pjsip --enable res_hep_rtcp menuselect.makeopts
RUN sed -i "s/BUILD_NATIVE//" menuselect.makeopts
# Continue with a standard make.
RUN make 1> /dev/null
RUN make install 1> /dev/null
RUN make samples 1> /dev/null
WORKDIR /

# Update max number of open files.
RUN sed -i -e 's/# MAXFILES=/MAXFILES=/' /usr/sbin/safe_asterisk

ADD start.sh /start.sh
CMD ["/bin/sh", "start.sh"]
