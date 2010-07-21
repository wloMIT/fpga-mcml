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
//  Internal registers within the reflector.
//////////////////////////////////////////////////////////////////////////////////


module InternalsBlock_Reflector(
	//Inputs
	clock,
	reset,
	enable,

	i_uz_2,			//uz^2
	i_uz2,			//new uz, should the photon transmit to new layer
	i_oneMinusUz_2, 	//(1-uz)^2
	i_sa2_2,		//(sine of angle 2)^2 (uz2 = cosine of angle 2).
	i_uz2_2,		//(uz2)^2, new uz squared.
	i_ux_transmitted,	//new value for ux, if the photon transmits to the next layer
	i_uy_transmitted,	//new value for uy, if the photon transmits to the next layer
	
	//Outputs
	o_uz_2,
	o_uz2,
	o_oneMinusUz_2,
	o_sa2_2,
	o_uz2_2,
	o_ux_transmitted,
	o_uy_transmitted
	);

input					clock;
input					reset;
input					enable;

input		[63:0]		i_uz_2;
input		[31:0]		i_uz2;
input		[63:0]		i_oneMinusUz_2;
input		[63:0]		i_sa2_2;
input		[63:0]		i_uz2_2;
input		[31:0]		i_ux_transmitted;
input		[31:0]		i_uy_transmitted;

output		[63:0]		o_uz_2;
output		[31:0]		o_uz2;
output		[63:0]		o_oneMinusUz_2;
output		[63:0]		o_sa2_2;
output		[63:0]		o_uz2_2;
output		[31:0]		o_ux_transmitted;
output		[31:0]		o_uy_transmitted;


wire					clock;
wire					reset;
wire					enable;

wire		[63:0]		i_uz_2;
wire		[31:0]		i_uz2;
wire		[63:0]		i_oneMinusUz_2;
wire		[63:0]		i_sa2_2;
wire		[63:0]		i_uz2_2;
wire		[31:0]		i_ux_transmitted;
wire		[31:0]		i_uy_transmitted;


reg		[63:0]		o_uz_2;
reg		[31:0]		o_uz2;
reg		[63:0]		o_oneMinusUz_2;
reg		[63:0]		o_sa2_2;
reg		[63:0]		o_uz2_2;
reg		[31:0]		o_ux_transmitted;
reg		[31:0]		o_uy_transmitted;



always @ (posedge clock)
	if(reset) begin
		o_uz_2					<= 64'h3FFFFFFFFFFFFFFF;
		o_uz2					<= 32'h7FFFFFFF;
		o_oneMinusUz_2				<= 64'h0000000000000000;
		o_sa2_2					<= 64'h0000000000000000;
		o_uz2_2					<= 64'h3FFFFFFFFFFFFFFF;
		o_ux_transmitted			<= 32'h00000000;
		o_uy_transmitted			<= 32'h00000000;
	end else if(enable) begin
		o_uz_2					<= i_uz_2;
		o_uz2					<= i_uz2;
		o_oneMinusUz_2				<= i_oneMinusUz_2;
		o_sa2_2					<= i_sa2_2;
		o_uz2_2					<= i_uz2_2;
		o_ux_transmitted			<= i_ux_transmitted;
		o_uy_transmitted			<= i_uy_transmitted;
	end
endmodule

//////////////////////////////////////////////////////////////////////////////////
//  #####    ######   ######   #        ######    ####    #####    ####    #####
//  #    #   #        #        #        #        #    #     #     #    #   #    #
//  #    #   #####    ####     #        #####    #          #     #    #   #    #
//  #####    #        #        #        #        #          #     #    #   #####
//  #   #    #        #        #        #        #    #     #     #    #   #   #
//  #    #   ######   #        ######   ######    ####      #      ####    #    #
//
//
//
//NAMING CONVENTION:
//prodX_Y means the Xth product which started calculation at the Yth clock cycle
//opX_Y_Z means the Zth operand for the Xth product of the Yth cycle
//i_uxN means input from the Nth register in the pipeline, the value of ux.
//////////////////////////////////////////////////////////////////////////////////

