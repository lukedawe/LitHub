#!/bin/bash

checkOut(){
    ls
    read -p "Please enter the name of the file that you would like to check out" filename
    if [ -f $filename ]
    then
        cp $filename checkedOut
        chmod 444 $filename
        currentDate=`date`
        echo "FILE_CHECKED_OUT $filename $currentDate" >> log.txt
        cd checkedOut 
        chmod 0744 $filename
        nano $filename
        cp $filename .. 
        cd ..
    else
        echo "A file with this name was not found :()"
    fi
}

createRepo(){
    read -p "Please enter the name of your new repository: " Repository
    if [ ! -d "$Repository" ]
    then
        mkdir $Repository
        cd $Repository/
        touch log.txt
        currentDate=`date`
        echo "REPOSITORYCREATED: $Repository $currentDate" >> log.txt
        mkdir .checkedOut 

        read -p "Open/Create a new file in this repository? [y/n]: " answer
        if [[ $answer =~ ^[Yy]$ ]]
        then
            read -p "Filename to edit: " answer
            touch $answer
            echo "++++++++++++++"
            echo "OPENING EDITOR"
            echo "++++++++++++++"
            echo
            checkOut $answer
        else
            echo "guess not..."
        fi
        cd ..
    else
        echo "can't create a repository with this name (already exists?)"
    fi
}

createFile(){
    #Create File
    if [ -f $1]
    then
        touch $1
    else
        echo "This file already exists, enter a unique name"
    fi
}

while :
do
    echo
    echo " _________________________________________"
    echo "|Which action would you like to perform?  |"
    echo "|[1] Create new repository                |"
    echo "|[2] Create a new file                    |"
    echo "|[0] Exit                                 |"

    read -p "Enter a Number: " num

    case $num in
        1)
        createRepo
        ;;
        2)
        read -p "Please enter the name of your file: " filename
        createFile filename 
        ;;
        0)exit 0;;
        *)echo;echo "INVALID INPUT";;
    esac
done