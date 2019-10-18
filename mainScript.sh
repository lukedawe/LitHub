#!/bin/bash

makeNewBranch(){
    echo "List of existing branches"
    find .. -mindepth 1 -maxdepth 1 -type d
    read -p "Please enter the name of the branch you would like to branch out from: " branch
    if [ -d ../$branch ]; then
        read -p "Please enter the name of the new branch: " newBranch
        if [ ! -d ../$newBranch ]; then
            cp -r ../$branch ../$newBranch
            currentBranch=$newBranch
            cd ../$newBranch
            currentTimeDate=`date`
            echo "BRANCH $newBranch CREATED BY $USER AT $currentTimeDate" >> ../log.txt
        else
            echo "This branch already exists, please enter a name that is not the same as an existing branch"
        fi
    else
        echo "This branch does not exist, please try again and make sure you enter a valid branch name"
    fi
}

mergeBranch(){
    echo "List of existing branches"
    find .. -mindepth 1 -maxdepth 1 -type d
    read -p "Please enter the name of the branch you would like to merge into: " keepBranch
    read -p "Please enter the name of the branch you would like to merge (this branch will be automatically deleted): " deleteBranch
    if [ -d ../$keepBranch ] && [ -d ../$deleteBranch ]; then
        rm -r ../$keepBranch/*
        cp -r ../$deleteBranch/. ../$keepBranch
        cd ..
        rm -r $deleteBranch
        currentBranch=$keepBranch
        cd $keepBranch
    else
        echo "One of the referenced branches does not exist"
    fi
}

selectBranch(){
    echo 
    echo "List of directories outside of the current branch"
    find .. -mindepth 1 -maxdepth 1 -type d
    read -p "Please enter the name of the branch you would like to select: " selectedBranch
    if [ -d ../$selectedBranch ]; then
        cd ../$selectedBranch
        currentBranch=$selectedBranch
    else
        echo "This branch does not exist"
    fi
}

deleteBranch(){
    echo "List of branches"
    cd ..
    ls -d */ | sed -e 's/\/$//' 
    read -p "Please enter the name of the branch you would like to delete: " branchToDelete
    if [ $branchToDelete = "master" ]; then
        echo
        echo "MASTER CANNOT BE DELETED"
        cd master
        return
    fi
    if [ -d $branchToDelete ]; then
        while true
        do
            read -p "Are you sure that you would like to remove the branch $branchToDelete?[y/n]: " answer
            case $answer in
                [Yy]* ) rm -r $branchToDelete
                    currentDate=`date`
                    echo "DELETED BRANCH $branchToDelete by $USER AT $currentDate" >> log.txt
                    break;;
                [Nn]* ) break;;
                 * ) echo "Please enter y/n";;
            esac
        done
            
    else
        echo "A branch of that name does not exist"
    fi
    cd master
    selectBranch
}

