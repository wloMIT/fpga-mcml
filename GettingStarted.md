

## 1. Top-Level Simulation Flow ##

---

The host computer runs the software portion of the MCML simulation, while the hardware-accelerated portion is run on the FPGA platform, as shown.

![https://fpga-mcml.googlecode.com/svn/wiki/images/flow1b.png](https://fpga-mcml.googlecode.com/svn/wiki/images/flow1b.png)

## 2. Software Flow ##

---

The main function can be found in the file mcml\_tm4.c.  This file calls functions to do the pre-simulation calculations that are handled in software.  The definition of the main structures used in the software flow can be found in mcml.h.

**NOTE**: The original platform used for this design was called the tm4.  Hence, some of the file and variable names contain tm4, referring to this device.

![https://fpga-mcml.googlecode.com/svn/wiki/images/flow2b.png](https://fpga-mcml.googlecode.com/svn/wiki/images/flow2b.png)

## 3. Software-Hardware Communication ##

---

The communication with hardware is done through a hardware library known as the ports package (linux\_tmjports\_old.a).  This package uses USB Blaster to communicate with the DE3 board.  Unfortunately, when used with the DE3 board, this package has known issues that result in slow transfer rates.  However, the TM4 package may be replaced by any host-board communication without affecting the main portion of the design: the Photon Calculator (refer to the next section).

This package requires the use of a configuration file which we have called the mcml\_hw.ports file.  This file is included in the /hw directory.  For more information about how the ports package works, download [ports.pdf](http://www.eecg.toronto.edu/~tm4/ports.pdf).


## 4. Hardware Flow ##

---

The hardware flow consists of three main components: mcml\_hw, skeleton, and Photon Calculator.  The mcml\_hw contains the necessary control signals and components to communicate with software.  The skeleton contains the control logic to control the flow of data from the software to the hardware.  It also starts and stops the simulation.  Finally, the skeleton fans out the input constants from a 32-bit bus to the appropriate signals for use within the FPGA device.

The Photon Calculator is the main component in this design.  This is where the absorption array is calculated, which is the computationally complex portion of the mcml calculation.  The absorption array can be used to calculate the fluence distribution.

To replace the ports package with another method for communication between the host computer and the FPGA device, the mcml\_hw and skeleton blocks must be replaced.  Note that some of the logic contained in the skeleton must be ported to the new solution, as the Photon Calculator control logic and the fanout logic must be maintained.

![https://fpga-mcml.googlecode.com/svn/wiki/images/flow3.png](https://fpga-mcml.googlecode.com/svn/wiki/images/flow3.png)

## 5. Source Code Release ##

---

Download and unarchive: [FPGA-MCML](http://code.google.com/p/fpga-mcml/downloads/list).

Download the two related papers for further information.

## 6a. Building the Hardware ##

---

  1. Type **cd /hw/top**
  1. Edit the Makefile, and change the **QUARTUS\_PATH** variable to the location of the   quartus\_sh script
  1. Type **make**
  1. This creates a file named **mcml\_hw.sof**, which can be used to program the FPGA.

## 6b. Building the Software ##

---

  1. Type **cd /sw**
  1. Type **make**
  1. This creates an executable called **mcml\_tm4** which can be run, and communicates with the hardware