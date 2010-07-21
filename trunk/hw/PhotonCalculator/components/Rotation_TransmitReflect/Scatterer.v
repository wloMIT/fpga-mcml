//////////////////////////////////////////////////////////////////////////////////
//  #####   ##     #   #####   ######   #####    ##     #     ##     #
//    #     # #    #     #     #        #    #   # #    #    #  #    #
//    #     #  #   #     #     #####    #    #   #  #   #   #    #   #
//    #     #   #  #     #     #        #####    #   #  #   ######   #
//    #     #    # #     #     #        #   #    #    # #   #    #   #
//  #####   #     ##     #     ######   #    #   #     ##   #    #   ######
//
//  #####   #####   #####    ######   #        #####   ##     #   ######
//  #    #    #     #    #   #        #          #     # #    #   #
//  #    #    #     #    #   #####    #          #     #  #   #   #####
//  #####     #     #####    #        #          #     #   #  #   #
//  #         #     #        #        #          #     #    # #   #
//  #       #####   #        ######   ######   #####   #     ##   ######
//
//
//  Internal registers within the Scatterer.
//////////////////////////////////////////////////////////////////////////////////
module InternalsBlock(
	//Inputs
	clock,
	reset,
	enable,
	
	i_sint,
	i_cost,
	i_sinp,
	i_cosp,
	i_sintCosp,
	i_sintSinp,
	i_uz2,
	i_uxUz,
	i_uyUz,
	i_uySintSinp,
	i_oneMinusUz2,
	i_uyUzSintCosp,
	i_uxUzSintCosp,
	i_uxSintSinp,
	i_sqrtOneMinusUz2,
	i_sintCospSqrtOneMinusUz2,
	i_uxCost,
	i_uzCost,
	i_sqrtOneMinusUz2_inv,
	i_uxNumerator,
	i_uyNumerator,
	i_uyCost,
	i_uxQuotient,
	i_uyQuotient,
	//Outputs
	o_sint,
	o_cost,
	o_sinp,
	o_cosp,
	o_sintCosp,
	o_sintSinp,
	o_uz2,
	o_uxUz,
	o_uyUz,
	o_uySintSinp,
	o_oneMinusUz2,
	o_uyUzSintCosp,
	o_uxUzSintCosp,
	o_uxSintSinp,
	o_sqrtOneMinusUz2,
	o_sintCospSqrtOneMinusUz2,
	o_uxCost,
	o_uzCost,
	o_sqrtOneMinusUz2_inv,
	o_uxNumerator,
	o_uyNumerator,
	o_uyCost,
	o_uxQuotient,
	o_uyQuotient
	);

input					clock;
input					reset;
input					enable;

input		[31:0]		i_sint;
input		[31:0]		i_cost;
input		[31:0]		i_sinp;
input		[31:0]		i_cosp;
input		[31:0]		i_sintCosp;
input		[31:0]		i_sintSinp;
input		[63:0]		i_uz2;
input		[31:0]		i_uxUz;
input		[31:0]		i_uyUz;
input		[31:0]		i_uySintSinp;
input		[63:0]		i_oneMinusUz2;
input		[31:0]		i_uyUzSintCosp;
input		[31:0]		i_uxUzSintCosp;
input		[31:0]		i_uxSintSinp;
input		[31:0]		i_sqrtOneMinusUz2;
input		[31:0]		i_sintCospSqrtOneMinusUz2;
input		[31:0]		i_uxCost;
input		[31:0]		i_uzCost;
input		[31:0]		i_sqrtOneMinusUz2_inv;
input		[31:0]		i_uxNumerator;
input		[31:0]		i_uyNumerator;
input		[31:0]		i_uyCost;
input		[31:0]		i_uxQuotient;
input		[31:0]		i_uyQuotient;


output		[31:0]		o_sint;
output		[31:0]		o_cost;
output		[31:0]		o_sinp;
output		[31:0]		o_cosp;
output		[31:0]		o_sintCosp;
output		[31:0]		o_sintSinp;
output		[63:0]		o_uz2;
output		[31:0]		o_uxUz;
output		[31:0]		o_uyUz;
output		[31:0]		o_uySintSinp;
output		[63:0]		o_oneMinusUz2;
output		[31:0]		o_uyUzSintCosp;
output		[31:0]		o_uxUzSintCosp;
output		[31:0]		o_uxSintSinp;
output		[31:0]		o_sqrtOneMinusUz2;
output		[31:0]		o_sintCospSqrtOneMinusUz2;
output		[31:0]		o_uxCost;
output		[31:0]		o_uzCost;
output		[31:0]		o_sqrtOneMinusUz2_inv;
output		[31:0]		o_uxNumerator;
output		[31:0]		o_uyNumerator;
output		[31:0]		o_uyCost;
output		[31:0]		o_uxQuotient;
output		[31:0]		o_uyQuotient;


wire					clock;
wire					reset;
wire					enable;

wire		[31:0]		i_sint;
wire		[31:0]		i_cost;
wire		[31:0]		i_sinp;
wire		[31:0]		i_cosp;
wire		[31:0]		i_sintCosp;
wire		[31:0]		i_sintSinp;
wire		[63:0]		i_uz2;
wire		[31:0]		i_uxUz;
wire		[31:0]		i_uyUz;
wire		[31:0]		i_uySintSinp;
wire		[63:0]		i_oneMinusUz2;
wire		[31:0]		i_uyUzSintCosp;
wire		[31:0]		i_uxUzSintCosp;
wire		[31:0]		i_uxSintSinp;
wire		[31:0]		i_sqrtOneMinusUz2;
wire		[31:0]		i_sintCospSqrtOneMinusUz2;
wire		[31:0]		i_uxCost;
wire		[31:0]		i_uzCost;
wire		[31:0]		i_sqrtOneMinusUz2_inv;
wire		[31:0]		i_uxNumerator;
wire		[31:0]		i_uyNumerator;
wire		[31:0]		i_uyCost;
wire		[31:0]		i_uxQuotient;
wire		[31:0]		i_uyQuotient;


reg			[31:0]		o_sint;
reg			[31:0]		o_cost;
reg			[31:0]		o_sinp;
reg			[31:0]		o_cosp;
reg			[31:0]		o_sintCosp;
reg			[31:0]		o_sintSinp;
reg			[63:0]		o_uz2;
reg			[31:0]		o_uxUz;
reg			[31:0]		o_uyUz;
reg			[31:0]		o_uySintSinp;
reg			[63:0]		o_oneMinusUz2;
reg			[31:0]		o_uyUzSintCosp;
reg			[31:0]		o_uxUzSintCosp;
reg			[31:0]		o_uxSintSinp;
reg			[31:0]		o_sqrtOneMinusUz2;
reg			[31:0]		o_sintCospSqrtOneMinusUz2;
reg			[31:0]		o_uxCost;
reg			[31:0]		o_uzCost;
reg			[31:0]		o_sqrtOneMinusUz2_inv;
reg			[31:0]		o_uxNumerator;
reg			[31:0]		o_uyNumerator;
reg			[31:0]		o_uyCost;
reg			[31:0]		o_uxQuotient;
reg			[31:0]		o_uyQuotient;




