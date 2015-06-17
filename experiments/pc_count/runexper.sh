#Sets the filename and the rsaname
filename=$1
executable=$2
window_size=$3
filetype=$4

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

#Runs the file in asc and puts the output into a file
do ./asc -a $line/$window_size ../ubasicexper/experiments/executables/$executable &> ../ubasicexper/experiments/pc_count//$line.txt;

#Puts the PC name into the data file
printf $line" " >> ../ubasicexper/experiments/pc_count/$filename.txt; 

#Takes the last line in the PC file and puts the excited bit count into the data file
tail -1 ../ubasicexper/experiments/pc_count/$line.txt | cut -f 3 | xargs >> ../ubasicexper/experiments/pc_count/$filename.txt;

#Finishes reading the file 
done < $loopfile

#Changes the directory to the experiment for convenience
cd ../ubasicexper/experiments/pc_count/;

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
   set title "PCs vs Excited Bits for $filename"                                              
   set xlabel "PCs"                                                             
   set ylabel "Excited Bits"                                                    
   set boxwidth 0.5                                                             
   set xtics rotate out                                                         
   set term png                                                                 
   set output '$filename.png'                                                          
   plot '$filename.txt' using 2:xticlabels(1) with boxes fillstyle solid lc rgb 'purple';
EOF