#function to restore from backup
rollBack(){
    #select the backup folder and print off the contents
        cd backups
    echo BACKUP VERSIONS
    #creating an array that assigns folders to an index for easy entering of names
    declare -A array
    i=0
    for file in *
    do
        echo "[$i] $file"
        array[$i]=$file
        let "i =$i+1"
    done
    echo

    #allows user to name of folder
    read -p "Please enter the name of the backup version: " repository
    if [ -d $repository ]; then
            cd $repository
            ls 
            read -p "What file would you like to restore?: " restoreFile
            if [ -f $restoreFile ]; then
                cp $restoreFile ../../$restoreFile
                currentTimeDate=`date`
                cd ../..
                echo "$restoreFil*/e RESTORED BY $USER AT $currentTimeDate IN $currentBranch" >> ../log.txt
            else
                echo "That file doesn't exist, returning to menu..."
            fi
    #allows user to enter index number of folder
    elif [ -d ${array[$repository]} ]; then
            len=${#array[@]}
            let "len =$len-1"
            if [[ "$repository" > "$len" ]]; then
                echo "Invaild input"
                cd ..
            else
                cd ${array[$repository]}
                ls 
                read -p "What file would you like to restore?: " restoreFile
                if [ -f $restoreFile ]; then
                    cp $restoreFile ../../$restoreFile
                    currentTimeDate=`date`
                    cd ../..
                    echo "$restoreFile RESTORED BY $USER AT $currentTimeDate IN $currentBranch" >> ../log.txt
                else
                    echo "That file doesn't exist, returning to menu..."
                fi
            fi
    else
        echo "Backup version does not exist"
        cd ..
    fi
}

#function to make an archive of a repository or file
zipProject(){
    if [ -d $1 ]; then
        #make a zip file of the directory or file and add that to the log
        currentTimeDate=`date`
        echo "$1 ARCHIVED BY $USER AT $currentTimeDate" >> $1/log.txt
        zip -r $1.zip $1
        rm -r $1
        echo
        echo "$1 ZIPPED"
    else
        echo "Directory with this name does not exist"
    fi
}

#function tounarchive a project
unzipProject(){
    #unzip the file and remove the archived version
    #update the log file
    if [ -f $1.zip ]; then
        unzip $1.zip
        rm $1.zip
        currentTimeDate=`date`
        echo "FILE UNARCHIVED BY $USER AT $currentTimeDate " >> $1/log.txt
        echo
        echo "FILE UNZIPPED AND ZIP REMOVED"
    else
        echo "Archive with this name does not exist"
    fi
}

#function for the user to add a comment to the log file
updateLog(){
    #lets the user select whether they want to update the log
    #with a comment then (if user chooses to) adds the comment
    #to the log file.
    while true
    do
        read -p "Add an extra comment to the log [y/n]: " answer
        case $answer in
            [Yy]* ) read -p "What is your comment? " comment
                    echo "USER COMMIT COMMENT BY $USER $comment" >> ../log.txt
                    break;; 
            [Nn]* ) break;; 
            * ) echo "Please enter y/n";;
        esac 
    done
}

backup(){
    currentDate=`date +%d-%b-%Y`
        if [ ! -d ../backups/$currentDate ];then
            mkdir ../backups/$currentDate
        fi
        cp -r $1 backups/$currentDate
}

#function to check a file out for editing
checkOut(){
    #prints out all the files and lets the user select which one to check out
    ls
    read -p "Please enter the file you would like to checkout: " filename
    if [ -f $filename ]
    then
    #copies the file to the checkedOut folder, sets the permissions of the original file
    #to read only, adds this to the log and selects the checkedOut folder, sets the permissons
    #of the checked out file to editable for the user but read only for the group and other.
        cp $filename .checkedOut
        chmod 444 $filename
        currentTimeDate=`date`
        echo "FILE_CHECKED_OUT BY $USER $filename AT $currentTimeDate IN $currentBranch" >> ../log.txt
        cd .checkedOut 
        chmod 0744 $filename    
        #lets the user edit the file and once the user saves the changes, sets the permissions
        #for the original file to rwx and copies it outside of the file.
        #backs up the file and removes the file from the checkedOut folder.
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
        #updates the log and allows the user to add a comment
        echo "FILE_CHECKED_IN BY $USER $filename AT $currentTimeDate AND BACKED TO /backups/$currentDate IN $currentBranch" >> ../log.txt
        updateLog
    else
        echo "A file with this name was not found :()"
    fi
}

#allows the user to create a repository
createRepo(){
    #checks if the repository already exists, if it does not then creates the 
    #directory with the default files and folders then updates the log.
    read -p "Please enter the name of your new repository: " Repository
    if [ ! -d "$Repository" ]
    then
        mkdir $Repository
        cd $Repository/
        mkdir master
        touch log.txt
        currentBranch=master
        currentDate=`date`
        echo "REPOSITORYCREATED BY $USER IN $Repository AT $currentDate" >> log.txt
        mkdir master/.checkedOut
        mkdir master/backups
        #allows the user to create a file in that new repository
        while true
        do
            read -p "Create a new file in this repository? [y/n]: " answer
            case $answer in
                [Yy]* ) read -p "Filename: " answer
                        cd master
                        createFile $answer
                        cd ..
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

