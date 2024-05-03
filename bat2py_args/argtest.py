#!/usr/local/bin/python3

import sys

if __name__ == '__main__':
    print('len_args:%s' % len(sys.argv))

    i = 0
    for i in range(0, len(sys.argv), 1):
        print('arg[%s]:%s' % (i, sys.argv[i]))