always @ (posedge clock)
	if(reset) begin
		o_sint						<= 32'h00000000;
		o_cost						<= 32'h00000000;
		o_sinp						<= 32'h00000000;
		o_cosp						<= 32'h00000000;
		o_sintCosp					<= 32'h00000000;
		o_sintSinp					<= 32'h00000000;
		o_uz2						<= 64'h0000000000000000;
		o_uxUz						<= 32'h00000000;
		o_uyUz						<= 32'h00000000;
		o_uySintSinp				<= 32'h00000000;
		o_oneMinusUz2				<= 64'h0000000000000000;
		o_uyUzSintCosp				<= 32'h00000000;
		o_uxUzSintCosp				<= 32'h00000000;
		o_uxSintSinp				<= 32'h00000000;
		o_sqrtOneMinusUz2			<= 32'h00000000;
		o_sintCospSqrtOneMinusUz2	<= 32'h00000000;
		o_uxCost					<= 32'h00000000;
		o_uzCost					<= 32'h00000000;
		o_sqrtOneMinusUz2_inv		<= 32'h00000000;
		o_uxNumerator				<= 32'h00000000;
		o_uyNumerator				<= 32'h00000000;
		o_uyCost					<= 32'h00000000;
		o_uxQuotient				<= 32'h00000000;
		o_uyQuotient				<= 32'h00000000;
	end else if(enable) begin
		o_sint						<= i_sint;
		o_cost						<= i_cost;
		o_sinp						<= i_sinp;
		o_cosp						<= i_cosp;
		o_sintCosp					<= i_sintCosp;
		o_sintSinp					<= i_sintSinp;
		o_uz2						<= i_uz2;
		o_uxUz						<= i_uxUz;
		o_uyUz						<= i_uyUz;
		o_uySintSinp				<= i_uySintSinp;
		o_oneMinusUz2				<= i_oneMinusUz2;
		o_uyUzSintCosp				<= i_uyUzSintCosp;
		o_uxUzSintCosp				<= i_uxUzSintCosp;
		o_uxSintSinp				<= i_uxSintSinp;
		o_sqrtOneMinusUz2			<= i_sqrtOneMinusUz2;
		o_sintCospSqrtOneMinusUz2	<= i_sintCospSqrtOneMinusUz2;
		o_uxCost					<= i_uxCost;
		o_uzCost					<= i_uzCost;
		o_sqrtOneMinusUz2_inv		<= i_sqrtOneMinusUz2_inv;
		o_uxNumerator				<= i_uxNumerator;
		o_uyNumerator				<= i_uyNumerator;
		o_uyCost					<= i_uyCost;
		o_uxQuotient				<= i_uxQuotient;
		o_uyQuotient				<= i_uyQuotient;
	end
endmodule


//////////////////////////////////////////////////////////////////////////////////
//   ####     ####      ##     #####   #####   ######   #####    ######   #####
//  #        #    #    #  #      #       #     #        #    #   #        #    #
//   ####    #        #    #     #       #     #####    #    #   #####    #    #
//       #   #        ######     #       #     #        #####    #        #####
//  #    #   #    #   #    #     #       #     #        #   #    #        #   #
//   ####     ####    #    #     #       #     ######   #    #   ######   #    #	
//
//
//
//
//
//
//
//
//NAMING CONVENTION:
//prodX_Y means the Xth product which started calculation at the Yth clock cycle
//opX_Y_Z means the Zth operand for the Xth product of the Yth cycle
//i_uxN means input from the Nth register in the pipeline, the value of ux.
//////////////////////////////////////////////////////////////////////////////////

module Scatterer (
	//INPUTS
	clock,
	reset,
	enable,
	//Values from Photon Pipeline
	i_uz1,
	i_ux3,
	i_uz3,
	i_uy32,
	i_uz32,
	i_ux33,
	i_uy33,
	i_ux35,
	i_uy35,
	i_uz35,
	i_uz36,

	//Mathematics Results
	prod1_2,
	prod1_4,
	sqrtResult1_6,
	prod1_33,
	prod2_33,
	prod3_33,
	prod1_34,
	prod2_34,
	prod3_34,
	prod4_34,
	quot1_16,
	prod1_36,
	prod2_36,
	prod3_36,
	prod4_36,
	prod5_36,
	prod6_36,

	//Trig from Memory
	sint_Mem,
	cost_Mem,
	sinp_Mem,
	cosp_Mem,
	
	//OUTPUTS
	op1_2_1,
	op1_2_2,
	op1_4_1,
	op1_4_2,
	sqrtOperand1_6,
	divNumerator1_16,
	divDenominator1_16,
	op1_33_1,
	op1_33_2,
	op2_33_1,
	op2_33_2,
	op3_33_1,
	op3_33_2,
	op1_34_1,
	op1_34_2,
	op2_34_1,
	op2_34_2,
	op3_34_1,
	op3_34_2,
	op4_34_1,
	op4_34_2,
	op1_36_1,
	op1_36_2,
	op2_36_1,
	op2_36_2,
	op3_36_1,
	op3_36_2,
	op4_36_1,
	op4_36_2,
	op5_36_1,
	op5_36_2,
	op6_36_1,
	op6_36_2,
	
	//Final calculated values
	ux_scatterer,
	uy_scatterer,
	uz_scatterer
	
	
	);
	
//-------------------PARAMETER DEFINITION----------------------
//
//
//
//
//
//
//Assign values to parameters used later in the program.
	
parameter DIV = 20;
parameter SQRT = 10;
parameter LAT = DIV + SQRT + 7;
parameter INTMAX_2 = 64'h3FFFFFFF00000001;
parameter INTMAX = 2147483647;
parameter INTMIN = -2147483647;
parameter INTMAXMinus3 = 2147483644;
parameter negINTMAXPlus3 = -2147483644;



//-----------------------------PIN DECLARATION----------------------
//
//
//
//
//
//
//
//
//Assign appropriate types to pins (input or output).

input				clock;
input				reset;
input				enable;
//Values from Photon Pipeline
input	[31:0]		i_uz1;
input	[31:0]		i_ux3;
input	[31:0]		i_uz3;
input	[31:0]		i_uy32;
input	[31:0]		i_uz32;
input	[31:0]		i_ux33;
input	[31:0]		i_uy33;
input	[31:0]		i_ux35;
input	[31:0]		i_uy35;
input	[31:0]		i_uz35;
input	[31:0]		i_uz36;

//Multiplication Results
input	[63:0]		prod1_2;
input	[31:0]		prod1_4;
input	[31:0]		sqrtResult1_6;
input	[31:0]		prod1_33;
input	[31:0]		prod2_33;
input	[31:0]		prod3_33;
input	[31:0]		prod1_34;
input	[31:0]		prod2_34;
input	[31:0]		prod3_34;
input	[31:0]		prod4_34;
input	[63:0]		quot1_16;
//Need all 64-bits for these two to detect overflows
input	[63:0]		prod1_36;
input	[63:0]		prod2_36;
input	[31:0]		prod3_36;
input	[31:0]		prod4_36;
input	[31:0]		prod5_36;
input	[31:0]		prod6_36;


//Trig Values from Memory
input	[31:0]		sint_Mem;
input	[31:0]		cost_Mem;
input	[31:0]		sinp_Mem;
input	[31:0]		cosp_Mem;

output	[31:0]		op1_2_1;
output	[31:0]		op1_2_2;
output	[31:0]		op1_4_1;
output	[31:0]		op1_4_2;
output	[63:0]		sqrtOperand1_6;
output	[63:0]		divNumerator1_16;
output	[31:0]		divDenominator1_16;
output	[31:0]		op1_33_1;
output	[31:0]		op1_33_2;
output	[31:0]		op2_33_1;
output	[31:0]		op2_33_2;
output	[31:0]		op3_33_1;
output	[31:0]		op3_33_2;
output	[31:0]		op1_34_1;
output	[31:0]		op1_34_2;
output	[31:0]		op2_34_1;
output	[31:0]		op2_34_2;
output	[31:0]		op3_34_1;
output	[31:0]		op3_34_2;
output	[31:0]		op4_34_1;
output	[31:0]		op4_34_2;
output	[31:0]		op1_36_1;
output	[31:0]		op1_36_2;
output	[31:0]		op2_36_1;
output	[31:0]		op2_36_2;
output	[31:0]		op3_36_1;
output	[31:0]		op3_36_2;
output	[31:0]		op4_36_1;
output	[31:0]		op4_36_2;
output	[31:0]		op5_36_1;
output	[31:0]		op5_36_2;
output	[31:0]		op6_36_1;
output	[31:0]		op6_36_2;

//Final Calculated Results
output	[31:0]		ux_scatterer;
output	[31:0]		uy_scatterer;
output	[31:0]		uz_scatterer;


