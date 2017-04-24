FROM ubuntu:trusty

ENV DEBIAN_FRONTEND noninteractive
ENV ROOTPASSWORD pentaho

# set up ubuntu
RUN apt-get -qq update > /dev/null 2>&1 && \
    apt-get -qq -y install \
        software-properties-common curl unzip \
        ssh net-tools openssh-server socat \
        > /dev/null 2>&1

# sshd
EXPOSE 22
RUN echo "root:$ROOTPASSWORD" | chpasswd && \
    sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    echo "export VISIBLE=now" >> /etc/profile

# Install gosu
ENV GOSU_VERSION 1.9
RUN set -x \
    && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
    && curl -L -o /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
    && curl -L -o /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

# Install java
RUN add-apt-repository ppa:webupd8team/java
RUN apt-get update > /dev/null 2>&1
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get -y install oracle-java8-installer oracle-java8-set-default #ant > /dev/null 2>&1

# Install PDI
WORKDIR /usr/src/app
RUN wget -q "https://kent.dl.sourceforge.net/project/pentaho/Data%20Integration/7.0/pdi-ce-7.0.0.0-25.zip" -O /usr/src/app/app.zip && \
    unzip -qq /usr/src/app/app.zip && \
    rm /usr/src/app/app.zip

# Install newer MySQL connector
RUN curl -Ls "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.41.tar.gz" | \
    tar -xz --strip-components=1 --directory "/usr/src/app/data-integration/lib" "mysql-connector-java-5.1.41/mysql-connector-java-5.1.41-bin.jar"
ENV PATH=/usr/src/app/data-integration:$PATH

WORKDIR /usr/src/app/data-integration

COPY with_app_user /
COPY configure_and_start /
ENTRYPOINT ["/with_app_user", "/configure_and_start"]
