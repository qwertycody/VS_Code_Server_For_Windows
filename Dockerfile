FROM debian:latest

ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY

#Setup Assets Folder
ARG ASSETS_FOLDER
ENV ASSETS_FOLDER ${ASSETS_FOLDER}
COPY ${ASSETS_FOLDER} /root/${ASSETS_FOLDER}

USER root 
RUN chmod 700 -R /root/${ASSETS_FOLDER}

#Set Proxy Credentials Yum Temporarily
ENV HTTP_PROXY ${HTTP_PROXY}
ENV HTTPS_PROXY ${HTTPS_PROXY}
ENV NO_PROXY ${NO_PROXY}

#SSH Server - Install
USER root
RUN apt-get update &&\
    apt-get install -y openssh-server passwd &&\
    mkdir /var/run/sshd &&\
    echo "y" | ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' &&\
    apt-get clean all

#Misc Dependencies - Install
USER root
RUN apt-get update &&\
    apt-get install -y git git-lfs subversion zip openjdk-11-jdk docker.io &&\
    apt-get clean all

#Code Server - Install
USER root
ARG ASSET_CODE_SERVER
RUN tar -xf /root/${ASSETS_FOLDER}/${ASSET_CODE_SERVER} -C /opt/ &&\
    mv /opt/code-server* /opt/code-server &&\
    chmod 700 /opt/code-server/code-server

#Startup Script - Install
USER root
ARG ASSET_STARTUP_SCRIPT
RUN mv /root/${ASSETS_FOLDER}/${ASSET_STARTUP_SCRIPT} /opt/startup.sh &&\
    chmod 700 /opt/startup.sh

#Set Proxy Credentials Yum Temporarily
ENV HTTP_PROXY ""
ENV HTTPS_PROXY ""
ENV NO_PROXY ""

CMD ["bash", "-c", "/opt/startup.sh"]