//-----------------------------PIN TYPES-----------------------------
//
//
//
//
//
//
//
//
//Assign pins to be wires or regs.


wire				clock;
wire				reset;
wire				enable;
//Values from Photon Pipeline
wire	[31:0]		i_uz1;
wire	[31:0]		i_ux3;
wire	[31:0]		i_uz3;
wire	[31:0]		i_uy32;
wire	[31:0]		i_uz32;
wire	[31:0]		i_ux33;
wire	[31:0]		i_uy33;
wire	[31:0]		i_ux35;
wire	[31:0]		i_uy35;
wire	[31:0]		i_uz35;
wire	[31:0]		i_uz36;

//Multiplication Results
wire	[63:0]		prod1_2;
wire	[31:0]		prod1_4;
wire	[31:0]		sqrtResult1_6;
wire	[31:0]		prod1_33;
wire	[31:0]		prod2_33;
wire	[31:0]		prod3_33;
wire	[31:0]		prod1_34;
wire	[31:0]		prod2_34;
wire	[31:0]		prod3_34;
wire	[31:0]		prod4_34;
wire	[63:0]		quot1_16;
wire	[63:0]		prod1_36;
wire	[63:0]		prod2_36;
wire	[31:0]		prod3_36;
wire	[31:0]		prod4_36;
wire	[31:0]		prod5_36;
wire	[31:0]		prod6_36;


//Trig Values from Memory
wire	[31:0]		sint_Mem;
wire	[31:0]		cost_Mem;
wire	[31:0]		sinp_Mem;
wire	[31:0]		cosp_Mem;

//Operands for shared resources
wire	[31:0]		op1_2_1;
wire	[31:0]		op1_2_2;
wire	[31:0]		op1_4_1;
wire	[31:0]		op1_4_2;
wire	[63:0]		sqrtOperand1_6;
wire	[63:0]		divNumerator1_16;
wire	[31:0]		divDenominator1_16;
wire	[31:0]		op1_33_1;
wire	[31:0]		op1_33_2;
wire	[31:0]		op2_33_1;
wire	[31:0]		op2_33_2;
wire	[31:0]		op3_33_1;
wire	[31:0]		op3_33_2;
wire	[31:0]		op1_34_1;
wire	[31:0]		op1_34_2;
wire	[31:0]		op2_34_1;
wire	[31:0]		op2_34_2;
wire	[31:0]		op3_34_1;
wire	[31:0]		op3_34_2;
wire	[31:0]		op4_34_1;
wire	[31:0]		op4_34_2;
wire	[31:0]		op1_36_1;
wire	[31:0]		op1_36_2;
wire	[31:0]		op2_36_1;
wire	[31:0]		op2_36_2;
wire	[31:0]		op3_36_1;
wire	[31:0]		op3_36_2;
wire	[31:0]		op4_36_1;
wire	[31:0]		op4_36_2;
wire	[31:0]		op5_36_1;
wire	[31:0]		op5_36_2;
wire	[31:0]		op6_36_1;
wire	[31:0]		op6_36_2;

//Final outputs
reg		[31:0]		ux_scatterer;
reg		[31:0]		uy_scatterer;
reg		[31:0]		uz_scatterer;

//-----------------------------END Pin Types-------------------------



//Wires to Connect to Internal Registers
wire		[31:0]		sint[LAT:0];
wire		[31:0]		cost[LAT:0];
wire		[31:0]		sinp[LAT:0];
wire		[31:0]		cosp[LAT:0];
wire		[31:0]		sintCosp[LAT:0];
wire		[31:0]		sintSinp[LAT:0];
wire		[63:0]		uz2[LAT:0];
wire		[31:0]		uxUz[LAT:0];
wire		[31:0]		uyUz[LAT:0];
wire		[31:0]		uySintSinp[LAT:0];
wire		[63:0]		oneMinusUz2[LAT:0];
wire		[31:0]		uyUzSintCosp[LAT:0];
wire		[31:0]		uxUzSintCosp[LAT:0];
wire		[31:0]		uxSintSinp[LAT:0];
wire		[31:0]		sqrtOneMinusUz2[LAT:0];
wire		[31:0]		sintCospSqrtOneMinusUz2[LAT:0];
wire		[31:0]		uxCost[LAT:0];
wire		[31:0]		uzCost[LAT:0];
wire		[31:0]		sqrtOneMinusUz2_inv[LAT:0];
wire		[31:0]		uxNumerator[LAT:0];
wire		[31:0]		uyNumerator[LAT:0];
wire		[31:0]		uyCost[LAT:0];
wire		[31:0]		uxQuotient[LAT:0];
wire		[31:0]		uyQuotient[LAT:0];

wire		[31:0]		new_sint;
wire		[31:0]		new_cost;
wire		[31:0]		new_sinp;
wire		[31:0]		new_cosp;
wire		[31:0]		new_sintCosp;
wire		[31:0]		new_sintSinp;
wire		[63:0]		new_uz2;
wire		[31:0]		new_uxUz;
wire		[31:0]		new_uyUz;
wire		[31:0]		new_uySintSinp;
wire		[63:0]		new_oneMinusUz2;
wire		[31:0]		new_uyUzSintCosp;
wire		[31:0]		new_uxUzSintCosp;
wire		[31:0]		new_uxSintSinp;
wire		[31:0]		new_sqrtOneMinusUz2;
wire		[31:0]		new_sintCospSqrtOneMinusUz2;
wire		[31:0]		new_uxCost;
wire		[31:0]		new_uzCost;
wire		[31:0]		new_sqrtOneMinusUz2_inv;
wire		[31:0]		new_uxNumerator;
wire		[31:0]		new_uyNumerator;
wire		[31:0]		new_uyCost;
reg		[31:0]		new_uxQuotient;
reg		[31:0]		new_uyQuotient;


//Wiring for calculating final values
wire				uxNumerOverflow;
wire				uyNumerOverflow;
reg					normalIncident;
wire		[31:0]		ux_add_1;
wire		[31:0]		ux_add_2;
wire					uxOverflow;
wire		[31:0]		uy_add_1;
wire		[31:0]		uy_add_2;
wire					uyOverflow;
wire		[31:0]		normalUz;
wire		[31:0]		uz_sub_1;
wire		[31:0]		uz_sub_2;
wire					uzOverflow;
	
wire		[31:0]		new_ux;
wire		[31:0]		new_uy;
wire		[31:0]		new_uz;

wire				div_overflow;
wire				toAnd1_36_1;
wire				toAnd1_36_2;
wire				overflow1_36;
wire				negOverflow1_36;
wire				toAnd2_36_1;
wire				toAnd2_36_2;
wire				overflow2_36;
wire				negOverflow2_36;



