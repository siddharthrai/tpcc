# Version: 0.0.1
FROM ubuntu
MAINTAINER Ilya Petukhov <iproha94@tarantool.org>

RUN apt-get update

RUN apt-get install -y -f gcc libc6-dev zlib1g-dev make libmysqlclient-dev
RUN apt-get install -y -f ssh vim git dh-autoreconf pkg-config libicu-dev
RUN apt-get install -y -f build-essential cmake coreutils sed libreadline-dev \
      libncurses5-dev libyaml-dev libssl-dev libcurl4-openssl-dev \
      libunwind-dev python python-pip python-setuptools python-dev \
      python-msgpack python-yaml python-argparse python-six python-gevent

RUN git clone https://github.com/msgpack/msgpack-c.git
RUN cd msgpack-c ; cmake . ; make ; make install ; cd ..

RUN git clone --recursive https://github.com/tarantool/tarantool.git -b 1.8 tarantool
RUN cd tarantool; cmake . -DENABLE_DIST=ON; make; make install; cd ..;

RUN git clone --recursive https://github.com/tarantool/tarantool-c tarantool-c
RUN cd tarantool-c/third_party/msgpuck/; cmake . ; make; make install; cd ../../..;
RUN cd tarantool-c; cmake . ; make; make install; cd ..;

RUN mkdir -p /usr/local/var/lib/tarantool/tpcc-server/
COPY snapshot/ /usr/local/var/lib/tarantool/tpcc-server/

RUN mkdir -p /usr/local/var/run/tarantool