#function to check a file out for editing
checkOut(){
    #prints out all the files and lets the user select which one to check out
    #creating an array that assigns folders to an index for easy entering of names
    declare -A array
    i=0
    for file in *
    do
        echo "[$i] $file"
        array[$i]=$file
        let "i =$i+1"
    done

    read -p "Please enter the file you would like to checkout: " filename
    if [ -f $filename ]
    then
    #copies the file to the checkedOut folder, sets the permissions of the original file
    #to read only, adds this to the log and selects the checkedOut folder, sets the permissons
    #of the checked out file to editable for the user but read only for the group and other.
        cp $filename .checkedOut
        chmod 444 $filename
        currentTimeDate=`date`
        echo "FILE_CHECKED_OUT by $USER $filename $currentTimeDate" >> log.txt
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
        echo "FILE_CHECKED_IN by $USER $filename on $currentTimeDate and backed to /backups/$currentDate" >> log.txt
        updateLog
     #allows user to enter index number of folder
    elif [ -f ${array[$filename]} ]; then
        len=${#array[@]}
        let "len =$len-1"
            if [[ "$filename" > "$len" ]]; then
                echo "Invaild input"
                cd ..
            else
            cp ${array[$filename]} .checkedOut
            chmod 444 ${array[$filename]}
            currentTimeDate=`date`
            echo "FILE_CHECKED_OUT by $USER ${array[$filename]} $currentTimeDate" >> log.txt
            cd .checkedOut 
            chmod 0744 ${array[$filename]}   
            #lets the user edit the file and once the user saves the changes, sets the permissions
            #for the original file to rwx and copies it outside of the file.
            #backs up the file and removes the file from the checkedOut folder.
            nano ${array[$filename]}
            chmod 0777 ../${array[$filename]}
            cp ${array[$filename]} ..
            currentDate=`date +%d-%b-%Y`
                if [ ! -d ../backups/$currentDate ];then
                    mkdir ../backups/$currentDate
                fi
            cp ${array[$filename]} ../backups/$currentDate
            rm ${array[$filename]}
            cd ..
            currentTimeDate=`date`
            #updates the log and allows the user to add a comment
            echo "FILE_CHECKED_IN by $USER ${array[$filename]} on $currentTimeDate and backed to /backups/$currentDate" >> log.txt
            updateLog
            fi
        
    else
        echo "A file with this name was not found :()"
    fi
}