//------------------Register Pipeline-----------------
//Generation Methodology: Standard block, called InternalsBlock, is
//repeated multiple times, based on the latency of the reflector and
//scatterer.  This block contains the list of all internal variables
//that need to be registered and passed along in the pipeline.
//
//Previous values in the pipeline are passed to the next register on each
//clock tick.  The exception comes when an internal variable gets
//calculated.  Each time a new internal variable is calculated, a new
//case is added to the case statement, and instead of hooking previous
//values of that variable to next, the new, calculated values are hooked up.
//
//This method will generate many more registers than what are required, but
//it is expected that the synthesis tool will synthesize these away.
//
//
//Commenting Convention: Whenever a new value is injected into the pipe, the
//comment //Changed Value is added directly above the variable in question.
//When multiple values are calculated in a single clock cycle, multiple such
//comments are placed.  Wires connected to "Changed Values" always start with
//the prefix new_.
//
//GENERATE PIPELINE
genvar i;
generate
	for(i=LAT; i>0; i=i-1) begin: internalPipe
		case(i)
		
		2:
		InternalsBlock pipeReg(
			//Inputs
			.clock(clock),
			.reset(reset),
			.enable(enable),
			
			.i_sint(sint[i-1]),
			.i_cost(cost[i-1]),
			.i_sinp(sinp[i-1]),
			.i_cosp(cosp[i-1]),
			.i_sintCosp(sintCosp[i-1]),
			.i_sintSinp(sintSinp[i-1]),
			//Changed Value
			.i_uz2(new_uz2),
			.i_uxUz(uxUz[i-1]),
			.i_uyUz(uyUz[i-1]),
			.i_uySintSinp(uySintSinp[i-1]),
			.i_oneMinusUz2(oneMinusUz2[i-1]),
			.i_uyUzSintCosp(uyUzSintCosp[i-1]),
			.i_uxUzSintCosp(uxUzSintCosp[i-1]),
			.i_uxSintSinp(uxSintSinp[i-1]),
			.i_sqrtOneMinusUz2(sqrtOneMinusUz2[i-1]),
			.i_sintCospSqrtOneMinusUz2(sintCospSqrtOneMinusUz2[i-1]),
			.i_uxCost(uxCost[i-1]),
			.i_uzCost(uzCost[i-1]),
			.i_sqrtOneMinusUz2_inv(sqrtOneMinusUz2_inv[i-1]),
			.i_uxNumerator(uxNumerator[i-1]),
			.i_uyNumerator(uyNumerator[i-1]),
			.i_uyCost(uyCost[i-1]),
			.i_uxQuotient(uxQuotient[i-1]),
			.i_uyQuotient(uyQuotient[i-1]),
			
			//Outputs			
			.o_sint(sint[i]),
			.o_cost(cost[i]),
			.o_sinp(sinp[i]),
			.o_cosp(cosp[i]),
			.o_sintCosp(sintCosp[i]),
			.o_sintSinp(sintSinp[i]),
			.o_uz2(uz2[i]),
			.o_uxUz(uxUz[i]),
			.o_uyUz(uyUz[i]),
			.o_uySintSinp(uySintSinp[i]),
			.o_oneMinusUz2(oneMinusUz2[i]),
			.o_uyUzSintCosp(uyUzSintCosp[i]),
			.o_uxUzSintCosp(uxUzSintCosp[i]),
			.o_uxSintSinp(uxSintSinp[i]),
			.o_sqrtOneMinusUz2(sqrtOneMinusUz2[i]),
			.o_sintCospSqrtOneMinusUz2(sintCospSqrtOneMinusUz2[i]),
			.o_uxCost(uxCost[i]),
			.o_uzCost(uzCost[i]),
			.o_sqrtOneMinusUz2_inv(sqrtOneMinusUz2_inv[i]),
			.o_uxNumerator(uxNumerator[i]),
			.o_uyNumerator(uyNumerator[i]),
			.o_uyCost(uyCost[i]),
			.o_uxQuotient(uxQuotient[i]),
			.o_uyQuotient(uyQuotient[i])
		);
		3:
		InternalsBlock pipeReg(
			//Inputs
			.clock(clock),
			.reset(reset),
			.enable(enable),
			
			.i_sint(sint[i-1]),
			.i_cost(cost[i-1]),
			.i_sinp(sinp[i-1]),
			.i_cosp(cosp[i-1]),
			.i_sintCosp(sintCosp[i-1]),
			.i_sintSinp(sintSinp[i-1]),
			.i_uz2(uz2[i-1]),
			.i_uxUz(uxUz[i-1]),
			.i_uyUz(uyUz[i-1]),
			.i_uySintSinp(uySintSinp[i-1]),
			//Changed Value
			.i_oneMinusUz2(new_oneMinusUz2),
			.i_uyUzSintCosp(uyUzSintCosp[i-1]),
			.i_uxUzSintCosp(uxUzSintCosp[i-1]),
			.i_uxSintSinp(uxSintSinp[i-1]),
			.i_sqrtOneMinusUz2(sqrtOneMinusUz2[i-1]),
			.i_sintCospSqrtOneMinusUz2(sintCospSqrtOneMinusUz2[i-1]),
			.i_uxCost(uxCost[i-1]),
			.i_uzCost(uzCost[i-1]),
			.i_sqrtOneMinusUz2_inv(sqrtOneMinusUz2_inv[i-1]),
			.i_uxNumerator(uxNumerator[i-1]),
			.i_uyNumerator(uyNumerator[i-1]),
			.i_uyCost(uyCost[i-1]),
			.i_uxQuotient(uxQuotient[i-1]),
			.i_uyQuotient(uyQuotient[i-1]),
			
			//Outputs			
			.o_sint(sint[i]),
			.o_cost(cost[i]),
			.o_sinp(sinp[i]),
			.o_cosp(cosp[i]),
			.o_sintCosp(sintCosp[i]),
			.o_sintSinp(sintSinp[i]),
			.o_uz2(uz2[i]),
			.o_uxUz(uxUz[i]),
			.o_uyUz(uyUz[i]),
			.o_uySintSinp(uySintSinp[i]),
			.o_oneMinusUz2(oneMinusUz2[i]),
			.o_uyUzSintCosp(uyUzSintCosp[i]),
			.o_uxUzSintCosp(uxUzSintCosp[i]),
			.o_uxSintSinp(uxSintSinp[i]),
			.o_sqrtOneMinusUz2(sqrtOneMinusUz2[i]),
			.o_sintCospSqrtOneMinusUz2(sintCospSqrtOneMinusUz2[i]),
			.o_uxCost(uxCost[i]),
			.o_uzCost(uzCost[i]),
			.o_sqrtOneMinusUz2_inv(sqrtOneMinusUz2_inv[i]),
			.o_uxNumerator(uxNumerator[i]),
			.o_uyNumerator(uyNumerator[i]),
			.o_uyCost(uyCost[i]),
			.o_uxQuotient(uxQuotient[i]),
			.o_uyQuotient(uyQuotient[i])
		);
		4:
		InternalsBlock pipeReg(
			//Inputs
			.clock(clock),
			.reset(reset),
			.enable(enable),
			
			.i_sint(sint[i-1]),
			.i_cost(cost[i-1]),
			.i_sinp(sinp[i-1]),
			.i_cosp(cosp[i-1]),
			.i_sintCosp(sintCosp[i-1]),
			.i_sintSinp(sintSinp[i-1]),
			.i_uz2(uz2[i-1]),
			//Changed Value
			.i_uxUz(new_uxUz),
			.i_uyUz(uyUz[i-1]),
			.i_uySintSinp(uySintSinp[i-1]),
			.i_oneMinusUz2(oneMinusUz2[i-1]),
			.i_uyUzSintCosp(uyUzSintCosp[i-1]),
			.i_uxUzSintCosp(uxUzSintCosp[i-1]),
			.i_uxSintSinp(uxSintSinp[i-1]),
			.i_sqrtOneMinusUz2(sqrtOneMinusUz2[i-1]),
			.i_sintCospSqrtOneMinusUz2(sintCospSqrtOneMinusUz2[i-1]),
			.i_uxCost(uxCost[i-1]),
			.i_uzCost(uzCost[i-1]),
			.i_sqrtOneMinusUz2_inv(sqrtOneMinusUz2_inv[i-1]),
			.i_uxNumerator(uxNumerator[i-1]),
			.i_uyNumerator(uyNumerator[i-1]),
			.i_uyCost(uyCost[i-1]),
			.i_uxQuotient(uxQuotient[i-1]),
			.i_uyQuotient(uyQuotient[i-1]),
			
			//Outputs			
			.o_sint(sint[i]),
			.o_cost(cost[i]),
			.o_sinp(sinp[i]),
			.o_cosp(cosp[i]),
			.o_sintCosp(sintCosp[i]),
			.o_sintSinp(sintSinp[i]),
			.o_uz2(uz2[i]),
			.o_uxUz(uxUz[i]),
			.o_uyUz(uyUz[i]),
			.o_uySintSinp(uySintSinp[i]),
			.o_oneMinusUz2(oneMinusUz2[i]),
			.o_uyUzSintCosp(uyUzSintCosp[i]),
			.o_uxUzSintCosp(uxUzSintCosp[i]),
			.o_uxSintSinp(uxSintSinp[i]),
			.o_sqrtOneMinusUz2(sqrtOneMinusUz2[i]),
			.o_sintCospSqrtOneMinusUz2(sintCospSqrtOneMinusUz2[i]),
			.o_uxCost(uxCost[i]),
			.o_uzCost(uzCost[i]),
			.o_sqrtOneMinusUz2_inv(sqrtOneMinusUz2_inv[i]),
			.o_uxNumerator(uxNumerator[i]),
			.o_uyNumerator(uyNumerator[i]),
			.o_uyCost(uyCost[i]),
			.o_uxQuotient(uxQuotient[i]),
			.o_uyQuotient(uyQuotient[i])
		);
		(SQRT+6):
		InternalsBlock pipeReg(
			//Inputs
			.clock(clock),
			.reset(reset),
			.enable(enable),
			
			.i_sint(sint[i-1]),
			.i_cost(cost[i-1]),
			.i_sinp(sinp[i-1]),
			.i_cosp(cosp[i-1]),
			.i_sintCosp(sintCosp[i-1]),
			.i_sintSinp(sintSinp[i-1]),
			.i_uz2(uz2[i-1]),
			.i_uxUz(uxUz[i-1]),
			.i_uyUz(uyUz[i-1]),
			.i_uySintSinp(uySintSinp[i-1]),
			.i_oneMinusUz2(oneMinusUz2[i-1]),
			.i_uyUzSintCosp(uyUzSintCosp[i-1]),
			.i_uxUzSintCosp(uxUzSintCosp[i-1]),
			.i_uxSintSinp(uxSintSinp[i-1]),
			//Changed Value
			.i_sqrtOneMinusUz2(new_sqrtOneMinusUz2),
			.i_sintCospSqrtOneMinusUz2(sintCospSqrtOneMinusUz2[i-1]),
			.i_uxCost(uxCost[i-1]),
			.i_uzCost(uzCost[i-1]),
			.i_sqrtOneMinusUz2_inv(sqrtOneMinusUz2_inv[i-1]),
			.i_uxNumerator(uxNumerator[i-1]),
			.i_uyNumerator(uyNumerator[i-1]),
			.i_uyCost(uyCost[i-1]),
			.i_uxQuotient(uxQuotient[i-1]),
			.i_uyQuotient(uyQuotient[i-1]),
			
			//Outputs			
			.o_sint(sint[i]),
			.o_cost(cost[i]),
			.o_sinp(sinp[i]),
			.o_cosp(cosp[i]),
			.o_sintCosp(sintCosp[i]),
			.o_sintSinp(sintSinp[i]),
			.o_uz2(uz2[i]),
			.o_uxUz(uxUz[i]),
			.o_uyUz(uyUz[i]),
			.o_uySintSinp(uySintSinp[i]),
			.o_oneMinusUz2(oneMinusUz2[i]),
			.o_uyUzSintCosp(uyUzSintCosp[i]),
			.o_uxUzSintCosp(uxUzSintCosp[i]),
			.o_uxSintSinp(uxSintSinp[i]),
			.o_sqrtOneMinusUz2(sqrtOneMinusUz2[i]),
			.o_sintCospSqrtOneMinusUz2(sintCospSqrtOneMinusUz2[i]),
			.o_uxCost(uxCost[i]),
			.o_uzCost(uzCost[i]),
			.o_sqrtOneMinusUz2_inv(sqrtOneMinusUz2_inv[i]),
			.o_uxNumerator(uxNumerator[i]),
			.o_uyNumerator(uyNumerator[i]),
			.o_uyCost(uyCost[i]),
			.o_uxQuotient(uxQuotient[i]),
			.o_uyQuotient(uyQuotient[i])
		);
		
		(SQRT+DIV+3):
		InternalsBlock pipeReg(
			//Inputs
			.clock(clock),
			.reset(reset),
			.enable(enable),
			
			//Changed Value
			.i_sint(new_sint),
			//Changed Value
			.i_cost(new_cost),
			//Changed Value
			.i_sinp(new_sinp),
			//Changed Value
			.i_cosp(new_cosp),
			//Changed Value
			.i_sintCosp(new_sintCosp),
			//Changed Value
			.i_sintSinp(new_sintSinp),
			.i_uz2(uz2[i-1]),
			.i_uxUz(uxUz[i-1]),
			//Changed Value
			.i_uyUz(new_uyUz),
			.i_uySintSinp(uySintSinp[i-1]),
			.i_oneMinusUz2(oneMinusUz2[i-1]),
			.i_uyUzSintCosp(uyUzSintCosp[i-1]),
			.i_uxUzSintCosp(uxUzSintCosp[i-1]),
			.i_uxSintSinp(uxSintSinp[i-1]),
			.i_sqrtOneMinusUz2(sqrtOneMinusUz2[i-1]),
			.i_sintCospSqrtOneMinusUz2(sintCospSqrtOneMinusUz2[i-1]),
			.i_uxCost(uxCost[i-1]),
			.i_uzCost(uzCost[i-1]),
			.i_sqrtOneMinusUz2_inv(sqrtOneMinusUz2_inv[i-1]),
			.i_uxNumerator(uxNumerator[i-1]),
			.i_uyNumerator(uyNumerator[i-1]),
			.i_uyCost(uyCost[i-1]),
			.i_uxQuotient(uxQuotient[i-1]),
			.i_uyQuotient(uyQuotient[i-1]),
			
			//Outputs			
			.o_sint(sint[i]),
			.o_cost(cost[i]),
			.o_sinp(sinp[i]),
			.o_cosp(cosp[i]),
			.o_sintCosp(sintCosp[i]),
			.o_sintSinp(sintSinp[i]),
			.o_uz2(uz2[i]),
			.o_uxUz(uxUz[i]),
			.o_uyUz(uyUz[i]),
			.o_uySintSinp(uySintSinp[i]),
			.o_oneMinusUz2(oneMinusUz2[i]),
			.o_uyUzSintCosp(uyUzSintCosp[i]),
			.o_uxUzSintCosp(uxUzSintCosp[i]),
			.o_uxSintSinp(uxSintSinp[i]),
			.o_sqrtOneMinusUz2(sqrtOneMinusUz2[i]),
			.o_sintCospSqrtOneMinusUz2(sintCospSqrtOneMinusUz2[i]),
			.o_uxCost(uxCost[i]),
			.o_uzCost(uzCost[i]),
			.o_sqrtOneMinusUz2_inv(sqrtOneMinusUz2_inv[i]),
			.o_uxNumerator(uxNumerator[i]),
			.o_uyNumerator(uyNumerator[i]),
			.o_uyCost(uyCost[i]),
			.o_uxQuotient(uxQuotient[i]),
			.o_uyQuotient(uyQuotient[i])
		);
		
		(SQRT+DIV+4):
		InternalsBlock pipeReg(
			//Inputs
			.clock(clock),
			.reset(reset),
			.enable(enable),
			
			.i_sint(sint[i-1]),
			.i_cost(cost[i-1]),
			.i_sinp(sinp[i-1]),
			.i_cosp(cosp[i-1]),
			.i_sintCosp(sintCosp[i-1]),
			.i_sintSinp(sintSinp[i-1]),
			.i_uz2(uz2[i-1]),
			.i_uxUz(uxUz[i-1]),
			.i_uyUz(uyUz[i-1]),
			//Changed Value
			.i_uySintSinp(new_uySintSinp),
			.i_oneMinusUz2(oneMinusUz2[i-1]),
			//Changed Value
			.i_uyUzSintCosp(new_uyUzSintCosp),
			//Changed Value
			.i_uxUzSintCosp(new_uxUzSintCosp),
			//Changed Value
			.i_uxSintSinp(new_uxSintSinp),
			.i_sqrtOneMinusUz2(sqrtOneMinusUz2[i-1]),
			.i_sintCospSqrtOneMinusUz2(sintCospSqrtOneMinusUz2[i-1]),
			.i_uxCost(uxCost[i-1]),
			.i_uzCost(uzCost[i-1]),
			.i_sqrtOneMinusUz2_inv(sqrtOneMinusUz2_inv[i-1]),
			.i_uxNumerator(uxNumerator[i-1]),
			.i_uyNumerator(uyNumerator[i-1]),
			.i_uyCost(uyCost[i-1]),
			.i_uxQuotient(uxQuotient[i-1]),
			.i_uyQuotient(uyQuotient[i-1]),
			
			//Outputs			
			.o_sint(sint[i]),
			.o_cost(cost[i]),
			.o_sinp(sinp[i]),
			.o_cosp(cosp[i]),
			.o_sintCosp(sintCosp[i]),
			.o_sintSinp(sintSinp[i]),
			.o_uz2(uz2[i]),
			.o_uxUz(uxUz[i]),
			.o_uyUz(uyUz[i]),
			.o_uySintSinp(uySintSinp[i]),
			.o_oneMinusUz2(oneMinusUz2[i]),
			.o_uyUzSintCosp(uyUzSintCosp[i]),
			.o_uxUzSintCosp(uxUzSintCosp[i]),
			.o_uxSintSinp(uxSintSinp[i]),
			.o_sqrtOneMinusUz2(sqrtOneMinusUz2[i]),
			.o_sintCospSqrtOneMinusUz2(sintCospSqrtOneMinusUz2[i]),
			.o_uxCost(uxCost[i]),
			.o_uzCost(uzCost[i]),
			.o_sqrtOneMinusUz2_inv(sqrtOneMinusUz2_inv[i]),
			.o_uxNumerator(uxNumerator[i]),
			.o_uyNumerator(uyNumerator[i]),
			.o_uyCost(uyCost[i]),
			.o_uxQuotient(uxQuotient[i]),
			.o_uyQuotient(uyQuotient[i])
		);
		
		(SQRT+DIV+5):
		InternalsBlock pipeReg(
			//Inputs
			.clock(clock),
			.reset(reset),
			.enable(enable),
			
			.i_sint(sint[i-1]),
			.i_cost(cost[i-1]),
			.i_sinp(sinp[i-1]),
			.i_cosp(cosp[i-1]),
			.i_sintCosp(sintCosp[i-1]),
			.i_sintSinp(sintSinp[i-1]),
			.i_uz2(uz2[i-1]),
			.i_uxUz(uxUz[i-1]),
			.i_uyUz(uyUz[i-1]),
			.i_uySintSinp(uySintSinp[i-1]),
			.i_oneMinusUz2(oneMinusUz2[i-1]),
			.i_uyUzSintCosp(uyUzSintCosp[i-1]),
			.i_uxUzSintCosp(uxUzSintCosp[i-1]),
			.i_uxSintSinp(uxSintSinp[i-1]),
			.i_sqrtOneMinusUz2(sqrtOneMinusUz2[i-1]),
			.i_sintCospSqrtOneMinusUz2(sintCospSqrtOneMinusUz2[i-1]),
			.i_uxCost(uxCost[i-1]),
			.i_uzCost(uzCost[i-1]),
			//Changed Value
			.i_sqrtOneMinusUz2_inv(new_sqrtOneMinusUz2_inv),
			//Changed Value
			.i_uxNumerator(new_uxNumerator),
			//Changed Value
			.i_uyNumerator(new_uyNumerator),
			.i_uyCost(uyCost[i-1]),
			.i_uxQuotient(uxQuotient[i-1]),
			.i_uyQuotient(uyQuotient[i-1]),
			
			//Outputs			
			.o_sint(sint[i]),
			.o_cost(cost[i]),
			.o_sinp(sinp[i]),
			.o_cosp(cosp[i]),
			.o_sintCosp(sintCosp[i]),
			.o_sintSinp(sintSinp[i]),
			.o_uz2(uz2[i]),
			.o_uxUz(uxUz[i]),
			.o_uyUz(uyUz[i]),
			.o_uySintSinp(uySintSinp[i]),
			.o_oneMinusUz2(oneMinusUz2[i]),
			.o_uyUzSintCosp(uyUzSintCosp[i]),
			.o_uxUzSintCosp(uxUzSintCosp[i]),
			.o_uxSintSinp(uxSintSinp[i]),
			.o_sqrtOneMinusUz2(sqrtOneMinusUz2[i]),
			.o_sintCospSqrtOneMinusUz2(sintCospSqrtOneMinusUz2[i]),
			.o_uxCost(uxCost[i]),
			.o_uzCost(uzCost[i]),
			.o_sqrtOneMinusUz2_inv(sqrtOneMinusUz2_inv[i]),
			.o_uxNumerator(uxNumerator[i]),
			.o_uyNumerator(uyNumerator[i]),
			.o_uyCost(uyCost[i]),
			.o_uxQuotient(uxQuotient[i]),
			.o_uyQuotient(uyQuotient[i])
		);
		
		(SQRT+DIV+6):
		InternalsBlock pipeReg(
			//Inputs
			.clock(clock),
			.reset(reset),
			.enable(enable),

			.i_sint(sint[i-1]),
			.i_cost(cost[i-1]),
			.i_sinp(sinp[i-1]),
			.i_cosp(cosp[i-1]),
			.i_sintCosp(sintCosp[i-1]),
			.i_sintSinp(sintSinp[i-1]),
			.i_uz2(uz2[i-1]),
			.i_uxUz(uxUz[i-1]),
			.i_uyUz(uyUz[i-1]),
			.i_uySintSinp(uySintSinp[i-1]),
			.i_oneMinusUz2(oneMinusUz2[i-1]),
			.i_uyUzSintCosp(uyUzSintCosp[i-1]),
			.i_uxUzSintCosp(uxUzSintCosp[i-1]),
			.i_uxSintSinp(uxSintSinp[i-1]),
			.i_sqrtOneMinusUz2(sqrtOneMinusUz2[i-1]),
			//Changed Value
			.i_sintCospSqrtOneMinusUz2(new_sintCospSqrtOneMinusUz2),
			//Changed Value
			.i_uxCost(new_uxCost),
			//Changed Value
			.i_uzCost(new_uzCost),
			.i_sqrtOneMinusUz2_inv(sqrtOneMinusUz2_inv[i-1]),
			.i_uxNumerator(uxNumerator[i-1]),
			.i_uyNumerator(uyNumerator[i-1]),
			//Changed Value
			.i_uyCost(new_uyCost),
			//Changed Value
			.i_uxQuotient(new_uxQuotient),
			//Changed Value
			.i_uyQuotient(new_uyQuotient),
			
			//Outputs			
			.o_sint(sint[i]),
			.o_cost(cost[i]),
			.o_sinp(sinp[i]),
			.o_cosp(cosp[i]),
			.o_sintCosp(sintCosp[i]),
			.o_sintSinp(sintSinp[i]),
			.o_uz2(uz2[i]),
			.o_uxUz(uxUz[i]),
			.o_uyUz(uyUz[i]),
			.o_uySintSinp(uySintSinp[i]),
			.o_oneMinusUz2(oneMinusUz2[i]),
			.o_uyUzSintCosp(uyUzSintCosp[i]),
			.o_uxUzSintCosp(uxUzSintCosp[i]),
			.o_uxSintSinp(uxSintSinp[i]),
			.o_sqrtOneMinusUz2(sqrtOneMinusUz2[i]),
			.o_sintCospSqrtOneMinusUz2(sintCospSqrtOneMinusUz2[i]),
			.o_uxCost(uxCost[i]),
			.o_uzCost(uzCost[i]),
			.o_sqrtOneMinusUz2_inv(sqrtOneMinusUz2_inv[i]),
			.o_uxNumerator(uxNumerator[i]),
			.o_uyNumerator(uyNumerator[i]),
			.o_uyCost(uyCost[i]),
			.o_uxQuotient(uxQuotient[i]),
			.o_uyQuotient(uyQuotient[i])
		);
		
		default:
		InternalsBlock pipeReg(
			//Inputs
			.clock(clock),
			.reset(reset),
			.enable(enable),
			
			.i_sint(sint[i-1]),
			.i_cost(cost[i-1]),
			.i_sinp(sinp[i-1]),
			.i_cosp(cosp[i-1]),
			.i_sintCosp(sintCosp[i-1]),
			.i_sintSinp(sintSinp[i-1]),
			.i_uz2(uz2[i-1]),
			.i_uxUz(uxUz[i-1]),
			.i_uyUz(uyUz[i-1]),
			.i_uySintSinp(uySintSinp[i-1]),
			.i_oneMinusUz2(oneMinusUz2[i-1]),
			.i_uyUzSintCosp(uyUzSintCosp[i-1]),
			.i_uxUzSintCosp(uxUzSintCosp[i-1]),
			.i_uxSintSinp(uxSintSinp[i-1]),
			.i_sqrtOneMinusUz2(sqrtOneMinusUz2[i-1]),
			.i_sintCospSqrtOneMinusUz2(sintCospSqrtOneMinusUz2[i-1]),
			.i_uxCost(uxCost[i-1]),
			.i_uzCost(uzCost[i-1]),
			.i_sqrtOneMinusUz2_inv(sqrtOneMinusUz2_inv[i-1]),
			.i_uxNumerator(uxNumerator[i-1]),
			.i_uyNumerator(uyNumerator[i-1]),
			.i_uyCost(uyCost[i-1]),
			.i_uxQuotient(uxQuotient[i-1]),
			.i_uyQuotient(uyQuotient[i-1]),
			
			//Outputs			
			.o_sint(sint[i]),
			.o_cost(cost[i]),
			.o_sinp(sinp[i]),
			.o_cosp(cosp[i]),
			.o_sintCosp(sintCosp[i]),
			.o_sintSinp(sintSinp[i]),
			.o_uz2(uz2[i]),
			.o_uxUz(uxUz[i]),
			.o_uyUz(uyUz[i]),
			.o_uySintSinp(uySintSinp[i]),
			.o_oneMinusUz2(oneMinusUz2[i]),
			.o_uyUzSintCosp(uyUzSintCosp[i]),
			.o_uxUzSintCosp(uxUzSintCosp[i]),
			.o_uxSintSinp(uxSintSinp[i]),
			.o_sqrtOneMinusUz2(sqrtOneMinusUz2[i]),
			.o_sintCospSqrtOneMinusUz2(sintCospSqrtOneMinusUz2[i]),
			.o_uxCost(uxCost[i]),
			.o_uzCost(uzCost[i]),
			.o_sqrtOneMinusUz2_inv(sqrtOneMinusUz2_inv[i]),
			.o_uxNumerator(uxNumerator[i]),
			.o_uyNumerator(uyNumerator[i]),
			.o_uyCost(uyCost[i]),
			.o_uxQuotient(uxQuotient[i]),
			.o_uyQuotient(uyQuotient[i])
		);
		endcase
	end
