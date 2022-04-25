#!/bin/bash
# Written by Sebastian Neef (@gehaxelt / neef.it), 2022

socat TCP-LISTEN:31337,fork,reuseaddr,pktinfo,pf=ip4 EXEC:./service
