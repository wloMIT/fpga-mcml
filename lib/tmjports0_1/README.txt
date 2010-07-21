This is version 0.1 of this package, dated April 23, 2009.

These files are an attempt to re-target University of Toronto's
TM-4 ports package (http://www.eecg.toronto.edu/~tm4/ports.pdf)
to the Altera DE-2 and DE-3 boards.

The ports package allows you to easily transfer data between a program
on your workstation and a circuit running in a board.

This implementation of the ports package transfers the data using the JTAG
connection to the board.  On the DE-2 and DE-3, JTAG information is
transferred over the USB Blaster cable.  This is the same communication
path that Quartus uses to program the FPGA, and that SignalTap uses to capture
debugging information.

This implementation works, but the performance is disappointing.  We see
data transfer speeds on the order of 50K bytes/second from the computer to
the circuit, but only 5K bytes/second from the circuit to the computer.
We are hoping to build a faster version someday by using a direct USB
link, but that may never happen, so we are releasing this one.

To install it, you need to install tmj.sh, tmjports and tmjportmux_gen.  Modify
the makefiles to set the pathnames to something reasonable.  At the same time,
fix up the pathnames at the top of tmj.sh and tmjportmux_gen.sh.

To use it, create a designname.ports file that describes the communication ports
on your design, following the examples in the ports package document.  Run

	tmj designname.ports

This should run tmjportmux_gen.sh, which will create a tmj_portmux.v file.
Add this module to your design, and connect its inputs and outputs to the
similarly named ports on your design.  It will also create the files
simple_dual_port_ram_single_clock.v and virtual1.v, which are used
by tmj_portmux.v to buffer data and talk to the JTAG interface respectively.
It will also copy designname.ports to fpga0.ports.  Put fpga0.ports in
the directory where you will run the program that communicates with your
design, so it can get information about the ports on your design.

Now you can write the program that talks to the design.  The library functions
in tmjports.a allow you to initialize the communication (tminit("")),
open a port (tm_open()) and transfer data (tm_read() and tm_write()).

Download your re-compiled design.  Run your program in a directory that has
the fpga0.ports file.  Make sure that you have the quartus_stp program on
your path, so that tm_init() can start it up in the background.

If anything goes wrong, you may be able to look at the information being
transferred between the routines in tmjports.a and quartus_stp.  You'll have
to uncomment some or all of the printf statements in tmports.c, and
re-build tmjports.a and your program.

There is an example design in examples/counter.  It is a simple
circuit that returns a 32-bit value which is incremented every time it
is read.  You will have to change the path names in the makefile in order
to compile it.
