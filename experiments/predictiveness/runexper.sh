#Help function
help(){
echo the arguments are h c b and n
echo h for help
echo b to use the basic files
echo c to use the c files
echo n to indicate which prime to use
echo m to create a plot of all the data
echo o to not run the main experiment 
echo "---->" use with m to only create a plot
}

create(){
    filename=$filetype\_$exec\_$window_size
    executable=$filetype\_$exec
    counter=0
  
  if [ -f ../executables/$executable ];
  then
      
      #Loops for each window size
      cd ../../../asc;
      while read window;
      do
	  if [ $(echo "sqrt ( $exec )" | bc) -gt $window ];
	  then
	      #Removes a previous version of the file since the experiment is being redone
	      cd ../ubasicexper/experiments/predictiveness
	      rm -r $filetype/$exec/$executable\_$window
	      mkdir $executable\_$window
	      cd ../../../asc
	      #Changes the directory to asc for convenience                                                                                                                                   
      	      #Reads in the file of pcs                                                                                                                                                       
	      while read line;
	      
	      #Runs the file in asc and puts the output into a file                                                                                                                           
	      do
		  echo Running experiment on $executable\_$line\_$window
		  if [ -f ../ubasicexper/experiments/predictiveness/$filetype/$exec/nets/$executable\_$line\_$window.net ];
		  then
		      ./asc -a $line/$window ../ubasicexper/experiments/predictiveness/$filetype/$exec/nets/$executable\_$line\_$window.net ../ubasicexper/experiments/executables/$executable &> ../ubasi\
cexper/experiments/predictiveness/$executable\_$window/$line.txt;
		  
		  else
		      echo There is no net for $executable\_$line\_$window
		      echo This experiment has not been properly set up
		      echo Create and train nets before running the experiment
		      echo Refer to the README for more information
		      cd ../ubasicexper/experiments/predictiveness
		      rm -r $executable\_$window
		      echo Exitting
		      echo
		      exit 1;
		  fi
		  #Puts the PC name into the data file                                                                                                                                        
		  printf $line" " >> ../ubasicexper/experiments/predictiveness/$filename.txt;
		  counter=$((counter + 1))
		  
		  #Takes the last line in the PC file and puts the excited bit count into the data file                                                                                           
		  let num=$(grep "+" ../ubasicexper/experiments/predictiveness/$executable\_$window/$line.txt -c);
		  let den=$(tail -1 ../ubasicexper/experiments/predictiveness/$executable\_$window/$line.txt | cut -f 1 | xargs);
		  printf "%f " "$(echo $num / $den | bc -l)" >> ../ubasicexper/experiments/predictiveness/$filename.txt;
		  
		  printf $window" " >> ../ubasicexper/experiments/predictiveness/$filename.txt;
		  
		  printf $counter"\n" >> ../ubasicexper/experiments/predictiveness/$filename.txt;
		  
		  echo Complete!
		  echo
		  #Finishes reading the file                                                                                                                                                      
	      done < $loopfile

	      
     
	      
	      #Changes the directory to the experiment for convenience                                                                                                                        
	      cd ../ubasicexper/experiments/predictiveness/;
	      
	      #Plots the data using gnuplot                                                                                                                                                   
	      gnuplot <<- EOF
clear
reset
set style data histogram;
set style fill solid border lc rgb 'black'
set nokey
set yrange[0:]
set title "PCs vs Predictiveness for $filename with WS $window_size"
set xlabel "PCs"
set ylabel "Predictiveness"
set boxwidth 0.5
set xtics rotate out
set term png
set output "$filename.png"
plot '$filename.txt' using 2:xticlabels(1) with boxes fillstyle solid lc rgb 'purple';


EOF
	      
	      #Moves the files to the appropriate places
	      mv $filename.txt ./$filetype/$exec/data
	      mv $filename.png ./$filetype/$exec/plots
	      mv $executable\_$window ./$filetype/$exec

      


	  else
              echo This program loops less than $window times
              echo The experiment can not be run any further!
              echo Exitting
              echo
              exit 1
          fi
	  
	  cd ../../../asc
      done < ../ubasicexper/statistics/$filetype/window_sizes.txt
      

  else
      echo There is no associated executable
      echo Check the executables folder for options
  fi
}


multplot(){

    cd ./$filetype/$exec/data

    datafile=$filetype\_$exec
    a=$datafile\_1.txt
    b=$datafile\_50.txt
    c=$datafile\_100.txt
    d=$datafile\_250.txt
    e=$datafile\_500.txt
    title=$datafile\_all.png

    if [ -f $a ] && [ -f $b ] && [ -f $c ] && [ -f $d ] && [ -f $ $e ];
    then
	
	#Removes the previous file if there is one                                    
	rm $title

	#Plots the data using gnuplot   
	gnuplot <<- EOF
clear                                                                                                                                                            
reset                                                                                                                                                            
set style data histogram                                                                                                                                         
set style fill solid border lc rgb "black"                                                                                                                       
set yrange [0:]                                                                                                                                                  
set term png size 1440, 900                                                                                                                                      
set title "Predictiveness for Various Window Sizes for $datafile"                                                                                                
set output "$title"                                                                                                                                              
plot "$a" using 2:xticlabels(1) title "$a", "$b" using 2 title "$b", "$c" using 2 title "$c", "$d" using 2 title "$d", "$e" using 2 title "$e"                   
EOF

	mv $title ../plots
else

	    echo $filetype\_$exec must be run at all window sizes before the multplot can be created!
	    echo A list of all window sizes can be found within the statistics folder
fi 


}
while getopts "hcbn:w:mo" FLAG
do
    case $FLAG in
        h)
            #Calls the help function
            help
            exit 1
            ;;
        b)
            #Sets the file type to basic
            filetype=basic      
	    loopfile='../ubasicexper/statistics/basic/basic_loop_pcs.txt'
            ;;
        c)
            #Sets the file type to C
	    loopfile='../ubasicexper/statistics/C/C_loop_pcs.txt'
            filetype=C
            ;;
        n)
            #Sets the executable
            exec=$OPTARG
            ;;
	m)
	    multplot
	    exit 1
	    ;;
	o)
	    exper=false
	    ;;
	esac
done

#Checks if a type has been set and a loop argument has been passed
if [ -z $exec ] || [ -z $filetype ];
then
    echo A proper filetype, number, and window size must be given! Run this script with -h for help
    exit 1
else
    create
fi
