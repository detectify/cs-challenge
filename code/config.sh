#!/bin/bash
# Written by Sebastian Neef (@gehaxelt / neef.it), 2022

STATICDIR="./static"
TEMPLATESDIR="./templates"
LOGDIR="./logs"
DBDIR="./db"
DBFILE="$DBDIR/db.sqlite"

LOGPATH="$LOGDIR/service.log"

mkdir -p "$STATICDIR" "$TEMPLATESDIR" "$LOGDIR" "$DBDIR"

DEBUG=1
declare -a ALLOWED_HOSTS=("localhost" "*")