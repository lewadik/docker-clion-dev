FROM ubuntu:16.04

########################################################
# Essential packages for remote debugging and login in
########################################################

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    apt-utils gcc g++ openssh-server cmake build-essential gdb gdbserver rsync vim \
    curl python-software-properties xz-utils ruby-full autoconf git libcurl4-openssl-dev \
    libicu-dev libssl-dev libtool ninja-build nodejs pkg-config unzip

ADD . /code
WORKDIR /code

# Taken from - https://docs.docker.com/engine/examples/running_ssh_service/#environment-variables
ADD cmake3.14.sh /cmake3.14.sh
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
#RUN chmod +x cmake3.14.sh && ./cmake3.14.sh
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN curl -fSsL https://dl.bintray.com/boostorg/release/1.66.0/source/boost_1_66_0.tar.gz -o boost.tar.gz \
    && tar xzf boost.tar.gz \
    && mv boost_1_66_0/boost /usr/include \
    && rm -rf boost*
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# 22 for ssh server. 7777 for gdb server.
EXPOSE 22 7777

RUN useradd -ms /bin/bash debugger
RUN echo 'debugger:pwd' | chpasswd

########################################################
# Add custom packages and development environment here
########################################################
RUN git clone https://github.com/TrustWallet/wallet-core.git \
    && cd wallet-core \
    && export PREFIX=/usr/local \
    && tools/install-dependencies
########################################################

CMD ["/usr/sbin/sshd", "-D"]
