#!/bin/bash

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
NORMAL=$(tput sgr0)


printf "${RED}"
printf "  _                                                       __         \n"
printf " / \    /\         __                          _    __   /_/ __      \n"
printf " | |\  / | _____   \ \            ___   _____ | |  /  \  _   \ \     \n"
printf " | | \/| | | ___\ |- -|   /\     / __\ | -__/ | | | | | | | |- -|    \n"
printf " |_|   | | | _|__  | |_  / -\  __\ \   | |    | |  \__/ | |  | |_    \n"
printf "       |/  |____/  \___\/ /\ \ \___/   \/     \__|      |_\  \___\  \n"
printf "                                                                    \n"
echo
printf "${NORMAL}"
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
printf "\n\n${GREEN}[*] Checking if git is installed ${NORMAL}"
if ! which git > /dev/null; then
	printf "\n${GREEN}[*] Git not found, installing git\n${NORMAL}"
	sudo apt install git
else
	printf "\n\n${GREEN}[*] Git already installed ${NORMAL}"
fi

printf "\n\n${GREEN}[*] Setting up github information \n\n${NORMAL}"
printf "  -> Enter your name        : "
read name
git config --global user.name "$name"
printf "  -> Enter github username  : "
read github_username
git config --global github.user "$github_username"
printf "  -> Enter github email id  : "
read github_email
git config --global user.email "$github_email"

printf "\n\n${GREEN}[*] Installing Dependencies \n\n${NORMAL}"
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


printf "\n\n${GREEN}[*] Cloning metasploit framework  \n${NORMAL}"
mkdir $HOME/git
cd $HOME/git
git clone https://github.com/rapid7/metasploit-framework.git
cd $HOME/git/metasploit-framework

printf "\n\n${GREEN}[*] Setup upstream ? (y/n)   : ${NORMAL}"
read upch
if [ $upch == "y" ]; then
	printf "\n${GREEN}[*] Setting up upstream ${NORMAL}"
	git remote add upstream https://github.com/rapid7/metasploit-framework.git
	git fetch upstream
	git checkout -b upstream-master --track upstream/master
else
	printf "\n${GREEN}[*] Skipping upstream setup ${NORMAL}"
fi

printf "\n\n${GREEN}[*] Getting the signing key for the RVM distribution \n${NORMAL}"
curl -sSL https://rvm.io/mpapis.asc | gpg --import -

printf "\n\n${GREEN}[*] Installing gnupg2 \n${NORMAL}"
sudo apt-get install gnupg2


printf "\n\n${GREEN}[*] Getting RVM \n${NORMAL}"
curl -L https://get.rvm.io | bash -s stable

printf "\n\n${GREEN}[*] Setting up RVM \n${NORMAL}"
source ~/.rvm/scripts/rvm

printf "\n\n${GREEN}[*] Installing ruby \n${NORMAL}"
cd ~/git/metasploit-framework
rvm --install ruby-"$(cat .ruby-version)"

printf "\n\n${GREEN}[*] Bundler \n${NORMAL}"
gem install bundler

printf "\n\n${GREEN}[*] Are you using gnome ? (y/n) ${NORMAL}"
read gch
if [ $gch == "y" ]; then
	printf "\n\n${GREEN}[*] Tweaking gnome to use RVM's version of ruby \n${NORMAL}"
	gconftool-2 --set --type boolean /apps/gnome-terminal/profiles/Default/login_shell true
fi

rbver="$(ruby -v)"
printf "\n\n${GREEN}[*] Current Ruby vesion \n${NORMAL}"
echo  $rbver

printf "\n\n${GREEN}[*] Installing bundled gems \n${NORMAL}"
cd ~/git/metasploit-framework/
bundle install

printf "\n\n${GREEN}[*] Trying to run metasploit \n${NORMAL}"
printf "\n${GREEN}[*] This will take a while \n${NORMAL}"
./msfconsole -qx "banner; exit"

printf "\n\n${GREEN}[*] Setting up the database for metasploit \n${NORMAL}"

printf "\n\n${GREEN}[*] Enter you\'re password           :  ${NORMAL}"
read password
user="$(whoami)"

printf "${GREEN}\n\n[*] Enter a password for postgresql  :  ${NORMAL}"
read pgsqlpassword

echo $password | sudo -kS update-rc.d postgresql enable &&
echo $password | sudo -S service postgresql start &&
cat <<EOF> $HOME/pg-utf8.sql
update pg_database set datallowconn = TRUE where datname = 'template0';
\c template0
update pg_database set datistemplate = FALSE where datname = 'template1';
drop database template1;
create database template1 with template = template0 encoding = 'UTF8';
update pg_database set datistemplate = TRUE where datname = 'template1';
\c template1
update pg_database set datallowconn = FALSE where datname = 'template0';
\q
EOF

sleep 1

sudo -u postgres psql -f $HOME/pg-utf8.sql &&
sudo -u postgres createuser $user -dRS &&
sudo -u postgres psql -c \
  "ALTER USER msfdev with ENCRYPTED PASSWORD '$pgsqlpassword';" &&
sudo -u postgres createdb --owner $user msf_dev_db &&
sudo -u postgres createdb --owner $user msf_test_db &&
cat <<EOF> $HOME/.msf4/database.yml
# Development Database
development: &pgsql
  adapter: postgresql
  database: msf_dev_db
  username: $user
  password: $pgsqlpassword
  host: localhost
  port: 5432
  pool: 5
  timeout: 5

#Production database -- same as dev
production: &production
  <<: *pgsql

#Test database -- not the same, since it gets dropped all the time
test:
  <<: *pgsql
  database: msf_test_db
EOF

printf "\n\n${GREEN}[*] Enabling postgresql on startup ${NORMAL}\n" 
sudo update-rc.d postgresql enable

sudo -sE su postgres
psql
update pg_database set datallowconn = TRUE where datname = 'template0';
\c template0
update pg_database set datistemplate = FALSE where datname = 'template1';
drop database template1;
create database template1 with template = template0 encoding = 'UTF8';
update pg_database set datistemplate = TRUE where datname = 'template1';
\c template1
update pg_database set datallowconn = FALSE where datname = 'template0';
\q

cd $HOME/git/metasploit-framework/
rake db:migrate RAILS_ENV=test

printf "\n\n${GREEN}[*] Finally checking DB connectivity \n${NORMAL}"
./msfconsole -qx "db_status; exit"


