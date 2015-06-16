
k-CC = cc
k-CFLAGS = -DTRACE_GOTO -D_BSD_SOURCE -D_GNU_SOURCE -nostdinc -I /usr/include/diet
k-CFLAGS += -Wall -Werror -Wno-attributes -Wno-deprecated-declarations
k-LDFLAGS = -g -nostdlib -static -L /usr/lib/diet/lib -lc -lm


%:
	xxd -i < $@.bas > program.xxd~
	echo ', 0x00' >> program.xxd~
	$(k-CC) crt0.s tokenizer.c ubasic.c use-ubasic.c $(k-CFLAGS) $(k-LDFLAGS) -o $@
	rm program.xxd~


clean:
	rm *~ *.o \#*

#eof
