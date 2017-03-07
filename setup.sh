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
printf "\n | Requirements                                                     |"
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
fi

printf "\n\n\n[*] Setting up github information \n\n"
printf "  -> Enter your name        : "
read name
printf "  -> Enter github username  : "
read github_username
printf "  -> Enter github email id  : "
read github_email




