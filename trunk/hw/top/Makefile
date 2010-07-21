QUARTUS_PATH=/jayar/g/g/drg/bin

all: mcml_hw.vhd Makefile tmj_portmux.v
	$(QUARTUS_PATH)/quartus_sh --flow compile mcml_hw

clean:
	rm -rf tm4

tmj_portmux.v: mcml_hw.ports Makefile
	cd ../../lib/tmjports0_1
	tmj ../../hw/top/mcml_hw.ports
	cd ../../hw/top
