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
        sudo cp $filename ..
        cd ..
    else
        echo "A file with this name was not found :()"
    fi
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
        #Create File
        read -p "Please enter the name of your file: " filename
        echo "Your file will be stored in /Repository"
        mkdir Repository
        touch Repository/"$filename.txt"

        #Open File?


        ;;
        2)
        checkOut filename
        ;;
        0)exit 0;;
        *)echo;echo "INVALID INPUT";;
    esac
done


