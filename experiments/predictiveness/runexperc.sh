#Sets the filename and the cname
filename=$1
cname=$2
window_size=$3
#Removes a previous version of the file since the experiment is being redone
rm $filename.txt

#Changes the directory to asc for convenience
cd ../../../asc;

#Reads in the file of pcs
while read line; 

#Runs the file in asc and puts the output into a file (checks every 500 executions of the specified pc)
do ./asc -a $line/$window_size ../ubasicexper/experiments/executables/$cname &> ../ubasicexper/experiments/predictiveness/$line.txt;

#Puts the PC name into the data file
printf $line" " >> ../ubasicexper/experiments/predictiveness/$filename.txt; 

#Takes the last line in the PC file and puts the excited bit count into the data file
let num=$(grep "+" ../ubasicexper/experiments/predictiveness/$line.txt -c);
let den=$(tail -1 ../ubasicexper/experiments/predictiveness/$line.txt | cut -f 1 | xargs);
echo $num / $den | bc -l >> ../ubasicexper/experiments/predictiveness/$filename.txt;

#Finishes reading the file 
done < ../ubasicexper/experiments/predictiveness/factor_c_basic_loop_pcs.txt;

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
   set title "PCs vs Predictiveness"                                              
   set xlabel "PCs"                                                             
   set ylabel "Predictiveness"                                                    
   set boxwidth 0.5                                                             
   set xtics rotate out                                                         
   set term png                                                                 
   set output '$filename.png'                                                          
   plot '$filename.txt' using 2:xticlabels(1) with boxes fillstyle solid lc rgb 'purple';
EOF
