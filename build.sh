#!/bin/sh

set -ex

# Install dependencies
apt-get update
apt-get -y upgrade
apt-get -y install curl unzip fuse file appstream gnupg procps

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
mongod --shutdown --logpath /var/log/mongodb.log --dbpath /data/db

# Install npm modules
npm install
npm run setup
npm run build-client
npm start &
npm run build

# Build the AppImage directory
cd /
mkdir -p MyApp.AppDir/usr/bin
mkdir -p MyApp.AppDir/usr/lib
mkdir -p MyApp.AppDir/data
mkdir -p MyApp.AppDir/var/log
mkdir -p MyApp.AppDir/workspaces

# Mongo
cp /usr/bin/mongod MyApp.AppDir/usr/bin
ldd /usr/bin/mongod | grep "=> /" | awk '{print $3}' | xargs -I {} cp {} MyApp.AppDir/usr/lib/

# Redis
cp /usr/bin/redis-server MyApp.AppDir/usr/bin
ldd /usr/bin/redis-server | grep "=> /" | awk '{print $3}' | xargs -I {} cp {} MyApp.AppDir/usr/lib/

# gettext
cp /usr/bin/gettext MyApp.AppDir/usr/bin
ldd /usr/bin/gettext | grep "=> /" | awk '{print $3}' | xargs -I {} cp {} MyApp.AppDir/usr/lib/
mkdir MyApp.AppDir/usr/lib/x86_64-linux-gnu
cp -r /usr/lib/x86_64-linux-gnu/gettext MyApp.AppDir/usr/lib/x86_64-linux-gnu
cp /usr/lib/x86_64-linux-gnu/libgettextlib-0.21.so MyApp.AppDir/usr/lib/x86_64-linux-gnu
cp /usr/lib/x86_64-linux-gnu/libgettextsrc-0.21.so MyApp.AppDir/usr/lib/x86_64-linux-gnu

cp -r /python3.8.13-cp38-cp38-manylinux2010_x86_64.AppDir MyApp.AppDir
sed -i "s;'NAME': '/workspaces;'NAME': './workspaces;" /workspaces/Sefaria-Project/sefaria/local_settings.py
cp -r /workspaces/Sefaria-Project MyApp.AppDir/workspaces
cp /workspaces/assets/AppRun MyApp.AppDir
chmod +x MyApp.AppDir/AppRun
cp /workspaces/assets/MyApp.desktop MyApp.AppDir
cp /workspaces/assets/myapp.png MyApp.AppDir
mv /data/db MyApp.AppDir/data

cp /usr/lib/x86_64-linux-gnu/libatomic.so.1 MyApp.AppDir/usr/lib/x86_64-linux-gnu

# Final migrate
cd MyApp.AppDir
./usr/bin/mongod --fork --logpath /var/log/mongodb.log --dbpath ./data/db
./python3.8.13-cp38-cp38-manylinux2010_x86_64.AppDir/opt/python3.8/bin/python3.8 ./workspaces/Sefaria-Project/manage.py migrate
cd /

# Build the AppImage
#curl -OL "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
#chmod a+x appimagetool-x86_64.AppImage
#ARCH=x86_64 ./appimagetool-x86_64.AppImage --appimage-extract-and-run MyApp.AppDir && rm -rf MyApp.AppDir
mv MyApp-x86_64.AppImage /workspaces

# Build Electron
mkdir sefaria-electron
cd sefaria-electron
npm init -y
npm install electron --save-dev
cp /workspaces/assets/main.js .
ls -lrtha
echo "===================================================="
cat package.json
