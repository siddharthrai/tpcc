#!/usr/bin/env bash

set -e

if [ ! -n "${PATH_TO_BENCHMARKING}" ]; then PATH_TO_BENCHMARKING=$(pwd)/benchmarking/; fi
if [ ! -n "${PATH_TO_TARANTOOL}" ]; then PATH_TO_TARANTOOL="/opt/tarantool"; fi

# build Tarantool
if [ ! -n "${BRANCH}" ]; then BRANCH="1.8"; fi
if [ ! -n "${HEAD_OFFSET}" ]; then HEAD_OFFSET="0"; fi
if [ ! -n "${DCMAKE_BUILD_TYPE}" ]; then DCMAKE_BUILD_TYPE="RelWithDebInfo"; fi
cd ${PATH_TO_TARANTOOL}
git pull origin ${BRANCH}
git checkout ${BRANCH}
git checkout HEAD~${HEAD_OFFSET}
cmake . -DENABLE_DIST=ON  -DCMAKE_BUILD_TYPE=${DCMAKE_BUILD_TYPE} ; make; make install

# define tarantool version
cd ${PATH_TO_BENCHMARKING}
if [ "${BRANCH}" != "1.8" ]; then
    echo "0.0.0-0-"${BRANCH} | tee version.txt
else
    TAR_VER=$(tarantool -v | grep -e "Tarantool" |  grep -oP '\s\K\S*')
    echo ${TAR_VER} | tee version.txt
fi

# run tarantool
cd ${PATH_TO_BENCHMARKING}
numactl --membind=0 --cpunodebind=0 --physcpubind=2 ./run-tarantool-server.sh

# Run tpcc
cd ${PATH_TO_BENCHMARKING}
apt-get install -y -f gdb
echo 3 > /proc/sys/vm/drop_caches
numactl --membind=0 --cpunodebind=0 --physcpubind=3 ./run-test.sh
