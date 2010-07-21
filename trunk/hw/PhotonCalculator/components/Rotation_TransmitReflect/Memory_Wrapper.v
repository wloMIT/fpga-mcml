module Memory_Wrapper (
	//Inputs
	clock,
	reset,
	pindex,
	//Outputs
	sinp,
	cosp
	);

input					clock;
input					reset;
input	[9:0]			pindex;


output	[31:0]			sinp;
output	[31:0]			cosp;

sinp_ROM sinp_MEM (
			.address(pindex),
			.clock(clock),
			.q(sinp)
			);

cosp_ROM cosp_MEM (
			.address(pindex),
			.clock(clock),
			.q(cosp)
			);
			
endmodule
