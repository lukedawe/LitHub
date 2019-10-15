#!/bin/bash

updateLog(){
    read -p "Add an extra comment to the log [y/n]: " answer
    echo
        if [[ $answer =~ ^[Yy]$ ]]
        then
            read -p "What is your comment? " comment
            echo
            echo "$comment" >> log.txt
        else
            echo "guess not..."
        fi
}

checkOut(){
    ls
    read -p "Please enter the file you would like to checkout: " filename
    if [ -f $filename ]
    then
        cp $filename .checkedOut
        chmod 444 $filename
        currentDate=`date`
        echo "FILE_CHECKED_OUT by $User $filename $currentDate" >> log.txt
        cd .checkedOut 
        chmod 0744 $filename    
        nano $filename
        cp $filename ..
        echo "FILE_CHECKED_IN $filename $currentDate" >> log.txt
        updateLog
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
            read -p "Filename: " answer
            touch $answer
            echo
            echo "FILES IN REPO $Repository"
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
    echo "|[2] Open repository                      |"
    echo "|[0] Exit                                 |"

    read -p "Enter a Number: " num

    case $num in
        1)
        createRepo
        ;;
        2)
        read -p "Please enter the name of your repository: " answer

        if [-d "$answer" ]
        then

            echo " _________________________________________"
            echo "|Which action would you like to perform?  |"
            echo "|[1] Checkout a file                      |"
            echo "|[2] Ammend Log                           |"
            echo "|[0] Exit                                 |"

            read -p "Enter a Number: " num
            
            ;;
            0)exit 0;;
            *)echo;echo "INVALID INPUT";;
    esac
done
