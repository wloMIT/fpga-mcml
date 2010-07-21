//////////////////////////////////////////////////////////////////////////////////
//  #     #   #####      ##     #####    #####    ######   #####
//  #     #   #    #    #  #    #    #   #    #   #        #    #
//  #     #   #    #   #    #   #    #   #    #   #####    #    #
//  #  #  #   #####    ######   #####    #####    #        #####
//  # # # #   #   #    #    #   #        #        #        #   #
//  ##   ##   #    #   #    #   #        #        ######   #    #
//
//
//
//NAMING CONVENTION:
//prodX_Y means the Xth product which started calculation at the Yth clock cycle
//opX_Y_Z means the Zth operand for the Xth product of the Yth cycle
//i_uxN means input from the Nth register in the pipeline, the value of ux.
//////////////////////////////////////////////////////////////////////////////////


module ScattererReflectorWrapper (
	//Inputs
	clock,
	reset,
	enable,
	//MEMORY WRAPPER

		//Inputs
		
		//Photon values
		i_uz1_pipeWrapper,
		i_hit2_pipeWrapper,
		i_ux3_pipeWrapper,
		i_uz3_pipeWrapper,
		i_layer3_pipeWrapper,
		i_hit4_pipeWrapper,
		i_hit6_pipeWrapper,
		i_hit16_pipeWrapper,
		i_layer31_pipeWrapper,
		i_uy32_pipeWrapper,
		i_uz32_pipeWrapper,
		i_hit33_pipeWrapper,
		i_ux33_pipeWrapper,
		i_uy33_pipeWrapper,
		i_hit34_pipeWrapper,
		i_ux35_pipeWrapper,
		i_uy35_pipeWrapper,
		i_uz35_pipeWrapper,
		i_layer35_pipeWrapper,
		i_hit36_pipeWrapper,
		i_ux36_pipeWrapper,
		i_uy36_pipeWrapper,
		i_uz36_pipeWrapper,
		i_layer36_pipeWrapper,
		i_dead36_pipeWrapper,


		//Memory Interface
			//Inputs
		rand2,
		rand3,
		rand5,
		sint,
		cost,
		up_rFresnel,
		down_rFresnel,
			//Outputs
		tindex,
		fresIndex,
		
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
		
		//Outputs
		ux_scatterer,
		uy_scatterer,
		uz_scatterer,
		
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
	
parameter INTMAX_2 = 64'h3FFFFFFF00000001;
	
	
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
input	[2:0]			i_layer31_pipeWrapper;



input	[31:0]			i_uz1_pipeWrapper;
input				i_hit2_pipeWrapper;
input	[31:0]			i_ux3_pipeWrapper;
input	[31:0]			i_uz3_pipeWrapper;
input	[2:0]			i_layer3_pipeWrapper;
input				i_hit4_pipeWrapper;
input				i_hit6_pipeWrapper;
input				i_hit16_pipeWrapper;
input	[31:0]			i_uy32_pipeWrapper;
input	[31:0]			i_uz32_pipeWrapper;
input				i_hit33_pipeWrapper;
input	[31:0]			i_ux33_pipeWrapper;
input	[31:0]			i_uy33_pipeWrapper;
input				i_hit34_pipeWrapper;
input	[31:0]			i_ux35_pipeWrapper;
input	[31:0]			i_uy35_pipeWrapper;
input	[31:0]			i_uz35_pipeWrapper;
input	[2:0]			i_layer35_pipeWrapper;
input				i_hit36_pipeWrapper;
input	[31:0]			i_ux36_pipeWrapper;
input	[31:0]			i_uy36_pipeWrapper;
input	[31:0]			i_uz36_pipeWrapper;
input	[2:0]			i_layer36_pipeWrapper;
input				i_dead36_pipeWrapper;


//Memory Interface
input	[31:0]			rand2;
input	[31:0]			rand3;
input	[31:0]			rand5;
input	[31:0]			sint;
input	[31:0]			cost;
input	[31:0]			up_rFresnel;
input	[31:0]			down_rFresnel;

output	[12:0]			tindex;
output	[9:0]			fresIndex;


//Constants
input	[31:0]			down_niOverNt_1;
input	[31:0]			down_niOverNt_2;
input	[31:0]			down_niOverNt_3;
input	[31:0]			down_niOverNt_4;
input	[31:0]			down_niOverNt_5;
input	[31:0]			up_niOverNt_1;
input	[31:0]			up_niOverNt_2;
input	[31:0]			up_niOverNt_3;
input	[31:0]			up_niOverNt_4;
input	[31:0]			up_niOverNt_5;
input	[63:0]			down_niOverNt_2_1;
input	[63:0]			down_niOverNt_2_2;
input	[63:0]			down_niOverNt_2_3;
input	[63:0]			down_niOverNt_2_4;
input	[63:0]			down_niOverNt_2_5;
input	[63:0]			up_niOverNt_2_1;
input	[63:0]			up_niOverNt_2_2;
input	[63:0]			up_niOverNt_2_3;
input	[63:0]			up_niOverNt_2_4;
input	[63:0]			up_niOverNt_2_5;
input	[31:0]			downCritAngle_0;
input	[31:0]			downCritAngle_1;
input	[31:0]			downCritAngle_2;
input	[31:0]			downCritAngle_3;
input	[31:0]			downCritAngle_4;
input	[31:0]			upCritAngle_0;
input	[31:0]			upCritAngle_1;
input	[31:0]			upCritAngle_2;
input	[31:0]			upCritAngle_3;
input	[31:0]			upCritAngle_4;


output	[31:0]			ux_scatterer;
output	[31:0]			uy_scatterer;
output	[31:0]			uz_scatterer;
output	[31:0]			ux_reflector;
output	[31:0]			uy_reflector;
output	[31:0]			uz_reflector;
output	[2:0]			layer_reflector;
output				dead_reflector;




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

wire	[2:0]			i_layer31_pipeWrapper;

wire	[31:0]			i_uz1_pipeWrapper;
wire				i_hit2_pipeWrapper;
wire	[31:0]			i_ux3_pipeWrapper;
wire	[31:0]			i_uz3_pipeWrapper;
wire	[2:0]			i_layer3_pipeWrapper;
wire				i_hit4_pipeWrapper;
wire				i_hit6_pipeWrapper;
wire				i_hit16_pipeWrapper;
wire	[31:0]			i_uy32_pipeWrapper;
wire	[31:0]			i_uz32_pipeWrapper;
wire				i_hit33_pipeWrapper;
wire	[31:0]			i_ux33_pipeWrapper;
wire	[31:0]			i_uy33_pipeWrapper;
wire				i_hit34_pipeWrapper;
wire	[31:0]			i_ux35_pipeWrapper;
wire	[31:0]			i_uy35_pipeWrapper;
wire	[31:0]			i_uz35_pipeWrapper;
wire	[2:0]			i_layer35_pipeWrapper;
wire				i_hit36_pipeWrapper;
wire	[31:0]			i_ux36_pipeWrapper;
wire	[31:0]			i_uy36_pipeWrapper;
wire	[31:0]			i_uz36_pipeWrapper;
wire	[2:0]			i_layer36_pipeWrapper;
wire				i_dead36_pipeWrapper;

wire	[9:0]			pindex;
wire	[12:0]			tindex;
wire	[31:0]			rand2;
wire	[31:0]			rand3;
wire	[31:0]			rand5;


//Constants
wire	[31:0]			down_niOverNt_1;
wire	[31:0]			down_niOverNt_2;
wire	[31:0]			down_niOverNt_3;
wire	[31:0]			down_niOverNt_4;
wire	[31:0]			down_niOverNt_5;
wire	[31:0]			up_niOverNt_1;
wire	[31:0]			up_niOverNt_2;
wire	[31:0]			up_niOverNt_3;
wire	[31:0]			up_niOverNt_4;
wire	[31:0]			up_niOverNt_5;
wire	[63:0]			down_niOverNt_2_1;
wire	[63:0]			down_niOverNt_2_2;
wire	[63:0]			down_niOverNt_2_3;
wire	[63:0]			down_niOverNt_2_4;
wire	[63:0]			down_niOverNt_2_5;
wire	[63:0]			up_niOverNt_2_1;
wire	[63:0]			up_niOverNt_2_2;
wire	[63:0]			up_niOverNt_2_3;
wire	[63:0]			up_niOverNt_2_4;
wire	[63:0]			up_niOverNt_2_5;
wire	[31:0]			downCritAngle_0;
wire	[31:0]			downCritAngle_1;
wire	[31:0]			downCritAngle_2;
wire	[31:0]			downCritAngle_3;
wire	[31:0]			downCritAngle_4;
wire	[31:0]			upCritAngle_0;
wire	[31:0]			upCritAngle_1;
wire	[31:0]			upCritAngle_2;
wire	[31:0]			upCritAngle_3;
wire	[31:0]			upCritAngle_4;

//Scatterer, final calculated values
wire	[31:0]			ux_scatterer;
wire	[31:0]			uy_scatterer;
wire	[31:0]			uz_scatterer;
wire	[31:0]			ux_reflector;
wire	[31:0]			uy_reflector;
wire	[31:0]			uz_reflector;
wire	[2:0]			layer_reflector;
wire				dead_reflector;


//Mathematics results signals
wire	[63:0]			prod1_2;
wire	[63:0]			prod1_4;
wire	[31:0]			sqrtResult1_6;
wire	[32:0]			sqrtRemainder;
wire	[63:0]			prod1_33;
wire	[63:0]			prod2_33;
wire	[63:0]			prod3_33;
wire	[63:0]			prod1_34;
wire	[63:0]			prod2_34;
wire	[63:0]			prod3_34;
wire	[63:0]			prod4_34;
wire	[63:0]			quot1_16;
wire	[31:0]			divRemainder;
wire	[63:0]			prod1_36;
wire	[63:0]			prod2_36;
wire	[63:0]			prod3_36;
wire	[63:0]			prod4_36;
wire	[63:0]			prod5_36;
wire	[63:0]			prod6_36;

//Scatterer Operands
wire	[31:0]			op1_2_1_scatterer;
wire	[31:0]			op1_2_2_scatterer;
wire	[31:0]			op1_4_1_scatterer;
wire	[31:0]			op1_4_2_scatterer;
wire	[63:0]			sqrtOperand1_6_scatterer;
wire	[63:0]			divNumerator1_16_scatterer;
wire	[31:0]			divDenominator1_16_scatterer;
wire	[31:0]			op1_33_1_scatterer;
wire	[31:0]			op1_33_2_scatterer;
wire	[31:0]			op2_33_1_scatterer;
wire	[31:0]			op2_33_2_scatterer;
wire	[31:0]			op3_33_1_scatterer;
wire	[31:0]			op3_33_2_scatterer;
wire	[31:0]			op1_34_1_scatterer;
wire	[31:0]			op1_34_2_scatterer;
wire	[31:0]			op2_34_1_scatterer;
wire	[31:0]			op2_34_2_scatterer;
wire	[31:0]			op3_34_1_scatterer;
wire	[31:0]			op3_34_2_scatterer;
wire	[31:0]			op4_34_1_scatterer;
wire	[31:0]			op4_34_2_scatterer;
wire	[31:0]			op1_36_1_scatterer;
wire	[31:0]			op1_36_2_scatterer;
wire	[31:0]			op2_36_1_scatterer;
wire	[31:0]			op2_36_2_scatterer;
wire	[31:0]			op3_36_1_scatterer;
wire	[31:0]			op3_36_2_scatterer;
wire	[31:0]			op4_36_1_scatterer;
wire	[31:0]			op4_36_2_scatterer;
wire	[31:0]			op5_36_1_scatterer;
wire	[31:0]			op5_36_2_scatterer;
wire	[31:0]			op6_36_1_scatterer;
wire	[31:0]			op6_36_2_scatterer;


//Reflector Operands
wire	[31:0]			op1_2_1_reflector;
wire	[31:0]			op1_2_2_reflector;
wire	[31:0]			op1_4_1_reflector;
wire	[31:0]			op1_4_2_reflector;
wire	[63:0]			sqrtOperand1_6_reflector;
wire	[31:0]			op1_36_1_reflector;
wire	[31:0]			op1_36_2_reflector;
wire	[31:0]			op2_36_1_reflector;
wire	[31:0]			op2_36_2_reflector;




//Operands entering the multipliers, divider, and sqrt
wire	[31:0]			op1_2_1;
wire	[31:0]			op1_2_2;
wire	[31:0]			op1_4_1;
wire	[31:0]			op1_4_2;
wire	[63:0]			sqrtOperand1_6;
wire	[63:0]			divNumerator1_16;
wire	[31:0]			divDenominator1_16;
wire	[31:0]			op1_33_1;
wire	[31:0]			op1_33_2;
wire	[31:0]			op2_33_1;
wire	[31:0]			op2_33_2;
wire	[31:0]			op3_33_1;
wire	[31:0]			op3_33_2;
wire	[31:0]			op1_34_1;
wire	[31:0]			op1_34_2;
wire	[31:0]			op2_34_1;
wire	[31:0]			op2_34_2;
wire	[31:0]			op3_34_1;
wire	[31:0]			op3_34_2;
wire	[31:0]			op4_34_1;
wire	[31:0]			op4_34_2;
wire	[31:0]			op1_36_1;
wire	[31:0]			op1_36_2;
wire	[31:0]			op2_36_1;
wire	[31:0]			op2_36_2;
wire	[31:0]			op3_36_1;
wire	[31:0]			op3_36_2;
wire	[31:0]			op4_36_1;
wire	[31:0]			op4_36_2;
wire	[31:0]			op5_36_1;
wire	[31:0]			op5_36_2;
wire	[31:0]			op6_36_1;
wire	[31:0]			op6_36_2;


reg	[2:0]			layerMinusOne;

wire	[31:0]			sint;
wire	[31:0]			cost;
wire	[31:0]			sinp;
wire	[31:0]			cosp;

wire	[31:0]			up_rFresnel;
wire	[31:0]			down_rFresnel;
wire	[9:0]			fresIndex;



//MUX for sending in indices for memory.
always @ (*) begin
	case (i_layer31_pipeWrapper)
		3'b001: layerMinusOne = 0;
		3'b010: layerMinusOne = 1;
		3'b011: layerMinusOne = 2;
		3'b100: layerMinusOne = 3;
		3'b101: layerMinusOne = 4;
		default: layerMinusOne = 0;
	endcase
end

assign tindex = {layerMinusOne, rand2[9:0]};
assign pindex = rand3[9:0];


//Arbitrarily decide on values of sine and cosine for now, should be memory lookups
Memory_Wrapper	memories(
					//INPUTS
					.clock(clock),
					.reset(reset),
					.pindex(pindex),
					//OUTPUTS
					.sinp(sinp),
					.cosp(cosp)
				);


Scatterer scatterer_0 (
			.clock(clock),
			.reset(reset),
			.enable(enable),
			//Photon values
			.i_uz1(i_uz1_pipeWrapper),
			.i_ux3(i_ux3_pipeWrapper),
			.i_uz3(i_uz3_pipeWrapper),
			.i_uy32(i_uy32_pipeWrapper),
			.i_uz32(i_uz32_pipeWrapper),
			.i_ux33(i_ux33_pipeWrapper),
			.i_uy33(i_uy33_pipeWrapper),
			.i_ux35(i_ux35_pipeWrapper),
			.i_uy35(i_uy35_pipeWrapper),
			.i_uz35(i_uz35_pipeWrapper),
			.i_uz36(i_uz36_pipeWrapper),
			//Mathematics Results
			.prod1_2(prod1_2),
			.prod1_4({prod1_4[63:63], prod1_4[61:31]}),
			.sqrtResult1_6(sqrtResult1_6),
			.prod1_33({prod1_33[63:63], prod1_33[61:31]}),
			.prod2_33({prod2_33[63:63], prod2_33[61:31]}),
			.prod3_33({prod3_33[63:63], prod3_33[61:31]}),
			.prod1_34({prod1_34[63:63], prod1_34[61:31]}),
			.prod2_34({prod2_34[63:63], prod2_34[61:31]}),
			.prod3_34({prod3_34[63:63], prod3_34[61:31]}),
			.prod4_34({prod4_34[63:63], prod4_34[61:31]}),
			.quot1_16(quot1_16),
			.prod1_36(prod1_36),
			.prod2_36(prod2_36),
			.prod3_36({prod3_36[63:63], prod3_36[61:31]}),
			.prod4_36({prod4_36[63:63], prod4_36[61:31]}),
			.prod5_36({prod5_36[63:63], prod5_36[61:31]}),
			.prod6_36({prod6_36[63:63], prod6_36[61:31]}),
			//Trig from Memory
			.sint_Mem(sint),
			.cost_Mem(cost),
			.sinp_Mem(sinp),
			.cosp_Mem(cosp),
			//Operands for mathematics
			.op1_2_1(op1_2_1_scatterer),
			.op1_2_2(op1_2_2_scatterer),
			.op1_4_1(op1_4_1_scatterer),
			.op1_4_2(op1_4_2_scatterer),
			.sqrtOperand1_6(sqrtOperand1_6_scatterer),
			.divNumerator1_16(divNumerator1_16_scatterer),
			.divDenominator1_16(divDenominator1_16_scatterer),
			.op1_33_1(op1_33_1_scatterer),
			.op1_33_2(op1_33_2_scatterer),
			.op2_33_1(op2_33_1_scatterer),
			.op2_33_2(op2_33_2_scatterer),
			.op3_33_1(op3_33_1_scatterer),
			.op3_33_2(op3_33_2_scatterer),
			.op1_34_1(op1_34_1_scatterer),
			.op1_34_2(op1_34_2_scatterer),
			.op2_34_1(op2_34_1_scatterer),
			.op2_34_2(op2_34_2_scatterer),
			.op3_34_1(op3_34_1_scatterer),
			.op3_34_2(op3_34_2_scatterer),
			.op4_34_1(op4_34_1_scatterer),
			.op4_34_2(op4_34_2_scatterer),
			.op1_36_1(op1_36_1_scatterer),
			.op1_36_2(op1_36_2_scatterer),
			.op2_36_1(op2_36_1_scatterer),
			.op2_36_2(op2_36_2_scatterer),
			.op3_36_1(op3_36_1_scatterer),
			.op3_36_2(op3_36_2_scatterer),
			.op4_36_1(op4_36_1_scatterer),
			.op4_36_2(op4_36_2_scatterer),
			.op5_36_1(op5_36_1_scatterer),
			.op5_36_2(op5_36_2_scatterer),
			.op6_36_1(op6_36_1_scatterer),
			.op6_36_2(op6_36_2_scatterer),
			
			//Final calculated values
			.ux_scatterer(ux_scatterer),
			.uy_scatterer(uy_scatterer),
			.uz_scatterer(uz_scatterer)

		);
		
Reflector reflector_0 (

			//INPUTS
			.clock(clock),
			.reset(reset),
			.enable(enable),
			//Photon values
			.i_uz1(i_uz1_pipeWrapper),
			.i_uz3(i_uz3_pipeWrapper),
			.i_layer3(i_layer3_pipeWrapper),
			.i_ux35(i_ux35_pipeWrapper),
			.i_uy35(i_uy35_pipeWrapper),
			.i_uz35(i_uz35_pipeWrapper),
			.i_layer35(i_layer35_pipeWrapper),
			.i_ux36(i_ux36_pipeWrapper),
			.i_uy36(i_uy36_pipeWrapper),
			.i_uz36(i_uz36_pipeWrapper),
			.i_layer36(i_layer36_pipeWrapper),
			.i_dead36(i_dead36_pipeWrapper),

			//Constants
			.down_niOverNt_1(down_niOverNt_1),
			.down_niOverNt_2(down_niOverNt_2),
			.down_niOverNt_3(down_niOverNt_3),
			.down_niOverNt_4(down_niOverNt_4),
			.down_niOverNt_5(down_niOverNt_5),
			.up_niOverNt_1(up_niOverNt_1),
			.up_niOverNt_2(up_niOverNt_2),
			.up_niOverNt_3(up_niOverNt_3),
			.up_niOverNt_4(up_niOverNt_4),
			.up_niOverNt_5(up_niOverNt_5),
			.down_niOverNt_2_1(down_niOverNt_2_1),
			.down_niOverNt_2_2(down_niOverNt_2_2),
			.down_niOverNt_2_3(down_niOverNt_2_3),
			.down_niOverNt_2_4(down_niOverNt_2_4),
			.down_niOverNt_2_5(down_niOverNt_2_5),
			.up_niOverNt_2_1(up_niOverNt_2_1),
			.up_niOverNt_2_2(up_niOverNt_2_2),
			.up_niOverNt_2_3(up_niOverNt_2_3),
			.up_niOverNt_2_4(up_niOverNt_2_4),
			.up_niOverNt_2_5(up_niOverNt_2_5),
			.downCritAngle_0(downCritAngle_0),
			.downCritAngle_1(downCritAngle_1),
			.downCritAngle_2(downCritAngle_2),
			.downCritAngle_3(downCritAngle_3),
			.downCritAngle_4(downCritAngle_4),
			.upCritAngle_0(upCritAngle_0),
			.upCritAngle_1(upCritAngle_1),
			.upCritAngle_2(upCritAngle_2),
			.upCritAngle_3(upCritAngle_3),
			.upCritAngle_4(upCritAngle_4),

			//Fresnels inputs
			.rnd({1'b0, rand5[30:0]}),
			.up_rFresnel(up_rFresnel),
			.down_rFresnel(down_rFresnel),

			//Mathematics Results
			.prod1_2(prod1_2),
			.prod1_4(prod1_4),
			.sqrtResult1_6(sqrtResult1_6),
			.prod1_36(prod1_36),
			.prod2_36(prod2_36),

			//OUTPUTS

			//Fresnels outputs
			.fresIndex(fresIndex),

			//Mathematics Operands
			.op1_2_1(op1_2_1_reflector),
			.op1_2_2(op1_2_2_reflector),
			.op1_4_1(op1_4_1_reflector),
			.op1_4_2(op1_4_2_reflector),
			.sqrtOperand1_6(sqrtOperand1_6_reflector),
			.op1_36_1(op1_36_1_reflector),
			.op1_36_2(op1_36_2_reflector),
			.op2_36_1(op2_36_1_reflector),
			.op2_36_2(op2_36_2_reflector),


			//Final Calculated Results
			.ux_reflector(ux_reflector),
			.uy_reflector(uy_reflector),
			.uz_reflector(uz_reflector),
			.layer_reflector(layer_reflector),
			.dead_reflector(dead_reflector)

);
		



	
//Multipliers, Dividers, and Sqrts for Scatterer & Reflector

assign op1_2_1 = (i_hit2_pipeWrapper == 1'b1) ? op1_2_1_reflector		:		op1_2_1_scatterer;
assign op1_2_2 = (i_hit2_pipeWrapper == 1'b1) ? op1_2_2_reflector		:		op1_2_2_scatterer;

Mult_32b	multiplier1_2 (
				.dataa(op1_2_1),
				.datab(op1_2_2),
				.result(prod1_2)
			);
			
assign op1_4_1 = (i_hit4_pipeWrapper == 1'b1) ? op1_4_1_reflector		:		op1_4_1_scatterer;
assign op1_4_2 = (i_hit4_pipeWrapper == 1'b1) ? op1_4_2_reflector		:		op1_4_2_scatterer;

Mult_32b	multiplier1_4 (
				.dataa(op1_4_1),
				.datab(op1_4_2),
				.result(prod1_4)
			);
			


Mult_32b	multiplier1_33 (
				.dataa(op1_33_1_scatterer),
				.datab(op1_33_2_scatterer),
				.result(prod1_33)
			);

Mult_32b	multiplier2_33 (
				.dataa(op2_33_1_scatterer),
				.datab(op2_33_2_scatterer),
				.result(prod2_33)
			);

Mult_32b	multiplier3_33 (
				.dataa(op3_33_1_scatterer),
				.datab(op3_33_2_scatterer),
				.result(prod3_33)
			);


Mult_32b	multiplier1_34 (
				.dataa(op1_34_1_scatterer),
				.datab(op1_34_2_scatterer),
				.result(prod1_34)
			);


Mult_32b	multiplier2_34 (
				.dataa(op2_34_1_scatterer),
				.datab(op2_34_2_scatterer),
				.result(prod2_34)
			);


Mult_32b	multiplier3_34 (
				.dataa(op3_34_1_scatterer),
				.datab(op3_34_2_scatterer),
				.result(prod3_34)
			);

Mult_32b	multiplier4_34 (
				.dataa(op4_34_1_scatterer),
				.datab(op4_34_2_scatterer),
				.result(prod4_34)
			);

assign op1_36_1 = (i_hit36_pipeWrapper == 1'b1) ? op1_36_1_reflector	:		op1_36_1_scatterer;
assign op1_36_2 = (i_hit36_pipeWrapper == 1'b1) ? op1_36_2_reflector	:		op1_36_2_scatterer;

Mult_32b	multiplier1_36 (
				.dataa(op1_36_1),
				.datab(op1_36_2),
				.result(prod1_36)
			);

assign op2_36_1 = (i_hit36_pipeWrapper == 1'b1) ? op2_36_1_reflector	:		op2_36_1_scatterer;
assign op2_36_2 = (i_hit36_pipeWrapper == 1'b1) ? op2_36_2_reflector	:		op2_36_2_scatterer;

Mult_32b	multiplier2_36 (
				.dataa(op2_36_1),
				.datab(op2_36_2),
				.result(prod2_36)
			);
			
Mult_32b	multiplier3_36 (
				.dataa(op3_36_1_scatterer),
				.datab(op3_36_2_scatterer),
				.result(prod3_36)
			);


Mult_32b	multiplier4_36 (
				.dataa(op4_36_1_scatterer),
				.datab(op4_36_2_scatterer),
				.result(prod4_36)
			);
			

Mult_32b	multiplier5_36 (
				.dataa(op5_36_1_scatterer),
				.datab(op5_36_2_scatterer),
				.result(prod5_36)
			);


Mult_32b	multiplier6_36 (
				.dataa(op6_36_1_scatterer),
				.datab(op6_36_2_scatterer),
				.result(prod6_36)
			);
			
assign sqrtOperand1_6 = (i_hit6_pipeWrapper == 1'b1) ? sqrtOperand1_6_reflector	:		sqrtOperand1_6_scatterer;

Sqrt_64b	squareRoot1_6 (
				.clk(clock),
				.radical(sqrtOperand1_6),
				.q(sqrtResult1_6),
				.remainder(sqrtRemainder)
			);



Div_64b		divide1_16 (
				.clock(clock),
				.numer(divNumerator1_16_scatterer),
				.denom(divDenominator1_16_scatterer),
				.quotient(quot1_16),
				.remain(divRemainder)
			);
				

endmodule
			
