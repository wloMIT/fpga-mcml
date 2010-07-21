TM=.
LIB=$(TM)

CFLAGS=-O

all:	tmjports.a

tmjports.a:	tmports.o util.o
	ar r tmjports.a tmports.o util.o

tmports.o:	tmports.c
	cc -c $(CFLAGS) tmports.c

util.o:	util.c
	cc -c $(CFLAGS) util.c

install:	tmjports.a
	cp tmjports.a $(LIB)/linux_tmjports.a

clean:
	rm -f *.o *.a
