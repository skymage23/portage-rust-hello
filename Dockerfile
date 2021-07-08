FROM debian
RUN apt-get update
RUN apt-get upgrade -y

#Install tzdata:
#RUN DEBIAN_FRONTEND="noninteractive"; TZ="America/Chicago" apt-get -y install tzdata

#Install build tools.
RUN apt-get install -y build-essential python2 python-setuptools python3 python3-setuptools dpkg

#Install Rust:
#RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

RUN update-alternatives --install /usr/bin/python \
python /usr/bin/python3 1

#Install
RUN apt-get install -y vim
