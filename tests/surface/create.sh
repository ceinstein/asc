help(){

    echo
    echo Use the b flag to create the basic surface
    echo Use the C flag to create the C surface
    echo
    exit 1;

}

main(){
    if [ -d $filetype ];
    then
	rm -r $filetype
    fi
    mkdir $filetype
    touch $filetype\_$window.txt

    while read window
    do
	while read prime
	do
	    while read pc
	    do

		if [ -d ../eb_count/$filetype/$prime/$filetype\_$prime\_$window ];
		then

		    printf $pc"\t" &>> $filetype\_$window.txt
		    
		    cd ../eb_count/$filetype/$prime/$filetype\_$prime\_$window


		    k=$(echo PANIC: run aborted: Success | cut -d" " -f1)
		    l=$(echo $(tail -1 $pc.txt | cut -f 3 | cut -d" " -f1))
		    if [ -z $l ];
		    then 
			l=$(echo $(tail -1 $pc.txt | cut -f 3))
		    fi
		    
		    
		    #Include the excited bit count
		    if [ $l = $k ];
		    then

			printf $(tail -4 $pc.txt | head -1 | cut -f3 | xargs)"\t" &>> ../../../../surface/$filetype\_$window.txt
		    else
			printf $(tail -1 $pc.txt | cut -f 3)"\t" &>> ../../../../surface/$filetype\_$window.txt
		    fi
		    #Change the directory to the predictiveness experiment
		    cd ../../../../predictiveness/$filetype/$prime/data
		    
		    #Include the predictiveness
		    printf $(less $filetype\_$prime\_$window.txt | grep "$pc" | cut -d" " -f2)"\t" &>> ../../../../surface/$filetype\_$window.txt
		    
		    cd ../../../../surface
		    
		    printf $window"\t" &>> $filetype\_$window.txt
		    printf $prime"\n" &>> $filetype\_$window.txt
		fi
		
		
		done < ../../statistics/$filetype/$filetype\_loop_pcs.txt
	done < numbers
    done < ../../statistics/$filetype/window_sizes.txt

    rm $filetype\_.txt
    mv $filetype\_*.txt ./$filetype

    cd ./$filetype
    cat *.txt > $filetype\_all.txt
}

while getopts "hbc" FLAG
do
    case $FLAG in
	h)
	    #Calls the help function
	    help
	    ;;
	b)
	    #Creates the basic surface
	    filetype=basic
	    ;;
	c)
	    #Create the C surface
	    filetype=C
	    ;;
    esac
done

#Checks whether the parameters have been properly set
if [ -z $filetype ];
then
    echo Please set the parameters properly
    echo Use the h flag for help
    echo
    exit 1
else
    main
fi
