FROM ubuntu:22.04

ARG VSCODE_BIN_PATH
ARG GIT_BIN_PATH
ARG DEFAULT_USER
ARG DEFAULT_USER_PASSWORD
ARG TZ
ARG HOSTNAME
ARG GO_VERSION

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && \
    apt-get install -y software-properties-common && \
    apt-get install -y wget curl unzip vim && \
    apt-get install -y init systemd && \
    apt-get install -y mysql-server && \
    add-apt-repository -y ppa:longsleep/golang-backports && \
    apt-get update
RUN apt-get install -y golang-$GO_VERSION && \
    apt-get install -y sudo

#  user
RUN adduser $DEFAULT_USER && \
    usermod -aG sudo $DEFAULT_USER && \
    echo $DEFAULT_USER:$DEFAULT_USER_PASSWORD | chpasswd

# DB
ARG DB_USER
ARG DB_USER_PASSWORD
RUN service mysql start && \
    mysql -uroot -p -e "create user '${DB_USER}'@'localhost' identified by '${DB_USER_PASSWORD}';" && \
    mysql -uroot -p -e "grant all on *.* to '${DB_USER}'@'localhost';"

# vscode & git
RUN echo "\n\
alias code='/mnt${VSCODE_BIN_PATH}'\n\
alias git='/mnt${GIT_BIN_PATH}'\n\
" >> /home/$DEFAULT_USER/.bashrc

# go setting
RUN ln -s /usr/lib/go-$GO_VERSION/bin/go /usr/bin/go && \
    ln -s /usr/lib/go-$GO_VERSION/bin/gofmt /usr/bin/gofmt

# wsl
COPY server_files/configure/wsl.conf /etc/wsl.conf
RUN chmod 644 /etc/wsl.conf
RUN echo "\n\
[user]\n\
default=${DEFAULT_USER}\n\
[network]\n\
hostname=${HOSTNAME}\n\
" >> /etc/wsl.conf

COPY server_files/configure/initialize.sh /initialize.sh