endgenerate	
//-------------SYNCHRONOUS LOGIC----------------------
//
//
//
//
//
//
//
//
//
//
//
//
//This is the end of the generate statement, and the beginning of the
//synchronous logic.  On the clock event, the outputs calculated from
//this block are put on the output pins for reading (registered
//outputs, as per the convention).




//Assign outputs from block on positive clock edge.
always @ (posedge clock) begin
	if(reset) begin
		//Reset internal non-pipelined registers here.
		ux_scatterer	<= 32'h00000000;
		uy_scatterer	<= 32'h00000000;
		uz_scatterer	<= 32'h7FFFFFFF;
	end else if (enable) begin
		ux_scatterer <= new_ux;
		uy_scatterer <= new_uy;
		uz_scatterer <= new_uz;
	end
end

//-------------ASYNCHRONOUS LOGIC----------------------
//
//
//
//
//
//
//
//
//
//
//
//
//This is where the asynchronous logic takes place.  Things that
//occur here include setting up wiring to send to the multipliers,
//divide unit, and square root unit.  Also, products brought in
//from the wrapper are placed on the appropriate wires for placement
//in the pipeline.




//-------------OPERAND SETUP----------------------


//NAMING CONVENTION:
//opX_Y_Z, op stands for operand, X stands for the multiplication number for
//that clock cycle, Y stands for the clock cycle, Z is either 1 or 2 for the
//first or second operand for this multiply
//
//COMMENTING CONVENTIONS:
//CC X means that the values being calculated will be ready for the Xth register
//location, where 0 is the register prior to any calculations being done, 1 is
//after the 1st clock cycle of calculation, etc.

