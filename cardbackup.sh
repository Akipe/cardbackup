#!/bin/bash

confirm() {
    echo -e "\n\e[44m$*\e[49m"
    read -p "continue (y/N)?" choice
    case "$choice" in
    y | Y) echo "yes !" ;;
    *) exit 1 ;;
    esac
}


echo -e "\e[93m _____               _  ______            _      _   _        ";
echo "/  __ \             | | | ___ \          | |    | | | |       ";
echo "| /  \/ __ _ _ __ __| | | |_/ / __ _  ___| | __ | | | |_ __   ";
echo "| |    / _\` | '__/ _\` | | ___ \/ _\` |/ __| |/ / | | | | '_ \  ";
echo "| \__/\ (_| | | | (_| | | |_/ / (_| | (__|   <  | |_| | |_) | ";
echo -e "\e[48;5;17m \____/\__,_|_|  \__,_| \____/ \__,_|\___|_|\_\  \___/| .__/  \e[49m";
echo "2020                                                  | |     ";
echo -e "                                                      |_|     \e[39m";


echo -e "\e[44mList of connected medias\e[49m"


list=$(lsblk -lo MOUNTPOINT | grep ^/media)

if [ -z "$list" ]
then
    echo "none :("
else
    lsblk -lo MOUNTPOINT,SIZE,FSTYPE,NAME | grep ^/media
fi

echo -e "\n\e[44mWich one do you want to backup ?\e[49m (type the corresponding number)"

options=$(lsblk -lo MOUNTPOINT | grep ^/media)

select src in $options cancel
do
    test -n "$src" && break
    echo "Device does not exist"
done

if [ $src = "cancel" ]
then
    exit
fi

echo -e "\e[33m"
tree -shn $src
echo "==============================="
du -sh $src
echo -e "\e[39m"

confirm "You are going to backup this card"

echo -e "\e[44mYou can type a folder name inside wich the card will be created, just press enter if you don't\e[49m"

read -p 'Card folder name :' cardname

echo 'card folder name :' $cardname

dir=$(zenity --file-selection --directory 2>/dev/null)

if [[ ! -d $dir ]]
then
    echo "directory does not exist"
    exit
fi

if [[ -n $cardname ]]
then
cdir=$dir'/'$cardname
else
cdir=$dir
fi

# check if there is enought available disk space

confirm "you have choosen the backup directory $dir, card will be copied in $cdir"


echo -e "\e[34m"
rsync -avh --progress --stats --preallocate $src $cdir
echo -e "\e[39m"


./analyse.sh $cdir