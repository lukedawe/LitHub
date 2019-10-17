#!/bin/bash

rollBack(){
    cd backups
    echo BACKUP VERSIONS
    ls 
    echo
    read -p "Please enter the name of the backup version: " repository
    if [ -d $repository ]; then
        cd $repository
        ls 
        read -p "What file would you like to restore?: " restoreFile
        if [ -f $restoreFile ]; then
            cp $restoreFile ../../$restoreFile
            currentTimeDate=`date`
            cd ../..
            echo "$restoreFile RESTORED AT $currentTimeDate" >> $1/log.txt
        fi
    fi
}

zipProject(){
    if [ -d $1 ]; then
        currentTimeDate=`date`
        echo "$1 ARCHIVED AT $currentTimeDate" >> $1/log.txt
        zip -r $1.zip $1
        rm -r $1
        echo
        echo "$1 ZIPPED"
    else
        echo "Directory with this name does not exist"
    fi
}

unzipProject(){
    if [ -f $1.zip ]; then
        unzip $1.zip
        rm $1.zip
        currentTimeDate=`date`
        echo "FILE UNARCHIVED AT $currentTimeDate" >> $1/log.txt
        echo
        echo "FILE UNZIPPED AND ZIP REMOVED"
    else
        echo "Archive with this name does not exist"
    fi
}

updateLog(){
    while true
    do
        read -p "Add an extra comment to the log [y/n]: " answer
        case $answer in
            [Yy]* ) read -p "What is your comment? " comment
                    echo "^^ USER COMMIT COMMENT $comment ^^" >> log.txt
                    break;;
            [Nn]* ) break;;
            * ) echo "Please enter y/n";;
        esac
    done
}

checkOut(){
    ls
    read -p "Please enter the file you would like to checkout: " filename
    if [ -f $filename ]
    then
        cp $filename .checkedOut
        chmod 444 $filename
        currentTimeDate=`date`
        echo "FILE_CHECKED_OUT by $USER $filename $currentTimeDate" >> log.txt
        cd .checkedOut 
        chmod 0744 $filename    
        nano $filename
        chmod 0777 ../$filename
        cp $filename ..
        currentDate=`date +%d-%b-%Y`
        if [ ! -d ../backups/$currentDate ];then
            mkdir ../backups/$currentDate
        fi
        cp $filename ../backups/$currentDate
        rm $filename
        cd ..
        currentTimeDate=`date`
        echo "FILE_CHECKED_IN by $USER $filename on $currentTimeDate and backed to /backups/$currentDate" >> log.txt
        updateLog
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
        mkdir backups

        while true
        do
            read -p "Create a new file in this repository? [y/n]: " answer
            case $answer in
                [Yy]* ) read -p "Filename: " answer
                        createFile $answer
                        break;;
                [Nn]* ) break;;
                * ) echo "Please enter y/n";;
            esac
        done

        cd ..
    else
        echo "can't create a repository with this name (already exists?)"
    fi
}

createFile(){
    #Create File
    if [ ! -f $1 ]
    then
        touch $1
        currentDate=`date`
        echo "CREATED FILE $1 $currentDate" >> log.txt
    else
        echo "This file already exists, enter a unique name"
    fi
}

deleteFile(){
    #Delete file
    if [ -f $1 ]
    then
        while true
        do
            read -p "Are you sure that you would like to remove this file? [y/n]: " answer
            case $answer in
                [Yy]* ) rm $1
                    currentDate=`date`
                    echo "DELETED FILE $1 $currentDate" >> log.txt
                    break;;
                [Nn]* ) break;;
                * ) echo "Please enter y/n";;
            esac
        done
    else
        echo "This file was not found, please make sure that"
        echo "you have entered the name of a file that is valid."
    fi
}

while :
do
    echo
    echo " _________________________________________"
    echo "|Which action would you like to perform?  |"
    echo "|[1] Create new repository                |"
    echo "|[2] Open repository                      |"
    echo "|[3] Archive repository                   |"
    echo "|[4] UnZip repository                     |"
    echo "|[0] Exit                                 |"

    read -p "Enter a Number: " num

    case $num in
        1)createRepo;;
        2)
        echo "POSSIBLE REPOSITORIES"
        ls -d */ | sed -e 's/\/$//' 
        echo
        read -p "Please enter the name of your repository: " repository

        if [ -d "$repository" ]
        then
            cd $repository
            while :
            do
                echo
                echo "REPOSITORY CONTENTS"
                ls
                echo " _________________________________________"
                echo "|Which action would you like to perform?  |"
                echo "|[1] Checkout a file                      |"
                echo "|[2] Create file                          |"
                echo "|[3] Delete file                          |"
                echo "|[4] Show repository                      |"
                echo "|[5] Restore Backup                       |"
                echo "|[0] Close repository                     |"

                read -p "Enter a Number: " num
                case $num in
                    1)checkOut;;
                    2)read -p "Please enter the name of the file: " file
                    createFile $file;;
                    3)read -p "Please enter the name of the file: " file
                    deleteFile $file;;
                    4)echo;ls;;
                    5)rollBack;;
                    0)cd ..;break;;
                    *)echo;echo "INVALID INPUT";;
                esac
            done
        else
            echo "Repository doesn't exist"
        fi
        ;;
        3)
        echo "POSSIBLE REPOSITORIES TO ARCHIVE"
        ls -d */ | sed -e 's/\/$//' 
        echo
        read -p "Please enter the name of the repository you would like to archive: " toZip
        zipProject $toZip
        ;;
        4)
        echo "POSSIBLE ZIPPED FILES"
        ls -1 *.zip | sed -e 's/\.zip$//' 
        echo
        read -p "Please enter the name of the repository you would like to unzip: " unZip
        unzipProject $unZip
        ;;
        0)exit 0;;
        *)echo;echo "INVALID INPUT";;
    esac
done