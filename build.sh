#!/bin/sh

set -ex

# Install dependencies
apt-get update
apt-get -y upgrade
apt-get -y install curl unzip

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
npm run build
npm run build-client

# Build the AppImage directory
cd /
mkdir -p MyApp.AppDir/{usr/bin,usr/lib,data/db,var/log,workspaces}
ls -R MyApp.AppDir
cp /usr/bin/mongod MyApp.AppDir/usr/bin
cp /usr/bin/redis-server MyApp.AppDir/usr/bin
cp -r /python3.8.13-cp38-cp38-manylinux2010_x86_64.AppDir MyApp.AppDir
cp -r /workspaces/Sefaria-Project MyApp.AppDir/workspaces
cp /workspaces/assets/AppRun MyApp.AppDir
chmod +x MyApp.AppDir/AppRun
cp /workspaces/assets/MyApp.desktop MyApp.AppDir
cp /workspaces/assets/myapp.png MyApp.AppDir

# Build the AppImage
ls -lrtha
wget "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
chmod a+x appimagetool-x86_64.AppImage
./appimagetool-x86_64.AppImage MyApp.AppDir
ls -lrtha
