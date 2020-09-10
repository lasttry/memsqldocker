FROM ubuntu
MAINTAINER MemSQL
# this container if deployed separatly from the composer image will not work properly
# password needs to be present during the build of the container
ARG PASSWORD=P@ssword1

RUN apt-get update
RUN apt-get -y install iputils-ping ca-certificates wget sudo gnupg2 openssh-server && \
    apt-get clean
    
RUN wget -O - 'https://release.memsql.com/release-aug2018.gpg'  2>/dev/null | sudo apt-key add - && apt-key list && \
apt-cache policy apt-transport-https && \
sudo apt -y install apt-transport-https && \
echo "deb [arch=amd64] https://release.memsql.com/production/debian memsql main" | sudo tee /etc/apt/sources.list.d/memsql.list && \
sudo apt update && sudo apt -y install memsql-client memsql-toolbox memsql-studio

RUN mkdir /var/run/sshd
RUN echo "root:$PASSWORD" | chpasswd
RUN sed -i 's/#*PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

RUN mkdir /root/.ssh

COPY ./privateKey /root/.ssh/id_rsa
RUN chmod 600 /root/.ssh/id_rsa
COPY ./publicKey /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys
COPY ./startup.sh /

RUN chmod +x /startup.sh

RUN mkdir -p /root/.config/memsql-toolbox/
RUN echo 'user = "root"' >> /root/.config/memsql-toolbox/toolbox.hcl

ENTRYPOINT /startup.sh