module Reflector (
	
	//INPUTS
	clock,
	reset,
	enable,
	//Values from Photon Pipeline
	i_uz1,
	i_uz3,
	i_layer3,
	i_ux35,
	i_uy35,
	i_uz35,
	i_layer35,
	i_ux36,
	i_uy36,
	i_uz36,
	i_layer36,
	i_dead36,
	
	//Constants
	down_niOverNt_1,
	down_niOverNt_2,
	down_niOverNt_3,
	down_niOverNt_4,
	down_niOverNt_5,
	up_niOverNt_1,
	up_niOverNt_2,
	up_niOverNt_3,
	up_niOverNt_4,
	up_niOverNt_5,
	down_niOverNt_2_1,
	down_niOverNt_2_2,
	down_niOverNt_2_3,
	down_niOverNt_2_4,
	down_niOverNt_2_5,
	up_niOverNt_2_1,
	up_niOverNt_2_2,
	up_niOverNt_2_3,
	up_niOverNt_2_4,
	up_niOverNt_2_5,
	downCritAngle_0,
	downCritAngle_1,
	downCritAngle_2,
	downCritAngle_3,
	downCritAngle_4,
	upCritAngle_0,
	upCritAngle_1,
	upCritAngle_2,
	upCritAngle_3,
	upCritAngle_4,
	
	//Fresnels inputs
	rnd,
	up_rFresnel,
	down_rFresnel,
	
	//Mathematics Results
	prod1_2,
	prod1_4,
	sqrtResult1_6,
	prod1_36,
	prod2_36,
	
	
	//OUTPUTS
	
	//Fresnels outputs
	fresIndex,
	
	//Mathematics Operands
	op1_2_1,
	op1_2_2,
	op1_4_1,
	op1_4_2,
	sqrtOperand1_6,
	op1_36_1,
	op1_36_2,
	op2_36_1,
	op2_36_2,

	
	//Final Calculated Results
	ux_reflector,
	uy_reflector,
	uz_reflector,
	layer_reflector,
	dead_reflector
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
parameter INTMAX_2 = 64'h3FFFFFFFFFFFFFFF;
parameter INTMAX = 2147483647;
parameter INTMIN = -2147483647;


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
input					clock;
input					reset;
input					enable;

//Values from Photon Pipeline
input		[31:0]			i_uz1;
input		[31:0]			i_uz3;
input		[2:0]			i_layer3;
input		[31:0]			i_ux35;
input		[31:0]			i_uy35;
input		[31:0]			i_uz35;
input		[2:0]			i_layer35;
input		[31:0]			i_ux36;
input		[31:0]			i_uy36;
input		[31:0]			i_uz36;
input		[2:0]			i_layer36;
input					i_dead36;

//Constants
input		[31:0]			down_niOverNt_1;
input		[31:0]			down_niOverNt_2;
input		[31:0]			down_niOverNt_3;
input		[31:0]			down_niOverNt_4;
input		[31:0]			down_niOverNt_5;
input		[31:0]			up_niOverNt_1;
input		[31:0]			up_niOverNt_2;
input		[31:0]			up_niOverNt_3;
input		[31:0]			up_niOverNt_4;
input		[31:0]			up_niOverNt_5;
input		[63:0]			down_niOverNt_2_1;
input		[63:0]			down_niOverNt_2_2;
input		[63:0]			down_niOverNt_2_3;
input		[63:0]			down_niOverNt_2_4;
input		[63:0]			down_niOverNt_2_5;
input		[63:0]			up_niOverNt_2_1;
input		[63:0]			up_niOverNt_2_2;
input		[63:0]			up_niOverNt_2_3;
input		[63:0]			up_niOverNt_2_4;
input		[63:0]			up_niOverNt_2_5;
input		[31:0]			downCritAngle_0;
input		[31:0]			downCritAngle_1;
input		[31:0]			downCritAngle_2;
input		[31:0]			downCritAngle_3;
input		[31:0]			downCritAngle_4;
input		[31:0]			upCritAngle_0;
input		[31:0]			upCritAngle_1;
input		[31:0]			upCritAngle_2;
input		[31:0]			upCritAngle_3;
input		[31:0]			upCritAngle_4;

//Fresnels inputs
input		[31:0]			rnd;
input		[31:0]			up_rFresnel;
input		[31:0]			down_rFresnel;

//Mathematics Results
input		[63:0]			prod1_2;
input		[63:0]			prod1_4;
input		[31:0]			sqrtResult1_6;
input		[63:0]			prod1_36;
input		[63:0]			prod2_36;

//OUTPUTS

//Fresnels outputs
output		[9:0]			fresIndex;

//Mathematics operands
output		[31:0]			op1_2_1;
output		[31:0]			op1_2_2;
output		[31:0]			op1_4_1;
output		[31:0]			op1_4_2;
output		[63:0]			sqrtOperand1_6;
output		[31:0]			op1_36_1;
output		[31:0]			op1_36_2;
output		[31:0]			op2_36_1;
output		[31:0]			op2_36_2;


//Final Calculated Results
output		[31:0]			ux_reflector;
output		[31:0]			uy_reflector;
output		[31:0]			uz_reflector;
output		[2:0]			layer_reflector;
output					dead_reflector;


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

wire					clock;
wire					reset;
wire					enable;
//Values from Photon Pipeline
wire		[31:0]			i_uz1;
wire		[31:0]			i_uz3;
wire		[2:0]			i_layer3;
wire		[31:0]			i_ux35;
wire		[31:0]			i_uy35;
wire		[31:0]			i_uz35;
wire		[2:0]			i_layer35;
wire		[31:0]			i_ux36;
wire		[31:0]			i_uy36;
wire		[31:0]			i_uz36;
wire		[2:0]			i_layer36;
wire					i_dead36;

//Constants
wire		[31:0]			down_niOverNt_1;
wire		[31:0]			down_niOverNt_2;
wire		[31:0]			down_niOverNt_3;
wire		[31:0]			down_niOverNt_4;
wire		[31:0]			down_niOverNt_5;
wire		[31:0]			up_niOverNt_1;
wire		[31:0]			up_niOverNt_2;
wire		[31:0]			up_niOverNt_3;
wire		[31:0]			up_niOverNt_4;
wire		[31:0]			up_niOverNt_5;
wire		[63:0]			down_niOverNt_2_1;
wire		[63:0]			down_niOverNt_2_2;
wire		[63:0]			down_niOverNt_2_3;
wire		[63:0]			down_niOverNt_2_4;
wire		[63:0]			down_niOverNt_2_5;
wire		[63:0]			up_niOverNt_2_1;
wire		[63:0]			up_niOverNt_2_2;
wire		[63:0]			up_niOverNt_2_3;
wire		[63:0]			up_niOverNt_2_4;
wire		[63:0]			up_niOverNt_2_5;
wire		[31:0]			downCritAngle_0;
wire		[31:0]			downCritAngle_1;
wire		[31:0]			downCritAngle_2;
wire		[31:0]			downCritAngle_3;
wire		[31:0]			downCritAngle_4;
wire		[31:0]			upCritAngle_0;
wire		[31:0]			upCritAngle_1;
wire		[31:0]			upCritAngle_2;
wire		[31:0]			upCritAngle_3;
wire		[31:0]			upCritAngle_4;

//Fresnels inputs
wire		[31:0]			rnd;
wire		[31:0]			up_rFresnel;
wire		[31:0]			down_rFresnel;

//Mathematics Results
wire		[63:0]			prod1_2;
wire		[63:0]			prod1_4;
wire		[31:0]			sqrtResult1_6;
wire		[63:0]			prod1_36;
wire		[63:0]			prod2_36;

//OUTPUTS


//Fresnels outputs
reg		[9:0]			fresIndex;

//Operands for shared resources
wire		[31:0]			op1_2_1;
wire		[31:0]			op1_2_2;
reg		[31:0]			op1_4_1;
wire		[31:0]			op1_4_2;
wire		[63:0]			sqrtOperand1_6;
wire		[31:0]			op1_36_1;
reg		[31:0]			op1_36_2;
wire		[31:0]			op2_36_1;
reg		[31:0]			op2_36_2;

//Final Calculated Results
reg		[31:0]			ux_reflector;
reg		[31:0]			uy_reflector;
reg		[31:0]			uz_reflector;
reg		[2:0]			layer_reflector;
reg					dead_reflector;

//-----------------------------END Pin Types-------------------------

//Overflow Wiring
wire					overflow1_4;
wire					toAnd1_36_1;
wire					toAnd1_36_2;
wire					overflow1_36;
wire					negOverflow1_36;
wire					toAnd2_36_1;
wire					toAnd2_36_2;
wire					overflow2_36;
wire					negOverflow2_36;
	
//Wiring for calculating final Results
reg		[31:0]			new_ux;
reg		[31:0]			new_uy;
reg		[31:0]			new_uz;
reg		[2:0]			new_layer;
reg					new_dead;
reg		[31:0]			downCritAngle;
reg		[31:0]			upCritAngle;
reg		[31:0]			negUz;



//Wires to Connect to Internal Registers
wire		[63:0]			uz_2[LAT:0];
wire		[31:0]			uz2[LAT:0];
wire		[63:0]			oneMinusUz_2[LAT:0];
wire		[63:0]			sa2_2[LAT:0];
wire		[63:0]			uz2_2[LAT:0];
wire		[31:0]			ux_transmitted[LAT:0];
wire		[31:0]			uy_transmitted[LAT:0];

wire		[63:0]			new_uz_2;
wire		[31:0]			new_uz2;
wire		[63:0]			new_oneMinusUz_2;
wire		[63:0]			new_sa2_2;
wire		[63:0]			new_uz2_2;
reg		[31:0]			new_ux_transmitted;
reg		[31:0]			new_uy_transmitted;


//------------------Register Pipeline-----------------
//Generation Methodology: Standard block, called InternalsBlock_Reflector,
//is repeated multiple times, based on the latency of the reflector and
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
	for(i=LAT; i>0; i=i-1) begin: internalPipe_Reflector
		case(i)
		
		2:
		InternalsBlock_Reflector pipeReg(
			//Inputs
			.clock(clock),
			.reset(reset),
			.enable(enable),
			
			//Changed Value
			.i_uz_2(new_uz_2),			//uz^2
			.i_uz2(uz2[i-1]),			//new uz, should the photon transmit to new layer
			.i_oneMinusUz_2(oneMinusUz_2[i-1]), 	//(1-uz)^2
			.i_sa2_2(sa2_2[i-1]),			//(sine of angle 2)^2 (uz2 = cosine of angle 2).
			.i_uz2_2(uz2_2[i-1]),			//(uz2)^2, new uz squared.
			.i_ux_transmitted(ux_transmitted[i-1]), //New value for ux, if photon moves to next layer
			.i_uy_transmitted(uy_transmitted[i-1]),	//New value for uy, if photon moves to next layer

			//Outputs
			.o_uz_2(uz_2[i]),
			.o_uz2(uz2[i]),
			.o_oneMinusUz_2(oneMinusUz_2[i]),
			.o_sa2_2(sa2_2[i]),
			.o_uz2_2(uz2_2[i]),
			.o_ux_transmitted(ux_transmitted[i]),
			.o_uy_transmitted(uy_transmitted[i])
		);
		
		3:
		InternalsBlock_Reflector pipeReg(
			//Inputs
			.clock(clock),
			.reset(reset),
			.enable(enable),

			.i_uz_2(uz_2[i-1]),			//uz^2
			.i_uz2(uz2[i-1]),			//new uz, should the photon transmit to new layer
			//Changed Value
			.i_oneMinusUz_2(new_oneMinusUz_2), 	//(1-uz)^2
			.i_sa2_2(sa2_2[i-1]),			//(sine of angle 2)^2 (uz2 = cosine of angle 2).
			.i_uz2_2(uz2_2[i-1]),			//(uz2)^2, new uz squared.
			.i_ux_transmitted(ux_transmitted[i-1]), //New value for ux, if photon moves to next layer
			.i_uy_transmitted(uy_transmitted[i-1]),	//New value for uy, if photon moves to next layer

			//Outputs
			.o_uz_2(uz_2[i]),
			.o_uz2(uz2[i]),
			.o_oneMinusUz_2(oneMinusUz_2[i]),
			.o_sa2_2(sa2_2[i]),
			.o_uz2_2(uz2_2[i]),
			.o_ux_transmitted(ux_transmitted[i]),
			.o_uy_transmitted(uy_transmitted[i])
		);
		4:
		InternalsBlock_Reflector pipeReg(
			//Inputs
			.clock(clock),
			.reset(reset),
			.enable(enable),

			.i_uz_2(uz_2[i-1]),			//uz^2
			.i_uz2(uz2[i-1]),			//new uz, should the photon transmit to new layer
			.i_oneMinusUz_2(oneMinusUz_2[i-1]), 	//(1-uz)^2
			//Changed Value
			.i_sa2_2(new_sa2_2),			//(sine of angle 2)^2 (uz2 = cosine of angle 2).
			.i_uz2_2(uz2_2[i-1]),			//(uz2)^2, new uz squared.
			.i_ux_transmitted(ux_transmitted[i-1]), //New value for ux, if photon moves to next layer
			.i_uy_transmitted(uy_transmitted[i-1]),	//New value for uy, if photon moves to next layer

			//Outputs
			.o_uz_2(uz_2[i]),
			.o_uz2(uz2[i]),
			.o_oneMinusUz_2(oneMinusUz_2[i]),
			.o_sa2_2(sa2_2[i]),
			.o_uz2_2(uz2_2[i]),
			.o_ux_transmitted(ux_transmitted[i]),
			.o_uy_transmitted(uy_transmitted[i])
		);
		
		5:
		InternalsBlock_Reflector pipeReg(
			//Inputs
			.clock(clock),
			.reset(reset),
			.enable(enable),

			.i_uz_2(uz_2[i-1]),			//uz^2
			.i_uz2(uz2[i-1]),			//new uz, should the photon transmit to new layer
			.i_oneMinusUz_2(oneMinusUz_2[i-1]), 	//(1-uz)^2
			.i_sa2_2(sa2_2[i-1]),			//(sine of angle 2)^2 (uz2 = cosine of angle 2).
			//Changed Value
			.i_uz2_2(new_uz2_2),			//(uz2)^2, new uz squared.
			.i_ux_transmitted(ux_transmitted[i-1]), //New value for ux, if photon moves to next layer
			.i_uy_transmitted(uy_transmitted[i-1]),	//New value for uy, if photon moves to next layer

			//Outputs
			.o_uz_2(uz_2[i]),
			.o_uz2(uz2[i]),
			.o_oneMinusUz_2(oneMinusUz_2[i]),
			.o_sa2_2(sa2_2[i]),
			.o_uz2_2(uz2_2[i]),
			.o_ux_transmitted(ux_transmitted[i]),
			.o_uy_transmitted(uy_transmitted[i])
		);
		
		(SQRT+6):
		InternalsBlock_Reflector pipeReg(
			//Inputs
			.clock(clock),
			.reset(reset),
			.enable(enable),

			.i_uz_2(uz_2[i-1]),			//uz^2
			//Changed Value
			.i_uz2(new_uz2),			//new uz, should the photon transmit to new layer
			.i_oneMinusUz_2(oneMinusUz_2[i-1]), 	//(1-uz)^2
			.i_sa2_2(sa2_2[i-1]),			//(sine of angle 2)^2 (uz2 = cosine of angle 2).
			.i_uz2_2(uz2_2[i-1]),			//(uz2)^2, new uz squared.
			.i_ux_transmitted(ux_transmitted[i-1]), //New value for ux, if photon moves to next layer
			.i_uy_transmitted(uy_transmitted[i-1]),	//New value for uy, if photon moves to next layer

			//Outputs
			.o_uz_2(uz_2[i]),
			.o_uz2(uz2[i]),
			.o_oneMinusUz_2(oneMinusUz_2[i]),
			.o_sa2_2(sa2_2[i]),
			.o_uz2_2(uz2_2[i]),
			.o_ux_transmitted(ux_transmitted[i]),
			.o_uy_transmitted(uy_transmitted[i])
		);
		
		(SQRT+DIV+6):
		InternalsBlock_Reflector pipeReg(
			//Inputs
			.clock(clock),
			.reset(reset),
			.enable(enable),

			.i_uz_2(uz_2[i-1]),			//uz^2
			.i_uz2(uz2[i-1]),			//new uz, should the photon transmit to new layer
			.i_oneMinusUz_2(oneMinusUz_2[i-1]), 	//(1-uz)^2
			.i_sa2_2(sa2_2[i-1]),			//(sine of angle 2)^2 (uz2 = cosine of angle 2).
			.i_uz2_2(uz2_2[i-1]),			//(uz2)^2, new uz squared.
			//Changed Value
			.i_ux_transmitted(new_ux_transmitted),	//New value for ux, if photon moves to next layer
			//Changed Value
			.i_uy_transmitted(new_uy_transmitted),	//New value for uy, if photon moves to next layer

			//Outputs
			.o_uz_2(uz_2[i]),
			.o_uz2(uz2[i]),
			.o_oneMinusUz_2(oneMinusUz_2[i]),
			.o_sa2_2(sa2_2[i]),
			.o_uz2_2(uz2_2[i]),
			.o_ux_transmitted(ux_transmitted[i]),
			.o_uy_transmitted(uy_transmitted[i])
		);
		default:
		InternalsBlock_Reflector pipeReg(
			//Inputs
			.clock(clock),
			.reset(reset),
			.enable(enable),
		
			.i_uz_2(uz_2[i-1]),			//uz^2
			.i_uz2(uz2[i-1]),			//new uz, should the photon transmit to new layer
			.i_oneMinusUz_2(oneMinusUz_2[i-1]), 	//(1-uz)^2
			.i_sa2_2(sa2_2[i-1]),			//(sine of angle 2)^2 (uz2 = cosine of angle 2).
			.i_uz2_2(uz2_2[i-1]),			//(uz2)^2, new uz squared.
			.i_ux_transmitted(ux_transmitted[i-1]), //New value for ux, if photon moves to next layer
			.i_uy_transmitted(uy_transmitted[i-1]),	//New value for uy, if photon moves to next layer
			
			//Outputs
			.o_uz_2(uz_2[i]),
			.o_uz2(uz2[i]),
			.o_oneMinusUz_2(oneMinusUz_2[i]),
			.o_sa2_2(sa2_2[i]),
			.o_uz2_2(uz2_2[i]),
			.o_ux_transmitted(ux_transmitted[i]),
			.o_uy_transmitted(uy_transmitted[i])
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
		ux_reflector	<= 32'h00000000;
		uy_reflector	<= 32'h00000000;
		uz_reflector	<= 32'h7FFFFFFF;
		layer_reflector	<= 3'b001;
		dead_reflector	<= 1'b1;
	end else if (enable) begin
		ux_reflector	<= new_ux;
		uy_reflector	<= new_uy;
		uz_reflector	<= new_uz;
		layer_reflector <= new_layer;
		dead_reflector	<= new_dead;
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
//and square root unit.  Also, products brought in from the wrapper 
//are placed on the appropriate wires for placement in the pipeline.

//-------------MUXES for SYNCHRONOUS LOGIC--------
always @ (*) begin
	case (i_layer36)
	1:begin
		downCritAngle		=	downCritAngle_0;
		upCritAngle		=	upCritAngle_0;
	end
	2:begin
		downCritAngle		=	downCritAngle_1;
		upCritAngle		=	upCritAngle_1;
	end
	3:begin
		downCritAngle		=	downCritAngle_2;
		upCritAngle		=	upCritAngle_2;
	end
	4:begin
		downCritAngle		=	downCritAngle_3;
		upCritAngle		=	upCritAngle_3;
	end
	5:begin
		downCritAngle		=	downCritAngle_4;
		upCritAngle		=	upCritAngle_4;
	end
	//Should never occur
	default:begin
		downCritAngle		=	downCritAngle_0;
		upCritAngle		=	upCritAngle_0;
	end
	endcase
end

always @ (*) begin
	negUz = i_uz35*-1;
	case (i_uz35[31])
	0: begin
		case (i_layer35)
			1:	fresIndex		=	{3'b000, i_uz35[30:24]};
			2:	fresIndex		=	{3'b001, i_uz35[30:24]};
			3:	fresIndex		=	{3'b010, i_uz35[30:24]};
			4:	fresIndex		=	{3'b011, i_uz35[30:24]};
			5:	fresIndex		=	{3'b100, i_uz35[30:24]};
			//Should never occur
			default: fresIndex		=	{3'b000, i_uz35[30:24]};
		endcase
	end
	1: begin
		case (i_layer35)
			1:	fresIndex		=	{3'b000, negUz[30:24]};
			2:	fresIndex		=	{3'b001, negUz[30:24]};
			3:	fresIndex		=	{3'b010, negUz[30:24]};
			4:	fresIndex		=	{3'b011, negUz[30:24]};
			5:	fresIndex		=	{3'b100, negUz[30:24]};
			//Should never occur
			default: fresIndex		=	{3'b000, negUz[30:24]};
		endcase
	end
	endcase
		
end


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
always @ (*) begin
	case (i_uz3[31])
	//uz >= 0
	0:begin
		case (i_layer3)
			1: op1_4_1			=	{down_niOverNt_2_1[63], down_niOverNt_2_1[61:31]};
			2: op1_4_1			=	{down_niOverNt_2_2[63], down_niOverNt_2_2[61:31]};
			3: op1_4_1			=	{down_niOverNt_2_3[63], down_niOverNt_2_3[61:31]};
			4: op1_4_1			=	{down_niOverNt_2_4[63], down_niOverNt_2_4[61:31]};
			5: op1_4_1			=	{down_niOverNt_2_5[63], down_niOverNt_2_5[61:31]};
			default: op1_4_1		=	{down_niOverNt_2_1[63], down_niOverNt_2_1[61:31]};
		endcase
	end
	//uz < 0
	1:begin
		case (i_layer3)
			1: op1_4_1			=	{up_niOverNt_2_1[63], up_niOverNt_2_1[61:31]};
			2: op1_4_1			=	{up_niOverNt_2_2[63], up_niOverNt_2_2[61:31]};
			3: op1_4_1			=	{up_niOverNt_2_3[63], up_niOverNt_2_3[61:31]};
			4: op1_4_1			=	{up_niOverNt_2_4[63], up_niOverNt_2_4[61:31]};
			5: op1_4_1			=	{up_niOverNt_2_5[63], up_niOverNt_2_5[61:31]};
			default: op1_4_1		=	{up_niOverNt_2_1[63], up_niOverNt_2_1[61:31]};
		endcase
	end
	endcase
end

assign	op1_4_2						=	{oneMinusUz_2[3][63], oneMinusUz_2[3][61:31]};

//CC 5
//SUBTRACTION, see math results

//CC SQRT+5 -- Started in CC 6
assign	sqrtOperand1_6					=	uz2_2[5];

//CC SQRT+DIV+6 -- Line up with Scatterer.
assign	op1_36_1					=	i_ux35;

always @ (*) begin
	case (i_uz35[31])
	0: begin//uz >= 0
		case (i_layer35)
			1:begin	
				op1_36_2		=	down_niOverNt_1;
				op2_36_2		=	down_niOverNt_1;
			end
			2:begin	
				op1_36_2		=	down_niOverNt_2;
				op2_36_2		=	down_niOverNt_2;
			end
			3:begin	
				op1_36_2		=	down_niOverNt_3;
				op2_36_2		=	down_niOverNt_3;
			end
			4:begin	
				op1_36_2		=	down_niOverNt_4;
				op2_36_2		=	down_niOverNt_4;
			end
			5:begin	
				op1_36_2		=	down_niOverNt_5;
				op2_36_2		=	down_niOverNt_5;
			end
			default:begin
				op1_36_2		=	down_niOverNt_1;
				op2_36_2		=	down_niOverNt_1;
			end
		endcase
	end
	1: begin//uz < 0
		case (i_layer35)
			1:begin
				op1_36_2		=	up_niOverNt_1;
				op2_36_2		=	up_niOverNt_1;
			end
			2:begin
				op1_36_2		=	up_niOverNt_2;
				op2_36_2		=	up_niOverNt_2;
			end
			3:begin
				op1_36_2		=	up_niOverNt_3;
				op2_36_2		=	up_niOverNt_3;
			end
			4:begin
				op1_36_2		=	up_niOverNt_4;
				op2_36_2		=	up_niOverNt_4;
			end
			5:begin
				op1_36_2		=	up_niOverNt_5;
				op2_36_2		=	up_niOverNt_5;
			end
			default:begin
				op1_36_2		=	up_niOverNt_1;
				op2_36_2		=	up_niOverNt_1;
			end
		endcase
	end
	endcase
end

assign	op2_36_1					=	i_uy35;





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


//CC 2
assign new_uz_2						=	prod1_2;

//CC 3
sub_64b		oneMinusUz2_sub(
			.dataa(INTMAX_2),
			.datab(uz_2[2]),
			.result(new_oneMinusUz_2)
		);

//CC 4
//Used to determine whether or not the multiply operation overflowed.
or U1(overflow1_4, prod1_4[62], prod1_4[61], prod1_4[60], prod1_4[59], prod1_4[58]);

//Cannot take sqrt of negative number, that is why prod1_4[58] must be 0.

													//sign		//data		//padding
assign	new_sa2_2					=	(overflow1_4 == 1)? INTMAX_2	:	{prod1_4[63], prod1_4[58:0], 4'h0};

//5th CC
sub_64b		uz2_2_sub(
			.dataa(INTMAX_2),
			.datab(sa2_2[4]),
			.result(new_uz2_2)
		);

//CC SQRT+5
assign new_uz2						= sqrtResult1_6;

//CC SQRT+DIV+6 -- Line up with Scatterer.


//Used to determine whether or not the multiply operation overflowed.
or U2(toAnd1_36_1, prod1_36[62], prod1_36[61], prod1_36[60]);
//Used to determine whether or not the multiply operation overflowed in the negative direction.
or U3(toAnd1_36_2, ~prod1_36[62], ~prod1_36[61], ~prod1_36[60]);

and U4(overflow1_36, ~prod1_36[63], toAnd1_36_1);
and U5(negOverflow1_36, prod1_36[63], toAnd1_36_2);


//Used to determine whether or not the multiply operation overflowed.
or U6(toAnd2_36_1, prod2_36[62], prod2_36[61], prod2_36[60]);
//Used to determine whether or not the multiply operation overflowed in the negative direction.
or U7(toAnd2_36_2, ~prod2_36[62], ~prod2_36[61], ~prod2_36[60]);

and U8(overflow2_36, ~prod2_36[63], toAnd2_36_1);
and U9(negOverflow2_36, prod2_36[63], toAnd2_36_2);

always @ (*) begin
	case ({overflow1_36, negOverflow1_36})
	0:	new_ux_transmitted = {prod1_36[63:63], prod1_36[59:29]};
	1:	new_ux_transmitted = INTMIN;
	2:	new_ux_transmitted = INTMAX;
	//Should never occur
	3:	new_ux_transmitted = {prod1_36[63:63], prod1_36[59:29]};
	endcase
	
	case ({overflow2_36, negOverflow2_36})
	
	0:	new_uy_transmitted = {prod2_36[63:63], prod2_36[59:29]};
	1:	new_uy_transmitted = INTMIN;
	2:	new_uy_transmitted = INTMAX;
	//Should never occur
	3:	new_uy_transmitted = {prod2_36[63:63], prod2_36[59:29]};
	endcase
end


//-------------FINAL CALCULATED VALUES----------------------
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
//
//
always @ (*) begin
	//REFLECTED -- Due to total internal reflection while moving down
	if (~i_uz36[31] && i_uz36 <= downCritAngle) begin
		new_ux		= i_ux36;
		new_uy		= i_uy36;
		new_uz		= -i_uz36;
		new_layer	= i_layer36;
		new_dead	= i_dead36;
	//REFLECTED -- Due to total internal reflection while moving up
	end else if (i_uz36[31] && -i_uz36 <= upCritAngle) begin
		new_ux		= i_ux36;
		new_uy		= i_uy36;
		new_uz		= -i_uz36;
		new_layer	= i_layer36;
		new_dead	= i_dead36;
	//REFLECTED -- Due to random number being too small while moving down
	end else if (~i_uz36[31] && rnd <= down_rFresnel) begin
		new_ux		= i_ux36;
		new_uy		= i_uy36;
		new_uz		= -i_uz36;
		new_layer	= i_layer36;
		new_dead	= i_dead36;
	//REFLECTED -- Due to random number being too small while moving up
	end else if (i_uz36[31] && rnd <= up_rFresnel) begin
		new_ux		= i_ux36;
		new_uy		= i_uy36;
		new_uz		= -i_uz36;
		new_layer	= i_layer36;
		new_dead	= i_dead36;
	//TRANSMITTED
	end else begin
		new_ux		= ux_transmitted[LAT-1];
		new_uy		= uy_transmitted[LAT-1];
		case (i_uz36[31])
		0:begin//uz >= 0
			if (i_layer36 == 5) begin
				new_layer	= 3'h5;
				new_dead	= 1'b1;
			end else begin
				new_layer	= i_layer36+3'h1;
				new_dead	= i_dead36;
			end
			new_uz			= uz2[LAT-1];
		end
		1:begin//uz < 0
			if (i_layer36 == 1) begin
				new_layer	= 3'h1;
				new_dead	= 1'b1;
			end else begin
				new_layer	= i_layer36-3'h1;
				new_dead	= i_dead36;
			end
			new_uz			= -uz2[LAT-1];
		end
		endcase
	
	end
end

endmodule

