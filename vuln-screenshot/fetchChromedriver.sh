#!/bin/bash

cdversion=$(curl -s https://chromedriver.storage.googleapis.com/LATEST_RELEASE)
wget "https://chromedriver.storage.googleapis.com/$cdversion/chromedriver_linux64.zip"
unzip chromedriver_linux64.zip
cp chromedriver /usr/local/bin
