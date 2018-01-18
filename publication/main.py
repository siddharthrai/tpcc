#!/usr/bin/env python

import os
import sys
from urllib import urlencode
import requests

def parse_bench(filename):
    fileHandle = open(filename)
    lastline = fileHandle.readlines()[-1]
    fileHandle.close()
    return lastline.split()[0]

def get_version(filename):
    fileHandle = open(filename)
    lastline = fileHandle.readlines()[-1]
    fileHandle.close()
    return lastline.split()[0]

def push_to_grafana(server, port, name, value, version, unit='trps', db='sysbench'):
    if "BRANCH" in os.environ:
        branch_name = os.environ['BRANCH']
    else:
        branch_name = "1.8"

    if "THREADS" in os.environ:
        threads = os.environ['THREADS']
    else:
        threads = "1"

    if "TIME" in os.environ:
        time = os.environ['TIME']
    else:
        time = "220"

    if "DCMAKE_BUILD_TYPE" in os.environ:
        build = os.environ['DCMAKE_BUILD_TYPE']
    else:
        build = "RelWithDebInfo"

    url_string = 'http://{}:{}/write?db={}'.format(server, port, db)
    data_string = '{},version={},branch={},threads={},duration={},build={} value={}'.format(
        name,
        version,
        branch_name,
        threads,
        time,
        build,
        value,
    )

    r = requests.post(
        url_string,
        data=data_string
    )

    if r.status_code == 204:
        print 'Export to grafana complete'
    else:
        print 'Export to grafana error http: %d' % r.status_code

def push_to_microb(server, token, name, value, version, unit='trps', tab='tpcc'):
    uri = 'http://%s/push?%s' % (server, urlencode(dict(
        key=token, name=name, param=value,
        v=version, unit=unit, tab=tab
    )))

    r = requests.get(uri)
    if r.status_code == 200:
        print 'Export complete'
    else:
        print 'Export error http: %d' % r.status_code

def main():
    if len(sys.argv) < 3:
        print('Usage:\n./main.py [benchmarks-results.file] [tarantool-version.file]')
        exit(-1)

    value = parse_bench(sys.argv[1])
    version = get_version(sys.argv[2])

    # push bench data to microb-server
    if "MICROB_WEB_TOKEN" in os.environ and \
        "MICROB_WEB_HOST" in os.environ:
        push_to_microb(
            os.environ['MICROB_WEB_HOST'],
            os.environ['MICROB_WEB_TOKEN'],
            "tpcc",
            value,
            version
        )
    else:
        print("MICROB params not specified")

    # push bench data to microb-server
    if "GRAFANA_WEB_HOST" in os.environ and \
        "GRAFANA_WEB_PORT" in os.environ:
        for value in values:
            push_to_grafana(
                os.environ['GRAFANA_WEB_HOST'],
                os.environ['GRAFANA_WEB_PORT'],
                "tpcc",
                value,
                version
            )
    else:
        print("GRAFANA params not specified")

    return 0

if __name__ == '__main__':
    main()