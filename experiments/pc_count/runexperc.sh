#Sets the filename and the cname
filename=$1
cname=$2

#Removes a previous version of the file since the experiment is being redone
rm $filename.txt

#Changes the directory to asc for convenience
cd ../../../asc;

#Reads in the file of pcs
while read line; 

#Runs the file in asc and puts the output into a file
do ./asc -a $line ../ubasicexper/experiments/executables/$cname &> ../ubasicexper/experiments/pc_count//$line.txt;

#Puts the PC name into the data file
printf $line" " >> ../ubasicexper/experiments/pc_count/$filename.txt; 

#Takes the last line in the PC file and puts the excited bit count into the data file
tail -1 ../ubasicexper/experiments/pc_count/$line.txt | cut -f 3 | xargs >> ../ubasicexper/experiments/pc_count/$filename.txt;

#Finishes reading the file 
done < ../ubasicexper/experiments/pc_count/factor_c_basic_loop_pcs.txt;

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
   set title "PCs vs Excited Bits"                                              
   set xlabel "PCs"                                                             
   set ylabel "Excited Bits"                                                    
   set boxwidth 0.5                                                             
   set xtics rotate out                                                         
   set term png                                                                 
   set output '$filename.png'                                                          
   plot '$filename.txt' using 2:xticlabels(1) with boxes fillstyle solid lc rgb 'purple';
EOF
