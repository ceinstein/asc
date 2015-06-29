
#Help function
help(){
echo the arguments are h c b and n
echo h for help
echo b to use the basic files
echo c to use the c files
echo n to indicate which prime to use
echo t to train the nets instead of create them
echo l to indicate how many times the training should occur
}


#Main function
create(){
    
    cd ./predictiveness

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
		    counter=0
		    while [ $counter -lt $tcount ];
		    do
			let ech=$counter+1
			#If the net exsits then train it
			if [ -f ./$type/$exec/nets/$type\_$exec\_$pc\_$window.net ];
			then
			    echo Training round $ech
			    echo Training $type\_$pc\_$exec\_$window
						
			    ../../../asc/asc -a $pc/$window ./$type/$exec/nets/$type\_$exec\_$pc\_$window.net ../executables/$type\_$exec &> ./$type/$exec/nets/$pc\_last_train.txt
			    
			    mv ./$type\_$exec.train ./$type/$exec/nets/$type\_$exec\_$pc\_$window.train
			
			    echo Complete!
			    echo
			    let counter=$counter+1
			    else
			    echo $tcount rounds of training are complete!
			    echo
			    exit 1;
			fi
		    done

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
			echo Net creation is complete
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
training=0
while getopts "hcbn:tl:" flag
do
    case $flag in
	h)
	    #calls the help function
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
	l)
	    tcount=$OPTARG
	    ;;
    esac
done

#Checks if a type has been set and a loop argument has been passed
if [ -z $exec ] || [ -z $type ];
then
    echo A proper type and number must be given! Run this script with -h for help
    echo Exitting!
    echo
    exit 1

else

   if [ $training -eq 0 ];
   then
       if [ -n $tcount ];
       then
	 echo Must specify training with the -t flag!
	 exit 1;
       fi
       create
   else
       if [ -z ${tcount+x} ];
       then
	   echo A training amount must be provided!
	   echo Exitting
	   echo
	   exit 1
       else
	   create
       fi
   fi
fi
