#!/bin/bash

python admin-app.py &

uwsgi app.ini