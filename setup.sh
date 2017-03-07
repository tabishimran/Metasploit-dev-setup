#!/bin/bash

printf "  _                                                       __         \n"
printf " / \    /\         __                          _    __   /_/ __      \n"
printf " | |\  / | _____   \ \            ___   _____ | |  /  \  _   \ \     \n"
printf " | | \/| | | ___\ |- -|   /\     / __\ | -__/ | | | | | | | |- -|    \n"
printf " |_|   | | | _|__  | |_  / -\  __\ \   | |    | |  \__/ | |  | |_    \n"
printf "       |/  |____/  \___\/ /\ \ \___/   \/     \__|      |_\  \___\  \n"
printf "                                                                    \n"
echo
printf "\n  __________________________________________________________________"
printf "\n |                                                                  |"
printf "\n | Metasploit development environment setup script                  |"
printf "\n | Requirements ->                                                  |"
printf "\n |                                                                  |"
printf "\n | You must have a Non-Root user account                            |"
printf "\n | You must have a debian based linux distro                        |"
printf "\n | You must have a github account                                   |"
printf "\n |__________________________________________________________________|"
sleep 2
printf "\n\n[*] Checking if git is installed "
if ! which git > /dev/null; then
	printf "\n[*] Git not found, installing git\n"
	sudo apt install git
else
	printf "\n[*] Git already installed \n"
fi

printf "\n\n[*] Setting up github information \n\n"
printf "  -> Enter your name        : "
read name
printf "  -> Enter github username  : "
read github_username
printf "  -> Enter github email id  : "
read github_email

printf "\n\n[*] Installing Dependencies \n\n"
sudo apt-get -y install \
  autoconf \
  bison \
  build-essential \
  curl \
  git-core \
  libapr1 \
  libaprutil1 \
  libcurl4-openssl-dev \
  libgmp3-dev \
  libpcap-dev \
  libpq-dev \
  libreadline6-dev \
  libsqlite3-dev \
  libssl-dev \
  libsvn1 \
  libtool \
  libxml2 \
  libxml2-dev \
  libxslt-dev \
  libyaml-dev \
  locate \
  ncurses-dev \
  openssl \
  postgresql \
  postgresql-contrib \
  wget \
  xsel \
  zlib1g \
  zlib1g-dev;


printf "\n\n[*] Cloning metasploit framework  \n\n"
mkdir $HOME/gitter
cd $HOME/gitter
git clone https://github.com/rapid7/metasploit-framework.git
cd metasploit-framework

printf "\n\n[*] Setup upstream ? (y/n)   : "
read upch
if [ $upch == "y" ]; then
	printf "\n[*] Setting up upstream "
else
	printf "\n[*] Skipping upstream setup "
fi

printf "\n\n[*] Getting the signing key for the RVM distribution \n"
curl -sSL https://rvm.io/mpapis.asc | gpg --import -

printf "\n\n[*] Getting RVM \n"
curl -L https://get.rvm.io | bash -s stable

printf "\n\n[*] Setting up RVM \n"
source ~/.rvm/scripts/rvm

printf "\n\n[*] Installing ruby \n"
cd ~/git/metasploit-framework
rvm --install .ruby-version

printf "\n\n[*] Bundler \n"
gem install bundler

printf "\n\n[*] Are you using gnome ? (y/n) "
read gch
if [ $gch == "y" ]; then
	printf "\n\n[*] Tweaking gnome to use RVM's version of ruby \n"
	gconftool-2 --set --type boolean /apps/gnome-terminal/profiles/Default/login_shell true
fi

$rbver="$(ruby -v")
printf "\n\n[*] You're now running ruby version %s \n" $rbver

printf "\n\n[*] Installing bundled gems \n"
cd ~/git/metasploit-framework/
bundle install

printf "\n\n[*] Trying to run metasploit \n"
printf "\n[*] This will take a while \n"
./msfconsole -qx "banner; exit"

printf "\n\n[*] Setting up the database for metasploit \n"

