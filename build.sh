#!/bin/sh

set -ex

# Install dependencies
apt-get update
apt-get -y upgrade
apt-get -y install curl unzip fuse file appstream gnupg procps \
                   libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 \
                   libgtk-3-0 libasound2 zip

# Migrate
curl -OL "https://github.com/Sefaria/Sefaria-Project/archive/refs/heads/master.zip"
unzip master.zip > /dev/null && rm master.zip
mv Sefaria-Project-master Sefaria-Project
cd Sefaria-Project
mkdir log && chmod 777 log
curl -OL "https://github.com/orxaicom/Sefaria-Container-Unofficial/archive/refs/heads/main.zip"
unzip main.zip >/dev/null && rm main.zip
mv Sefaria-Container-Unofficial-main/local_settings.py sefaria && rm -rf Sefaria-Container-Unofficial-main
mongod --fork --logpath /var/log/mongodb.log --dbpath /data/db
/python3.8 manage.py migrate

# Install npm modules
npm install
npm run setup
npm run build-client
npm start &
npm run build

# Build the AppImage directory
cd /
mkdir -p Sefaria-Desktop-Unofficial.AppDir/data
mkdir -p Sefaria-Desktop-Unofficial.AppDir/workspaces

# linuxdeploy
curl -OL "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage"
chmod a+x linuxdeploy-x86_64.AppImage

# Mongo
./linuxdeploy-x86_64.AppImage --appimage-extract-and-run --appdir=Sefaria-Desktop-Unofficial.AppDir --executable=/usr/bin/mongod

# Redis
./linuxdeploy-x86_64.AppImage --appimage-extract-and-run --appdir=Sefaria-Desktop-Unofficial.AppDir --executable=/usr/bin/redis-server

# GetText
./linuxdeploy-x86_64.AppImage --appimage-extract-and-run --appdir=Sefaria-Desktop-Unofficial.AppDir --executable=/usr/bin/gettext

# pgrep
./linuxdeploy-x86_64.AppImage --appimage-extract-and-run --appdir=Sefaria-Desktop-Unofficial.AppDir --executable=/usr/bin/pgrep

# Desktop file, Icon and AppRun
./linuxdeploy-x86_64.AppImage --appimage-extract-and-run --appdir=Sefaria-Desktop-Unofficial.AppDir --desktop-file=/workspaces/assets/Sefaria-Desktop-Unofficial.desktop --icon-file=/workspaces/assets/Sefaria-Desktop-Unofficial.png --custom-apprun=/workspaces/assets/AppRun

cp -r /python3.8.13-cp38-cp38-manylinux2010_x86_64.AppDir Sefaria-Desktop-Unofficial.AppDir
sed -i "s;'NAME': '/workspaces;'NAME': './workspaces;" /workspaces/Sefaria-Project/sefaria/local_settings.py
cp -r /workspaces/Sefaria-Project Sefaria-Desktop-Unofficial.AppDir/workspaces
mv /data/db Sefaria-Desktop-Unofficial.AppDir/data

# Build the AppImage
curl -OL "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
chmod a+x appimagetool-x86_64.AppImage
ARCH=x86_64 ./appimagetool-x86_64.AppImage --appimage-extract-and-run Sefaria-Desktop-Unofficial.AppDir && rm -rf Sefaria-Desktop-Unofficial.AppDir
mv Sefaria-Desktop-Unofficial-x86_64.AppImage /workspaces
