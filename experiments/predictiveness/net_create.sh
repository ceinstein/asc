training=0
#Help function
help(){
echo the arguments are h c b and n
echo h for help
echo b to use the basic files
echo c to use the c files
echo n to indicate which prime to use
echo -t to train the nets instead of create them
}


#Main function
create(){

    #Checks that the executable exists                  
    if [ -f ../executables/$type\_$exec ];
	
    then
	while read window
	do
	    
	    while read pc
	    do

		#If training is occuring
		if [ $training -eq 1 ];
		then   

		    #If the net exsits then train it
		    if [ -f ./$type/$exec/nets/$type\_$exec\_$pc\_$window.net ];
		    then
			
			echo Training $type\_$pc\_$exec\_$window
						
			../../../asc/asc -a $pc/$window ./$type/$exec/nets/$type\_$exec\_$pc\_$window.net ../executables/$type\_$exec &> ./$type/$exec/nets/$pc\_last_train.txt
                    
			mv ./$type\_$exec.train ./$type/$exec/nets/$type\_$exec\_$pc\_$window.train
			
			echo Complete!
			echo
		    fi

		#If the nets are being created    
		else

		    #Does not run the system if the program loops less than the window size
		    if [ $(echo "sqrt ( $exec )" | bc) -gt $window ];
		    then
			echo Creating net for $type\_$pc\_$exec\_$window
		  			
			../../../asc/asc -a $pc/$window ../executables/$type\_$exec &> ./$type/$exec/nets/$pc\_last_train.txt
		    
		    
			mv ./$type\_$exec.net ./$type/$exec/nets
			mv ./$type\_$exec.train ./$type/$exec/nets
			mv ./$type/$exec/nets/$type\_$exec.net ./$type/$exec/nets/$type\_$exec\_$pc\_$window.net
			mv ./$type/$exec/nets/$type\_$exec.train ./$type/$exec/nets/$type\_$exec\_$pc\_$window.train

			echo Complete!
			echo
		    else
			echo This program loops less than $window times!
			echo No nets can be created for any more window sizes
			echo Exitting
			echo
			exit 1;
			
		    fi
		fi

	    done < ../../statistics/$type/$type\_loop_pcs.txt;
	done < ../../statistics/$type/window_sizes.txt;
	
	#If the executable does not exist, tell user to change argument                                                                       
    else
	echo there is no associated executable! Change the -n argument!
    fi
    
}

while getopts "hcbn:t" FLAG
do
    case $FLAG in
	h)
	    #Calls the help function
	    help
	    exit 1
	    ;;
	b)
	    #Sets the file type to basic
	    type=basic	    
	    ;;
	c)
	    #Sets the file type to C
	    type=C
	    ;;
	n)
	    #Sets the executable
	    exec=$OPTARG
	    ;;
	t)
	    #Sets the creation to training mode
	    training=1
	    ;;
    esac
done

#Checks if a type has been set and a loop argument has been passed
if [ -z $exec ] || [ -z $type ];
then
    echo A proper type and number must be given! Run this script with -h for help
    exit 1
else
    #Arguments have been properly implemented
       create
fi
