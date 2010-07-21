#! /bin/sh

TM=/jayar/i/tm4
LIB=$TM/lib/tmj_portmux

PART1=$LIB/tmjportmux_skel_part1a
PART1B=$LIB/tmjportmux_skel_part1b
PART1C=$LIB/tmjportmux_skel_part1c
PART1D=$LIB/tmjportmux_skel_part1d
PART2=$LIB/tmjportmux_skel_part2

# Generate a portmux circuit that can be added to a user's circuit

case $# in

1)	
	portfile=$1
	;;

*)	echo usage: tmjportmux_gen port_description_file
	exit 1
	;;

esac

echo "module tmj_portmux("

grep -v '^#' $portfile | tr -d '\r' | grep -v '^$' | awk '
BEGIN	{
	maxtouserbits = 2
	maxfromuserbits = 2
	port = 0
}

{
	name = $1
	dir = $2
	bits = $3
	hs1 = $4
	hs2 = $5

	padded_bits = int((bits+7)/8) * 8

	if(dir == "o" || dir == "O") {
		printf "      input [%d:0] %s,\n", bits-1, name
		if(padded_bits > maxtouserbits)
			maxtouserbits = padded_bits
	}
	if(dir == "i" || dir == "I") {
		printf "      output reg [%d:0] %s,\n", bits-1, name
		if(padded_bits > maxfromuserbits)
			maxfromuserbits = padded_bits
	}
	if(hs1)
		printf "      input %s,\n", hs1
	if(hs2)
		printf "      output reg %s,\n", hs2

	portbits[port] = bits
	padded_portbits[port] = padded_bits
	port++
}

END	{
	printf "      input XXXclkXXX\n"
	printf "      );\n\n"
	printf "parameter TMJ_MAX_TO_USER_PORT_WIDTH = %d;\n", maxtouserbits
	printf "parameter TMJ_MAX_FROM_USER_PORT_WIDTH = %d;\n", maxfromuserbits
	for(p = 0; p < port; p++) {
		printf "parameter TMJ_PORT%d_WIDTH = %d;\n", p, portbits[p]
		printf "parameter TMJ_PORT%d_PADDED_WIDTH = %d;\n", p, padded_portbits[p]
		printf "parameter TMJ_PORT%d_ADDRESS = %d;\n", p, p+1
	}
}'

cat $PART1

grep -v '^#' $portfile | tr -d '\r' | grep -v '^$' | awk '
BEGIN	{
	port = 0
}

{
	name = $1
	dir = $2
	bits = $3
	hs1[port] = $4
	hs2[port] = $5

	printf "            if(tmj_port_address == TMJ_PORT%d_ADDRESS) begin\n", port
	printf "               tmj_port_data_width <= TMJ_PORT%d_PADDED_WIDTH;\n", port
	printf "            end\n\n"

	port++
}'

cat $PART1B

grep -v '^#' $portfile | tr -d '\r' | grep -v '^$' | awk '
BEGIN	{
	port = 0
}

{
	name = $1
	dir = $2
	bits = $3
	hs1[port] = $4
	hs2[port] = $5

	if(dir == "i" || dir == "I") {
		printf "               if(tmj_port_address == TMJ_PORT%d_ADDRESS) begin\n", port
		if(hs1[port]) {
			printf "                  if(%s && !%s) begin\n", hs1[port], hs2[port]
			printf "                     tmj_data_accepted = 1;\n"
			printf "                     %s <= tmj_write_data[TMJ_MAX_FROM_USER_PORT_WIDTH-TMJ_PORT%d_PADDED_WIDTH+TMJ_PORT%d_WIDTH-1\n", name, port, port
			printf "                                        :TMJ_MAX_FROM_USER_PORT_WIDTH-TMJ_PORT%d_PADDED_WIDTH];\n", port
			printf "                     %s <= 1;\n", hs2[port]
			printf "                  end\n"
		}
		else {
			printf "                  tmj_data_accepted = 1;\n"
			printf "                  %s <= tmj_write_data[TMJ_MAX_FROM_USER_PORT_WIDTH-TMJ_PORT%d_PADDED_WIDTH+TMJ_PORT%d_WIDTH-1\n", name, port, port
			printf "                                     :TMJ_MAX_FROM_USER_PORT_WIDTH-TMJ_PORT%d_PADDED_WIDTH];\n", port
		}

		printf "               end\n\n"
	}

	port++
}'

cat $PART1C

grep -v '^#' $portfile | tr -d '\r' | grep -v '^$' | awk '
BEGIN	{
	port = 0
}

{
	name = $1
	dir = $2
	bits = $3
	hs1[port] = $4
	hs2[port] = $5

	padded_bits = int((bits+7)/8) * 8

	if(dir == "o" || dir == "O") {
		printf "            if(tmj_port_address == TMJ_PORT%d_ADDRESS) begin\n", port
		if(hs1[port]) {
			printf "               if(%s && !%s) begin\n", hs1[port], hs2[port]
			printf "                  %s <= 1;\n", hs2[port]
			printf "                  tmj_read_data[TMJ_PORT%d_WIDTH:1] <= %s;\n", port, name
                        if(bits != padded_bits) {
				printf "                  tmj_read_data[%d:%d] <= { %d{ %s[%d] } };\n", padded_bits, bits+1, padded_bits - bits, name, bits-1
			}
			printf "                  tmj_data_ready = 1;\n"
			printf "               end\n"
		}
		else {
			printf "               tmj_read_data[TMJ_PORT%d_PADDED_WIDTH:1] <= %s;\n", port, name
                        if(bits != padded_bits) {
				printf "               tmj_read_data[%d:%d] <= { %d{ %s[%d] } };\n", padded_bits, bits+1, padded_bits - bits, name, bits-1
			}
			printf "               tmj_data_ready = 1;\n"
		}

		printf "            end\n\n"
	}

	port++
}'

cat $PART1D

grep -v '^#' $portfile | tr -d '\r' | grep -v '^$' | awk '
BEGIN	{
	port = 0
}

{
	name = $1
	dir = $2
	bits = $3
	hs1[port] = $4
	hs2[port] = $5

	port++
}

END	{
	for(p = 0; p < port; p++) {
		if(hs2[p]) {
			printf "\n   if(%s && !%s)\n", hs2[p], hs1[p]
			printf "      %s <= 0;\n", hs2[p]
		}
	}
}'

cat $PART2
