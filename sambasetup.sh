#!/bin/bash
# ~~~~~~~~~~  Environment Setup ~~~~~~~~~~ #
    NORMAL=$(echo "\033[m")
    MENU=$(echo "\033[36m") #Blue
    NUMBER=$(echo "\033[33m") #yellow
    RED_TEXT=$(echo "\033[31m") #Red
    INTRO_TEXT=$(echo "\033[32m") #green and white text
    END=$(echo "\033[0m")
# ~~~~~~~~~~  Environment Setup ~~~~~~~~~~ #

installsamba () {
  clear
  sudo apt-get update
  sudo apt-get install -y samba winbind krb5-user
  mainmenu
  }

installvsftpd () {
  clear
  sudo apt-get update
  sudo apt-get -y install vsftpd
  mainmenu
  }

installwebmin () {
  clear
  wget http://www.webmin.com/download/deb/webmin-current.deb
  sudo apt-get update
  sudo dpkg -i webmin-current.deb
  sudo apt-get -y install -f
  rm webmin-current.deb
  mainmenu
  }

updatesystem () {
  clear
  sudo apt-get update
  sudo apt-get -y dist-upgrade
  echo "Update Complete!"
  echo "It may be wise to restart your computer..."
  read -n 1
  mainmenu
  }

configuresambaforactivedirectory () {
  clear
  sudo service samba stop
  sudo rm /etc/samba/smb.conf
  sudo rm /var/run/samba/*.tdb
  sudo rm /var/lib/samba/*.tdb
  sudo rm /var/cache/samba/*.tdb
  sudo rm /var/lib/samba/private/*.tdb
  sudo rm /var/run/samba/*.ldb
  sudo rm /var/lib/samba/*.ldb
  sudo rm /var/cache/samba/*.ldb
  sudo rm /var/lib/samba/private/*.ldb
  sudo samba-tool domain provision --use-rfc2307 --interactive
  sudo mv /etc/krb5.conf /etc/krb5.conf.bak
  sudo ln -sf /var/lib/samba/private/krb5.conf /etc/krb5.conf
  domaincontrolleryorn
  }

domaincontrolleryorn () {
  clear
  echo "Did you set this installation as a primary domain controller?"
  echo ""
  echo "If you select yes then it will upgrade the forest and domain to"
  echo "Server 2008 R2 levels. This may break compatibility with earlier"
  echo "versions of Windows Server. You can always manually change the levels"
  echo "if you wish... Press wisely!"
  echo ""
read -p "Do you wish to use it (y/n)?" yn
   case $yn in
    [Yy]* ) upgradeforrestanddomain;;

    [Nn]* ) domaincontrolleryesorno;;
    * ) echo 'Please answer yes or no.';;
   esac
}
upgradeforrestanddomain () {
  clear
  sudo samba-tool domain level raise --domain-level=2008_R2
  sudo samba-tool domain level raise --forest-level=2008_R2
  sudo samba-tool domain passwordsettings set --complexity=off
  sudo samba-tool domain passwordsettings set --history-length=0
  sudo samba-tool domain passwordsettings set --min-pwd-age=0
  sudo samba-tool domain passwordsettings set --max-pwd-age=0
  echo "Domain Controller setup has completed!"
  echo ""
  echo "Press any key to return to the main menu..."
  read -n 1
  mainmenu
  }
quitprogram () {
  clear
  echo "Bye"
  exit
  }

mainmenu () {
clear
    echo "${INTRO_TEXT}              Samba setup tool             ${INTRO_TEXT}"
    echo "${INTRO_TEXT}             Created by Pierre Goude                  ${INTRO_TEXT}"
	echo "${INTRO_TEXT} This script will edit several critical files.. ${INTRO_TEXT}"
	echo "${INTRO_TEXT}  DO NOT attempt this without expert knowledge  ${INTRO_TEXT}"
    echo "${NORMAL}                                                    ${NORMAL}"
    echo "${MENU}*${NUMBER} 1)${MENU} Update your system   ${NORMAL}"
    echo "${MENU}*${NUMBER} 2)${MENU} Install samba    ${NORMAL}"
    echo "${MENU}*${NUMBER} 3)${MENU} Install vsFTPd - Depreciated  ${NORMAL}"
    echo "${MENU}*${NUMBER} 4)${MENU} Install the current version of Webmin   ${NORMAL}"
    echo "${MENU}*${NUMBER} 5)${MENU} Configure samba for Active Directory             ${NORMAL}"
    echo "${NORMAL}                                                    ${NORMAL}"
    echo "${ENTER_LINE}Please enter a menu option and enter or ${RED_TEXT}enter to exit. ${NORMAL}"
	read opt
while [ opt != '' ]
    do
    if [ $opt = "" ]; then 
            exit;
    else
        case $opt in
        1) clear;
            echo "Update your system";
            updatesystem;
            ;;

        2) clear;
            echo "Install samba";
            installsamba
            ;;
	3) clear;
	    echo "Install vsFTPd "
	    installvsftpd
            ;;
	4) clear;
	    echo "Install the current version of Webmin "
	     installwebmin
            ;;
	 5) clear;
	     echo "Configure samba for Active Directory"
	     configuresambaforactivedirectory
             ;;
        x)exit;
        ;;

        \n)exit;
        ;;

        *)clear;
        opt "Pick an option from the menu";
        mainmenu;
        ;;
    esac
fi
done
}
mainmenu
