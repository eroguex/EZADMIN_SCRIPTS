#!/bin/bash
init_colours() { #{{{
    # Use colors, but only if connected to a terminal, and that terminal
    # supports them.
    if which tput >/dev/null 2>&1; then
        ncolors=$(tput colors)
    fi
    if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
        RED="$(tput setaf 1)"
        GREEN="$(tput setaf 2)"
        YELLOW="$(tput setaf 3)"
        BLUE="$(tput setaf 4)"
        BOLD="$(tput bold)"
        NORMAL="$(tput sgr0)"
    else
        RED=""
        GREEN=""
        YELLOW=""
        BLUE=""
        BOLD=""
        NORMAL=""
    fi

    # Only enable exit-on-error after the non-critical colorization stuff,
    # which may fail on systems lacking tput or terminfo
    set -e
} #}}}
show_ezadmin_header() #{{{
{
  #Welcome Message
  printf "${GREEN}"
  echo '  _______  _______  _______  ______   _______    _________ _       '
  echo '(  ____ \/ ___   )(  ___  )(  __  \ (       )   \__   __/( (    /|'
  echo '| (    \/\/   )  || (   ) || (  \  )| () () |      ) (   |  \  ( |'
  echo '| (__        /   )| (___) || |   ) || || || |      | |   |   \ | |'
  echo '|  __)      /   / |  ___  || |   | || |(_)| |      | |   | (\ \) |'
  echo '| (        /   /  | (   ) || |   ) || |   | |      | |   | | \   |'
  echo '| (____/\ /   (_/\| )   ( || (__/  )| )   ( | _ ___) (___| )  \  |'
  echo '(_______/(_______/|/     \|(______/ |/     \|(_)\_______/|/    )_)'
  echo ''
  echo ''
  echo 'Please ensure full backups have been taken prior to running this script.'
  echo ''
  echo 'EZADMIN are not responsible for any loss of data.'
  echo ''
  echo 'p.s. Please report any bugs to http://bugs.ezadm.in.'
  echo ''
  printf "${NORMAL}"
} #}}}
ezadmin_detect_distro() #{{{
{
        export EZADMIN_OS='Unknown'
        export EZADMIN_DISTRIB_ID='Unknown'
        export EZADMIN_DISTRIB_RELEASE='Unknown'
        export EZADMIN_DISTRIB_CODENAME='Unknown'
        export EZADMIN_DISTRIB_DESCRIPTION='Unknown'

        echo 'Just detecting your OS and Distro, one moment please...'
        if [ -e /etc/os-release ]; then
            export EZADMIN_OS='Linux'
            eval `cat /etc/os-release | sed 's/^/export EZADMIN_/g'`
        fi
#        if [ -e /etc/centos-release ]; then
#            export EZADMIN_OS='Linux'
#            export EZADMIN_DISTRIB_ID='Centos'
#            export EZADMIN_DISTRIB_RELEASE=`cat /etc/centos-release | sed 's/CentOS Linux release //g' | sed 's/(Core)//g'`
#            export EZADMIN_DISTRIB_CODENAME='Centos'
#            export EZADMIN_DISTRIB_DESCRIPTION="Linux - Centos $EZADMIN_DISTRIB_RELEASE"
#        elif [ -e /etc/lsb-release ]; then
#            eval `cat /etc/lsb-release | sed 's/^/export EZADMIN_/g'`
#        elif [ -e /etc/debian-version ]; then
#            export EZADMIN_OS='Linux'
#            export EZADMIN_DISTRIB_ID='Debian'
#            export EZADMIN_DISTRIB_RELEASE=`cat /etc/debian-version`
#            export EZADMIN_DISTRIB_CODENAME='Unknown'
#            export EZADMIN_DISTRIB_DESCRIPTION='Unknown'
#        elif uname == "Windows"; then
#            echo "Win"
#        else
#                echo 'Sorry you are on an unsupported OS'
#        fi
} #}}}
ezadmin_display_distro() #{{{
{
        echo "Operating System: $EZADMIN_OS"
        echo "Distro: $EZADMIN_ID"
        echo "Distro version: $EZADMIN_VERSION_ID"
        echo "Distro human readable: $EZADMIN_NAME"
        echo "Distro version human readable: $EZADMIN_PRETTY_NAME"
} #}}}
ezadmin_init() #{{{
{
    init_colours
    show_ezadmin_header
    ezadmin_detect_distro

    if [ "$EZADMIN_ID" == "debian" ] || [ "$EZADMIN_ID" == "ubuntu" ]; then
        export EZADMIN_PKG_INSTALL="apt-get install -y"
    elif [ "$EZADMIN_ID" == "centos" ]; then
        export EZADMIN_PKG_INSTALL="yum install -y"
    elif [ "$EZADMIN_ID" == "arch" ]; then
        export EZADMIN_PKG_INSTALL="pacman -S --noconfirm"
    fi
} #}}}
ezadmin_user_check_backups() #{{{
{
    echo "=========== WARNING ==========="
    echo "Before you use any script from ezadm.in you should ensure that you have a recent working backup of your server."
    echo "Do you have a working backup? (Type 'YES I HAVE A WORKING BACKUP')"
    read WORKINGBACKUP

    if [ "$WORKINGBACKUP" != "YES I HAVE A WORKING BACKUP" ] && [ "$WORKINGBACKUP" != "Q" ]; then
        echo "Please enter: 'YES I HAVE A WORKING BACKUP' or 'Q' if you want to quit"
        ezadmin_user_check_backups
    elif [ "$WORKINGBACKUP" == "Q" ]; then
        exit
    fi
} #}}}

clear
ezadmin_init
ezadmin_display_distro

ezadmin_user_check_backups

declare -A HTOP_PACKAGE=( ["centos"]="" ["ubuntu"]="htop" ["debian"]="htop" ["arch"]="htop")

echo "$EZADMIN_PKG_INSTALL ${HTOP_PACKAGE[$EZADMIN_ID]}"
