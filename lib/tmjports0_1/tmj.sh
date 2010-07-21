#! /bin/sh

TM=.
LIB=.
MYLIB=$LIB/tmjportmux_gen

clock="clk"

case $1 in

-c*)	clock=`echo $1 | sed 's/-c//'`
	shift
	;;

esac

case $# in

1)	portsfile=$1
	;;

*)	echo "usage: tmj [ -cCLKNAME ] ports_file_name"
	exit 1
	;;

esac

cp $MYLIB/virtual1.v .
cp $MYLIB/simple_dual_port_ram_single_clock.v .
$LIB/tmjportmux_gen $portsfile | sed "s/XXXclkXXX/$clock/g" > tmj_portmux.v

if test $portsfile != "fpga0.ports"; then
	cp $portsfile fpga0.ports
fi
