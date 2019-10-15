#!/bin/bash

createRepo(){
    read -p "Please enter the name of your new repository: " Repository
    if[ -d "$Repository" ]; then
        mkdir $Repository
        cd $Repository/
        touch log.txt
        mkdir checkedOut 
    else
        echo "can't create a repository with this name"
    fi
    


    


    read -p "Open/Create a new file in this repository? [y/n]" 
}

createFile(){
    #Create File
    echo "Your file will be stored in /Repository"
    touch Repository/"$1.txt"
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
        createRepo()
        ;;
        2)
        read -p "Please enter the name of your file: " filename
        createFile filename 
        ;;
        0)exit 0;;
        *)echo;echo "INVALID INPUT";;
    esac
done