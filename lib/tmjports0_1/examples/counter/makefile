all:	linux_counter

TM=/jayar/i/tm4
LIB=$(TM)/lib

LINUXPORTS=$(LIB)/linux_tmjports.a

linux_counter:	suncounter.c $(LINUXPORTS)
	cc -o linux_counter suncounter.c $(LINUXPORTS)

bits:	top.vhd counter.vhd tmj_portmux.v
	qcmd top.vhd

tmj_portmux.v:	counter.ports
	tmj counter.ports

clean:
	rm -rf linux_counter *.o
