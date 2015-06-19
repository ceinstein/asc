#Sets the filename that is being used
datafile=$1
a=$datafile\_1.txt
b=$datafile\_50.txt
c=$datafile\_100.txt
d=$datafile\_250.txt
e=$datafile\_500.txt
title=$datafile\_all.png
#Removes the previous file if there is one
rm $title

#Plots the data using gnuplot
gnuplot <<- EOF
clear
reset
set style data histogram
set style fill solid border lc rgb "black"
set term png size 1440, 900
set title "Excited Bits for Various Window Sizes for $datafile"
set output "$title"
plot "$a" using 2:xticlabels(1) title "$a", "$b" using 2 title "$b", "$c" using 2 title "$c", "$d" using 2 title "$d", "$e" using 2 title "$e"
EOF
