#function to delete a file
deleteFile(){
    #creating an array that assigns folders to an index for easy entering of names
    declare -A array
    i=0
    for item in *
    do
        echo "[$i] $item"
        array[$i]=$item
        let "i =$i+1"
    done
    read -p "Please enter the name of the file: " file 
    if [ -f $file ]
    then
        while true
        do
            read -p "Are you sure that you would like to remove this file? [y/n]: " answer
            case $answer in
                [Yy]* ) rm $file
                    currentDate=`date`
                    echo "DELETED FILE $file by $USER $currentDate" >> log.txt
                    break;;
                [Nn]* ) break;;
                * ) echo "Please enter y/n";;
            esac
        done
    elif [ -f ${array[$file]} ]; then
            len=${#array[@]}
            let "len =$len-1"
            if [[ "$file" > "$len" ]]; then
                echo "Invaild input"
            else
                while true
                do
                    read -p "Are you sure that you would like to remove this file? [y/n]: " answer
                    case $answer in
                        [Yy]* ) rm ${array[$file]}
                            currentDate=`date`
                            echo "DELETED FILE ${array[$file]} by $USER $currentDate" >> log.txt
                            break;;
                        [Nn]* ) break;;
                        * ) echo "Please enter y/n";;
                    esac
                done
            fi
    else
        echo "This file was not found, please make sure that"
        echo "you have entered the name of a file that is valid."
    fi
}
