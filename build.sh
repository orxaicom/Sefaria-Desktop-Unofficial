#!/bin/sh

set -e

# Install dependencies
apt-get update
apt-get -y upgrade
apt-get -y install curl unzip

# Install python requirements
curl -OL "https://github.com/Sefaria/Sefaria-Project/archive/refs/heads/master.zip"
unzip master.zip > /dev/null && rm master.zip
mv Sefaria-Project-master Sefaria-Project
cd Sefaria-Project
mkdir log && chmod 777 log
curl -OL "https://github.com/orxaicom/Sefaria-Container-Unofficial/archive/refs/heads/main.zip"
unzip main.zip >/dev/null && rm main.zip
mv Sefaria-Container-Unofficial-main/local_settings.py sefaria && rm -rf Sefaria-Container-Unofficial-main
/python3.8 -m pip install -r requirements.txt
mongod --fork --logpath /var/log/mongodb.log --dbpath /data/db
/python3.8 manage.py migrate

# Install npm modules
npm install
npm run setup
npm run build
npm run build-client

# Debugging
ls -lrtha
