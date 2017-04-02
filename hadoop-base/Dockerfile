FROM java:openjdk-8
MAINTAINER p4km9y

USER root

# environment variables
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

ENV HADOOP_HOME /usr/local/hadoop
ENV HADOOP_COMMON_HOME /usr/local/hadoop
ENV HADOOP_HDFS_HOME /usr/local/hadoop
ENV HADOOP_MAPRED_HOME /usr/local/hadoop
ENV HADOOP_YARN_HOME /usr/local/hadoop
ENV HADOOP_CONF_DIR /usr/local/hadoop/etc/hadoop
ENV YARN_CONF_DIR /usr/local/hadoop/etc/hadoop
ENV HADOOP_LOG_DIR /var/log/hadoop

# install dev tools
RUN apt-get update
RUN apt-get install -y wget curl tar sudo openssh-server openssh-client rsync vim

# install hadoop
RUN current=http://www.apache.org/dist/hadoop/common/current && \
    ref=$(wget -qO - ${current} | grep -v src\\. | grep -v doc | sed -n 's/.*href="\(hadoop-.*\.gz\)".*/\1/p' | tail -1) && \
    wget -O - ${current}/${ref} | gzip -dc | tar x -C /usr/local -f - && \
    dir=`ls /usr/local | grep hadoop` && \
    ln -s /usr/local/${dir} ${HADOOP_HOME} && \
    chown -R root:root ${HADOOP_HOME}/

# download native support
RUN mkdir -p /tmp/native && \
    curl -Ls http://dl.bintray.com/sequenceiq/sequenceiq-bin/hadoop-native-64-2.7.0.tar | tar -x -C /tmp/native

# passwordless ssh
ADD ssh_config /root/.ssh/config
RUN rm -f /etc/ssh/ssh_host_dsa_key /etc/ssh/ssh_host_rsa_key /root/.ssh/id_rsa && \
	ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key && \
	ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key && \
	ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa && \
	cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys && \
	chmod 600 /root/.ssh/config && \
	chown root:root /root/.ssh/config

# hadoop config
RUN mkdir /var/log/hadoop && \
	mkdir ${HADOOP_HOME}/input && \
	cp ${HADOOP_HOME}/etc/hadoop/*.xml ${HADOOP_HOME}/input && \
    sed -i 's/^\s*\(export\s*JAVA_HOME\s*=.*\)$/#\1/' ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh && \
    sed -i "1iexport JAVA_HOME=${JAVA_HOME}" ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh && \
    sed -i 's/^\s*\(export\s*HADOOP_PREFIX\s*=.*\)$/#\1/' ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh && \
    sed -i 's/^\s*\(export\s*HADOOP_HOME\s*=.*\)$/#\1/' ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh && \
    sed -i 's/^\s*\(export\s*HADOOP_CONF_DIR\s*=.*\)$/#\1/' ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh && \
    sed -i "1iexport HADOOP_PREFIX=${HADOOP_HOME}\nexport HADOOP_HOME=${HADOOP_HOME}\nexport HADOOP_CONF_DIR=${HADOOP_CONF_DIR}" ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh

ADD core-site.xml ${HADOOP_HOME}/etc/hadoop/core-site.xml
ADD hdfs-site.xml ${HADOOP_HOME}/etc/hadoop/hdfs-site.xml
ADD mapred-site.xml ${HADOOP_HOME}/etc/hadoop/mapred-site.xml
ADD yarn-site.xml ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
ADD log4j.properties ${HADOOP_HOME}/etc/hadoop/log4j.properties

# fixing the libhadoop.so like a boss
RUN rm -rf /usr/local/hadoop/lib/native && \
	mv /tmp/native /usr/local/hadoop/lib

# workingaround docker.io build error
RUN ls -la /usr/local/hadoop/etc/hadoop/*-env.sh && \
	chmod +x /usr/local/hadoop/etc/hadoop/*-env.sh && \
	ls -la /usr/local/hadoop/etc/hadoop/*-env.sh

# fix the 254 error code
RUN sed  -i "/^[^#]*UsePAM/ s/.*/#&/"  /etc/ssh/sshd_config && \
	echo "UsePAM no" >> /etc/ssh/sshd_config && \
	echo "Port 2122" >> /etc/ssh/sshd_config

RUN service ssh start && \
    ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh && \
	${HADOOP_HOME}/bin/hdfs namenode -format

# Hdfs ports
EXPOSE 9000 50010 50020 50070 50075 50090
# See https://issues.apache.org/jira/browse/HDFS-9427
EXPOSE 9871 9870 9820 9869 9868 9867 9866 9865 9864
# Mapred ports
EXPOSE 19888
#Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088 8188
#Other ports
EXPOSE 49707 2122