//CC 2
assign	op1_2_1						=	i_uz1;
assign	op1_2_2						=	i_uz1;
	
//CC 3
//SUBTRACTION, see math results
	
//CC 4
assign	op1_4_1						=	i_ux3;
assign	op1_4_2						=	i_uz3;

//CC 5 -- NOOP, line up with reflector
	
//CC SQRT+5 -- Started in CC 6
assign	sqrtOperand1_6				=	oneMinusUz2[5];

//CC SQRT+DIV+6 -- Started in CC SQRT+5
assign	divNumerator1_16			=	INTMAX_2;
//assign	divDenominator1_16			=	sqrtOneMinusUz2[SQRT+5];
assign	divDenominator1_16			=	new_sqrtOneMinusUz2;

//CC SQRT+DIV+3
assign op1_33_1						=	sint_Mem;
assign op1_33_2						=	cosp_Mem;

assign op2_33_1						=	sint_Mem;
assign op2_33_2						=	sinp_Mem;

assign op3_33_1						=	i_uy32;
assign op3_33_2						=	i_uz32;

//CC SQRT+DIV+4
assign op1_34_1						=	i_ux33;
assign op1_34_2						=	sintSinp[SQRT+DIV+3];

assign op2_34_1						=	i_uy33;
assign op2_34_2						=	sintSinp[SQRT+DIV+3];

