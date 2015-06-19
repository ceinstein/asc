#Sets the filename and the rsaname
filename=$1
executable=$2
window_size=$3
filetype=$4
counter=0

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ];
then
    echo The arguments are incorrect
    echo Experiment should be of the form ./runexper.sh filename executable window_size filetype
    exit 0
fi


if [ "$filetype" = "C" ] || [ "$filetype" = "c" ];
then
	loopfile='../ubasicexper/statistics/C/C_loop_pcs.txt'
else 
	loopfile='../ubasicexper/statistics/basic/basic_loop_pcs.txt'
fi


#Removes a previous version of the file since the experiment is being redone
rm $filename.txt

#Changes the directory to asc for convenience
cd ../../../asc;

#Reads in the file of pcs
while read line; 

#Runs the file in asc and puts the output into a file (checks every 500 executions of the specified pc)
do ./asc -a $line/$window_size $executable.net ../ubasicexper/experiments/executables/$executable &> ../ubasicexper/experiments/predictiveness/$line.txt;

#Puts the PC name into the data file
printf $line" " >> ../ubasicexper/experiments/predictiveness/$filename.txt; 
counter=$((counter + 1))

#Takes the last line in the PC file and puts the excited bit count into the data file
let num=$(grep "+" ../ubasicexper/experiments/predictiveness/$line.txt -c);
let den=$(tail -1 ../ubasicexper/experiments/predictiveness/$line.txt | cut -f 1 | xargs);
printf "%f " "$(echo $num / $den | bc -l)" >> ../ubasicexper/experiments/predictiveness/$filename.txt;

printf $window_size" " >> ../ubasicexper/experiments/predictiveness/$filename.txt;

printf $counter"\n" >> ../ubasicexper/experiments/predictiveness/$filename.txt;


#Finishes reading the file 
done < $loopfile


#Changes the directory to the experiment for convenience
cd ../ubasicexper/experiments/predictiveness/;

#Remove extraneous files
rm 4*;

#Plots the data using gnuplot
gnuplot <<- EOF                                                                 
   clear
   reset
   set style data histogram;                                                    
   set style fill solid border lc rgb 'black'                                   
   set nokey                                                                    
   set yrange [0:]
   set title "PCs vs Predictiveness for $filename with WS $window_size"                                              
   set xlabel "PCs"                                                             
   set ylabel "Predictiveness"                                                    
   set boxwidth 0.5                                                             
   set xtics rotate out                                                         
   set term png                                                                 
   set output '$filename.png'                                                          
   plot '$filename.txt' using 2:xticlabels(1) with boxes fillstyle solid lc rgb 'purple';
EOF
