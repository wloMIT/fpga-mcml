Building the hardware:
1) cd /hw/top
2) edit the Makefile, and change the QUARTUS_PATH variable to the location of the quartus_sh script
3) "make"
4) This creates a file named mcml_hw.sof, which can be used to program the FPGA.

Building the software:
1) cd /sw
2) "make"
3) This creates an executable called mcml_tm4 which can be run, and communicates with the hardware

