#!/bin/bash

createFile(){
    #Create File
    echo "Your file will be stored in /Repository"
    mkdir Repository
    touch Repository/"$1.txt"
}

editFile(){
    Repository/"$1.txt"
}

while :
do
    echo
    echo " _________________________________________"
    echo "|Which action would you like to perform?  |"
    echo "|[1] Create new logged file               |"
    echo "|[2] Open file                            |"
    echo "|[0] Exit                                 |"

    read -p "Enter a Number: " num

    case $num in
        1)
        read -p "Please enter the name of your file: " filename
        createFile filename
        editFile filename
        ;;
        2)
        ;;
        0)exit 0;;
        *)echo;echo "INVALID INPUT";;
    esac
done