assign op3_34_1						=	uxUz[SQRT+DIV+3];
assign op3_34_2						=	sintCosp[SQRT+DIV+3];

assign op4_34_1						=	uyUz[SQRT+DIV+3];
assign op4_34_2						=	sintCosp[SQRT+DIV+3];

//CC SQRT+DIV+5
//2 SUBS (see math results)
//DIVISION COMPLETE (see math results)

//CC SQRT+DIV+6 -- Division is now complete and can be read.
assign op1_36_1						=	uxNumerator[SQRT+DIV+5];
assign op1_36_2						=	new_sqrtOneMinusUz2_inv;


assign op2_36_1						=	uyNumerator[SQRT+DIV+5];
assign op2_36_2						=	new_sqrtOneMinusUz2_inv;

assign op3_36_1						=	sintCosp[SQRT+DIV+5];
assign op3_36_2						=	sqrtOneMinusUz2[SQRT+DIV+5];

assign op4_36_1						=	i_ux35;
assign op4_36_2						=	cost[SQRT+DIV+5];

assign op5_36_1						=	i_uy35;
assign op5_36_2						=	cost[SQRT+DIV+5];

assign op6_36_1						=	i_uz35;
assign op6_36_2						=	cost[SQRT+DIV+5];


//-------------MATH RESULTS----------------------


//NAMING CONVENTION:
//new_VAR means that the variable named VAR will be stored into the register
//pipeline at the clock cycle indicated by the comments above it.
//
//prod stands for product, quot stands for quotient, sqrt stands for square root
//prodX_Y means the Xth product which started calculation at the Yth clock cycle
//Similarly for quot and sqrtResult.
//
//
//COMMENTING CONVENTIONS:
//CC X means that the values being calculated will be ready for the Xth register
//location, where 0 is the register prior to any calculations being done, 1 is
//after the 1st clock cycle of calculation, etc.


//Used to determine whether or not the divide operation overflowed.
or U1(div_overflow, quot1_16[62], quot1_16[61], quot1_16[60], quot1_16[59], quot1_16[58], quot1_16[57], quot1_16[56], quot1_16[55], quot1_16[54], quot1_16[53], quot1_16[52], quot1_16[51], quot1_16[50], quot1_16[49], quot1_16[48], quot1_16[47]);

