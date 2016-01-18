#! /bin/bash
#
# Copyright 2015 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# add Google Chrome source for installation
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
sudo dpkg --add-architecture i386
echo "Updating package lists..."
sudo apt-get -qq update
echo "Installing Gnome desktop environment. Please be patient, this may take a while..."
sudo apt-get install -y -qq gnome-core --no-install-recommends
sudo apt-get install -y -qq google-chrome-stable \
                            git \
                            zip \
                            openjdk-7-jdk \
                            vnc4server \
                            ia32-libs \
                            lib32ncurses5-dev \
                            lib32stdc++6
mkdir .vnc
cat >.vnc/xstartup <<'EOT'
#!/bin/sh
# Uncomment the following two lines for normal desktop:
# unset SESSION_MANAGER
# exec /etc/X11/xinit/xinitrc
[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
xsetroot -solid grey
vncconfig -iconic &
x-terminal-emulator -geometry 80x24+10+10 -ls -title "$VNCDESKTOP Desktop" &
gnome-session &
EOT
chmod u+x .vnc/xstartup
# Modify the PATH variable for all users to include App Engine SDK
# First for Gnome terminal
echo PATH=$PATH:/opt/google/google_appengine >> .bashrc
# Then for SSH connecitons
sudo bash -c "echo PATH=$PATH:/opt/google/google_appengine >> /etc/profile.d/env_vars.sh"
# enable password based SSH authentication for VNC
sudo sed -i 's|[#]*PasswordAuthentication no|PasswordAuthentication yes|g' /etc/ssh/sshd_config
sudo /etc/init.d/ssh restart
# create a VNC linux user
sudo useradd -s /bin/bash -m -d /home/vnc vnc