#a function to create a new file in a selected repository
createFile(){
    #Create File
    #if the file does not already exist, create a new file of a specified name.
    if [ ! -f $1 ]
    then
        touch $1
        currentDate=`date`
        echo "CREATED FILE  $1 BY $USER AT $currentDate IN $currentBranch" >> ../log.txt
    else
        echo "This file already exists, enter a unique name"
    fi
}

#function to delete a file
deleteFile(){
    if [ -f $1 ]
    then
        while true
        do
            read -p "Are you sure that you would like to remove this file? [y/n]: " answer
            case $answer in
                [Yy]* ) rm $1
                    currentDate=`date`
                    echo "DELETED FILE $1 by $USER AT $currentDate IN $currentBranch" >> ../log.txt
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

#function to delete a repository
deleteRepo(){
    #if the directory exists, asks the user if they are sure that they want to remove the directory.
    #then removes the directory recursively.
    if [ -d $1 ]
    then
        while true
        do
            read -p "Are you sure that you would like to remove this repository? [y/n]: " answer
            case $answer in
                [Yy]* ) rm -r $1
                    break;;
                [Nn]* ) break;;
                * ) echo "Please enter y/n";;
            esac
        done
    else
        #if the directory is not found, gives the user an error message
        echo "This repository was not found, please make sure that"
        echo "you have entered the name of a repository that is valid."
    fi
}

#menu
while :
do
    echo
    echo " _________________________________________"
    echo "|Which action would you like to perform?  |"
    echo "|[1] Create new repository                |"
    echo "|[2] Open repository                      |"
    echo "|[3] Archive repository                   |"
    echo "|[4] UnZip repository                     |"
    echo "|[5] Delete repository                    |"
    echo "|[0] Exit                                 |"

    read -p "Enter a Number: " num

    case $num in
        1)createRepo;;
        2)
        #prints the possible repositories, if it exists then prints off a second menu
        echo
        echo "POSSIBLE REPOSITORIES"
        ls -d */ | sed -e 's/\/$//' 
        echo
        read -p "Please enter the name of your repository: " repository
        if [ -d "$repository" ];then
            cd $repository
            echo "List of available branches"
            ls -d */ | sed -e 's/\/$//'
            echo
            read -p "Please enter the name of the branch you would like to enter: " chosenBranch
            if [ -d $chosenBranch ] && [ "$chosenBranch" != "" ];then
                cd $chosenBranch
                currentBranch=$chosenBranch
                while :
                do
                    echo
                    echo "BRANCH CONTENTS $currentBranch"
                    ls
                    echo " _________________________________________"
                    echo "|Which action would you like to perform?  |"
                    echo "|[1] Checkout a file                      |"
                    echo "|[2] Create file                          |"
                    echo "|[3] Delete file                          |"
                    echo "|[4] Show branch contents                 |"
                    echo "|[5] Restore backup                       |"
                    echo "|                                         |"
                    echo "|[6] Create new branch                    |"
                    echo "|[7] Merge branch                         |"
                    echo "|[8] Select branch                        |"
                    echo "|[9] Delete branch                        |"
                    echo "|[0] Close repository                     |"
                    read -p "Enter a Number: " num
                    case $num in
                        1)checkOut
                        ;;
                        2)
                        ls
                        read -p "Please enter the name of the file: " file
                        createFile $file
                        ;;
                        3)
                        ls
                        read -p "Please enter the name of the file: " file
                        deleteFile $file;;
                        4)echo;ls;;
                        5)rollBack;;
                        6)
                        makeNewBranch
                        ;;
                        7)
                        mergeBranch
                        ;;
                        8)
                        selectBranch
                        ;;
                        9)
                        deleteBranch
                        ;;
                        0)cd ../..;break;;
                        *)echo;echo "INVALID INPUT";;
                    esac
                done    
            else
                echo "A branch with this name does not exist"
                cd ..
            fi
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
        5)
        echo "POSSIBLE REPOSITORIES TO DELETE"
        ls -d */ | sed -e 's/\/$//' 
        echo
        read -p "Please enter the name of the repository you would like to delete: " repoToDelete
        deleteRepo $repoToDelete
        ;;
        0)exit 0;;
        *)echo;echo "INVALID INPUT";;
    esac
done
