FROM tianon/centos:6.5
MAINTAINER Wildleaf
USER root

RUN yum clean all; \
    rpm --rebuilddb; \
    yum install -y curl which tar sudo openssh-server openssh-clients rsync; \
    yum install -y glibc-common unzip
# update libselinux. see https://github.com/sequenceiq/hadoop-docker/issues/14
RUN yum update -y libselinux

# passwordless ssh
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key; \
	ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key; \
	ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa; \
	cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

ADD ssh_config /root/.ssh/config
RUN chmod 600 /root/.ssh/config; \
	chown root:root /root/.ssh/config; \
	echo "UsePAM no" >> /etc/ssh/sshd_config; \
	echo "Port 2122" >> /etc/ssh/sshd_config
# java
RUN curl -LO 'http://download.oracle.com/otn-pub/java/jdk/8u65-b14/jdk-8u65-linux-x64.rpm' -H 'Cookie: oraclelicense=accept-securebackup-cookie'; \
	rpm -i jdk-8u65-linux-x64.rpm; \
	rm jdk-8u65-linux-x64.rpm 

ENV JAVA_HOME /usr/java/default
ENV PATH $PATH:$JAVA_HOME/bin
RUN rm /usr/bin/java && ln -s $JAVA_HOME/bin/java /usr/bin/java

ADD bash_profile /root/.bash_profile
ADD bootstrap.sh /etc/
RUN chown root:root /etc/bootstrap*.sh; \
	chmod 700 /etc/bootstrap*.sh


ENTRYPOINT ["/etc/bootstrap.sh"]

EXPOSE 80 8080 2122