//Used to determine whether or not the multiply operation overflowed.
or U2(toAnd1_36_1, prod1_36[62], prod1_36[61], prod1_36[60], prod1_36[59], prod1_36[58], prod1_36[57], prod1_36[56], prod1_36[55], prod1_36[54], prod1_36[53], prod1_36[52], prod1_36[51], prod1_36[50], prod1_36[49], prod1_36[48], prod1_36[47], prod1_36[46]);
//Used to determine whether or not the multiply operation overflowed in the negative direction.
or U3(toAnd1_36_2, ~prod1_36[62], ~prod1_36[61], ~prod1_36[60], ~prod1_36[59], ~prod1_36[58], ~prod1_36[57], ~prod1_36[56], ~prod1_36[55], ~prod1_36[54], ~prod1_36[53], ~prod1_36[52], ~prod1_36[51], ~prod1_36[50], ~prod1_36[49], ~prod1_36[48], ~prod1_36[47], ~prod1_36[46]);

and U4(overflow1_36, ~prod1_36[63], toAnd1_36_1);
and U5(negOverflow1_36, prod1_36[63], toAnd1_36_2);


//Used to determine whether or not the multiply operation overflowed.
or U6(toAnd2_36_1, prod2_36[62], prod2_36[61], prod2_36[60], prod2_36[59], prod2_36[58], prod2_36[57], prod2_36[56], prod2_36[55], prod2_36[54], prod2_36[53], prod2_36[52], prod2_36[51], prod2_36[50], prod2_36[49], prod2_36[48], prod2_36[47], prod2_36[46]);
//Used to determine whether or not the multiply operation overflowed in the negative direction.
or U7(toAnd2_36_2, ~prod2_36[62], ~prod2_36[61], ~prod2_36[60], ~prod2_36[59], ~prod2_36[58], ~prod2_36[57], ~prod2_36[56], ~prod2_36[55], ~prod2_36[54], ~prod2_36[53], ~prod2_36[52], ~prod2_36[51], ~prod2_36[50], ~prod2_36[49], ~prod2_36[48], ~prod2_36[47], ~prod2_36[46]);

and U8(overflow2_36, ~prod2_36[63], toAnd2_36_1);
and U9(negOverflow2_36, prod2_36[63], toAnd2_36_2);



//CC 2
assign new_uz2						= prod1_2;
//CC 3
sub_64b		oneMinusUz2_sub(
				.dataa(INTMAX_2),
				.datab(uz2[2]),
				.result(new_oneMinusUz2)
		);

//CC 4
assign new_uxUz						= prod1_4;
//CC SQRT+5
assign new_sqrtOneMinusUz2			= sqrtResult1_6;
//CC SQRT+DIV+3
assign new_sintCosp					= prod1_33;
assign new_sintSinp					= prod2_33;
assign new_uyUz						= prod3_33;
//CC SQRT+DIV+4
assign new_sint						= sint_Mem;
assign new_cost						= cost_Mem;
assign new_sinp						= sinp_Mem;
assign new_cosp						= cosp_Mem;
assign new_uxSintSinp				= prod1_34;
assign new_uySintSinp				= prod2_34;
assign new_uxUzSintCosp				= prod3_34;
assign new_uyUzSintCosp				= prod4_34;
//CC SQRT+DIV+5
sub_32b		uxNumer_sub(
				.dataa(uxUzSintCosp[SQRT+DIV+4]),
				.datab(uySintSinp[SQRT+DIV+4]),
				.overflow(uxNumerOverflow),
				.result(new_uxNumerator)
			);

add_32b		uyNumer_add(
				.dataa(uyUzSintCosp[SQRT+DIV+4]),
				.datab(uxSintSinp[SQRT+DIV+4]),
				.overflow(uyNumerOverflow),
				.result(new_uyNumerator)
			);


//Possibility for division overflow (whereby the inverse is too large).  Data storage for this
//value is 15 bits left of the decimal, and 16 bits to the right.
assign new_sqrtOneMinusUz2_inv			=  (div_overflow) ? INTMAX		:	{quot1_16[63:63], quot1_16[46:16]};

//CC SQRT+DIV+6
always @ (*) begin
	case ({overflow1_36, negOverflow1_36})
	0:	new_uxQuotient = {prod1_36[63:63], prod1_36[45:15]};
	1:	new_uxQuotient = INTMIN;
	2:	new_uxQuotient = INTMAX;
	//Should never occur
	3:	new_uxQuotient = {prod1_36[63:63], prod1_36[45:15]};
	endcase
	
	case ({overflow2_36, negOverflow2_36})
	
	0:	new_uyQuotient = {prod2_36[63:63], prod2_36[45:15]};
	1:	new_uyQuotient = INTMIN;
	2:	new_uyQuotient = INTMAX;
		//Should never occur
	3:	new_uyQuotient = {prod2_36[63:63], prod2_36[45:15]};
	endcase
end

/*always @ (*) begin
	new_uxQuotient = {prod1_36[63:63], prod1_36[47:16]};
	new_uyQuotient = {prod2_36[63:63], prod2_36[47:16]};
end*/

assign new_sintCospSqrtOneMinusUz2	= prod3_36;
assign new_uxCost					= prod4_36;
assign new_uyCost					= prod5_36;
assign new_uzCost					= prod6_36;



//-----------------------FINAL RESULT CALCULATIONS--------------
//
//
//
//
//
//
//
//At this point, all calculations have been completed, save the
//final results.  This part of the code decides whether or not the
//current calculation involved a normal (orthogonal) incident or not,
//and uses this information to determine how to calculate the
//final results.  Final results are put on wires new_ux, new_uy, and
//new_uz, where they are output to registers ux_scatterer,
//uy_scatterer, and uz_scatterer on the clock event for synchronization
//(registered outputs, as per the convention).



//Determine whether or not the photon calculation was done on a photon that
//was normal (orthogonal) to the plane of interest.  This is to avoid divide
//by zero errors
always @ (*) begin
	//If uz >= INTMAX-3 || uz <= -INTMAX+3, normal incident
	if(i_uz36 == 32'h7FFFFFFF || i_uz36 == 32'h7FFFFFFE || i_uz36 == 32'h7FFFFFFD || i_uz36 == 32'h7FFFFFFC || i_uz36 == 32'h80000000 || i_uz36 == 32'h80000001 || i_uz36 == 32'h80000002 || i_uz36 == 32'h80000003 || i_uz36 == 32'h80000004) begin
		normalIncident = 1'b1;
	end else begin
		normalIncident = 1'b0;
	end
end



//Assign calculation values for final ux result
assign ux_add_1 = (normalIncident) ? sintCosp[LAT-1]	:	uxQuotient[LAT-1];
assign ux_add_2 = (normalIncident) ? 32'h00000000		:	uxCost[LAT-1];

add_32b		ux_add(
				.dataa(ux_add_1),
				.datab(ux_add_2),
				.overflow(uxOverflow),
				.result(new_ux)
			);

//Assign calculation values for final uy result
assign uy_add_1 = (normalIncident)	? sintSinp[LAT-1]	:	uyQuotient[LAT-1];
assign uy_add_2 = (normalIncident)	? 32'h00000000		:	uyCost[LAT-1];

add_32b		uy_add(
				.dataa(uy_add_1),
				.datab(uy_add_2),
				.overflow(uyOverflow),
				.result(new_uy)
			);




//Assign calculation values for final uz result.
//First MUX implements SIGN(uz) function.
assign normalUz = (i_uz36 >=0)		? cost[LAT-1]		:	-1*cost[LAT-1];
assign uz_sub_1 = (normalIncident)	? normalUz			:	uzCost[LAT-1];
assign uz_sub_2 = (normalIncident)	? 32'h00000000		:	sintCospSqrtOneMinusUz2[LAT-1];

sub_32b		uz_sub(
				.dataa(uz_sub_1),
				.datab(uz_sub_2),
				.overflow(uzOverflow),
				.result(new_uz)
			);




endmodule

