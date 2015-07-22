filename=$1
cc ../../../../asc/kernels/crt0.s $filename.c -nostdinc -isystem /usr/include/diet -ggdb3 -Wno-cpp -static -nostdlib -L /usr/lib/diet/lib -lc -lm -o $filename
