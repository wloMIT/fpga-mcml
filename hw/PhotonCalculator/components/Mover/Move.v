// Move
// Author Jason Luu
// Description:
// Calculate the desired move steps for the photon, latency of one, registered outputs


module Move(     //INPUTS
				 clock, reset, enable,
				 x_moverMux, y_moverMux, z_moverMux,
				 ux_moverMux, uy_moverMux, uz_moverMux,
				 sz_moverMux, sr_moverMux,
				 sleftz_moverMux, sleftr_moverMux,
				 layer_moverMux, weight_moverMux, dead_moverMux,

				 log_rand_num,

				 //OUTPUTS
				 x_mover, y_mover, z_mover,
				 ux_mover, uy_mover, uz_mover,
				 sz_mover, sr_mover,
				 sleftz_mover, sleftr_mover,
				 layer_mover, weight_mover, dead_mover,

				 // CONSTANTS
				 OneOver_MutMaxrad_0, OneOver_MutMaxrad_1, OneOver_MutMaxrad_2, OneOver_MutMaxrad_3, OneOver_MutMaxrad_4, OneOver_MutMaxrad_5,
				 OneOver_MutMaxdep_0, OneOver_MutMaxdep_1, OneOver_MutMaxdep_2, OneOver_MutMaxdep_3, OneOver_MutMaxdep_4, OneOver_MutMaxdep_5,
				 OneOver_Mut_0, OneOver_Mut_1, OneOver_Mut_2, OneOver_Mut_3, OneOver_Mut_4, OneOver_Mut_5
				 );

parameter BIT_WIDTH=32;
parameter LAYER_WIDTH=3;
parameter LOGSCALEFACTOR=5;
parameter MAXLOG=2977044471;		//Based on 32 bit unsigned rand num generator
parameter CONST_MOVE_AMOUNT=25000;  //Used for testing purposes only
parameter MUTMAX_BITS = 15;

input clock;
input reset;
input enable;

input [BIT_WIDTH-1:0] x_moverMux;
input [BIT_WIDTH-1:0] y_moverMux;
input [BIT_WIDTH-1:0] z_moverMux;
input [BIT_WIDTH-1:0] ux_moverMux;
input [BIT_WIDTH-1:0] uy_moverMux;
input [BIT_WIDTH-1:0] uz_moverMux;
input [BIT_WIDTH-1:0] sz_moverMux;
input [BIT_WIDTH-1:0] sr_moverMux;
input [BIT_WIDTH-1:0] sleftz_moverMux;
input [BIT_WIDTH-1:0] sleftr_moverMux;
input [LAYER_WIDTH-1:0] layer_moverMux;
input [BIT_WIDTH-1:0] weight_moverMux;
input	dead_moverMux;

output [BIT_WIDTH-1:0] x_mover;
output [BIT_WIDTH-1:0] y_mover;
output [BIT_WIDTH-1:0] z_mover;
output [BIT_WIDTH-1:0] ux_mover;
output [BIT_WIDTH-1:0] uy_mover;
output [BIT_WIDTH-1:0] uz_mover;
output [BIT_WIDTH-1:0] sz_mover;
output [BIT_WIDTH-1:0] sr_mover;
output [BIT_WIDTH-1:0] sleftz_mover;
output [BIT_WIDTH-1:0] sleftr_mover;
output [LAYER_WIDTH-1:0]layer_mover;
output [BIT_WIDTH-1:0] weight_mover;
output	dead_mover;


input [BIT_WIDTH-1:0] OneOver_MutMaxrad_0;
input [BIT_WIDTH-1:0] OneOver_MutMaxrad_1;
input [BIT_WIDTH-1:0] OneOver_MutMaxrad_2;
input [BIT_WIDTH-1:0] OneOver_MutMaxrad_3;
input [BIT_WIDTH-1:0] OneOver_MutMaxrad_4;
input [BIT_WIDTH-1:0] OneOver_MutMaxrad_5;
input [BIT_WIDTH-1:0] OneOver_MutMaxdep_0;
input [BIT_WIDTH-1:0] OneOver_MutMaxdep_1;
input [BIT_WIDTH-1:0] OneOver_MutMaxdep_2;
input [BIT_WIDTH-1:0] OneOver_MutMaxdep_3;
input [BIT_WIDTH-1:0] OneOver_MutMaxdep_4;
input [BIT_WIDTH-1:0] OneOver_MutMaxdep_5;
input [BIT_WIDTH-1:0] OneOver_Mut_0;
input [BIT_WIDTH-1:0] OneOver_Mut_1;
input [BIT_WIDTH-1:0] OneOver_Mut_2;
input [BIT_WIDTH-1:0] OneOver_Mut_3;
input [BIT_WIDTH-1:0] OneOver_Mut_4;
input [BIT_WIDTH-1:0] OneOver_Mut_5;
input [BIT_WIDTH-1:0] log_rand_num;

//------------Local Variables------------------------
reg [BIT_WIDTH-1:0] c_sr;
reg [BIT_WIDTH-1:0] c_sz;
reg [2*BIT_WIDTH-1:0] c_sr_big;
reg [2*BIT_WIDTH-1:0] c_sz_big;
reg [BIT_WIDTH-1:0] c_sleftr;
reg [BIT_WIDTH-1:0] c_sleftz;

reg unsigned [BIT_WIDTH-1:0] c_r_op0;
reg unsigned [BIT_WIDTH-1:0] c_r_op1;
reg unsigned [BIT_WIDTH-1:0] c_z_op0;
reg unsigned [BIT_WIDTH-1:0] c_z_op1;

// grab multiplexed constant
reg [BIT_WIDTH-1:0] OneOver_MutMaxrad;
reg [BIT_WIDTH-1:0] OneOver_MutMaxdep;
reg [BIT_WIDTH-1:0] OneOver_Mut;

//------------REGISTERED Values------------------------
reg [BIT_WIDTH-1:0] x_mover;
reg [BIT_WIDTH-1:0] y_mover;
reg [BIT_WIDTH-1:0] z_mover;
reg [BIT_WIDTH-1:0] ux_mover;
reg [BIT_WIDTH-1:0] uy_mover;
reg [BIT_WIDTH-1:0] uz_mover;
reg [BIT_WIDTH-1:0] sz_mover;
reg [BIT_WIDTH-1:0] sr_mover;
reg [BIT_WIDTH-1:0] sleftz_mover;
reg [BIT_WIDTH-1:0] sleftr_mover;
reg [LAYER_WIDTH-1:0]layer_mover;
reg [BIT_WIDTH-1:0] weight_mover;
reg	dead_mover;

// multiplex constants
always @(*)
begin
case(layer_moverMux)
	3'b000:
	begin
		OneOver_MutMaxrad = OneOver_MutMaxrad_0;
		OneOver_MutMaxdep = OneOver_MutMaxdep_0;
		OneOver_Mut = OneOver_Mut_0;
	end
	3'b001:
	begin
		OneOver_MutMaxrad = OneOver_MutMaxrad_1;
		OneOver_MutMaxdep = OneOver_MutMaxdep_1;
		OneOver_Mut = OneOver_Mut_1;
	end
	3'b010:
	begin
		OneOver_MutMaxrad = OneOver_MutMaxrad_2;
		OneOver_MutMaxdep = OneOver_MutMaxdep_2;
		OneOver_Mut = OneOver_Mut_2;
	end
	3'b011:
	begin
		OneOver_MutMaxrad = OneOver_MutMaxrad_3;
		OneOver_MutMaxdep = OneOver_MutMaxdep_3;
		OneOver_Mut = OneOver_Mut_3;
	end
	3'b100:
	begin
		OneOver_MutMaxrad = OneOver_MutMaxrad_4;
		OneOver_MutMaxdep = OneOver_MutMaxdep_4;
		OneOver_Mut = OneOver_Mut_4;
	end
	3'b101:
	begin
		OneOver_MutMaxrad = OneOver_MutMaxrad_5;
		OneOver_MutMaxdep = OneOver_MutMaxdep_5;
		OneOver_Mut = OneOver_Mut_5;
	end
	default:
	begin
		OneOver_MutMaxrad = 0;
		OneOver_MutMaxdep = 0;
		OneOver_Mut = 0;
	end
endcase
end

// Determine move value
always @(*)
begin
	// Resource sharing for multipliers
	if(sleftz_moverMux == 32'b0)
	begin
		c_r_op0 = MAXLOG - log_rand_num;
		c_r_op1 = OneOver_MutMaxrad;
		c_z_op0 = MAXLOG - log_rand_num;
		c_z_op1 = OneOver_MutMaxdep;
	end
	else
	begin
		c_r_op0 = sleftr_moverMux;
		c_r_op1 = OneOver_Mut;
		c_z_op0 = sleftz_moverMux;
		c_z_op1 = OneOver_Mut;
	end
end

// Determine move value
always @(*)
begin
	c_sr_big = c_r_op0 * c_r_op1;
	c_sz_big = c_z_op0 * c_z_op1;
	if(sleftz_moverMux == 32'b0)
	begin
		c_sr = c_sr_big[2*BIT_WIDTH - LOGSCALEFACTOR - 1:BIT_WIDTH - LOGSCALEFACTOR];
		c_sz = c_sz_big[2*BIT_WIDTH - LOGSCALEFACTOR - 1:BIT_WIDTH - LOGSCALEFACTOR];

		c_sleftr = sleftr_moverMux;
		c_sleftz = 0;

		//c_sr = CONST_MOVE_AMOUNT;
		//c_sz = CONST_MOVE_AMOUNT;
	end
	else
	begin
		c_sr = c_sr_big[2*BIT_WIDTH - MUTMAX_BITS - 1 - 1:BIT_WIDTH - MUTMAX_BITS - 1];
		c_sz = c_sz_big[2*BIT_WIDTH - MUTMAX_BITS - 1 - 1:BIT_WIDTH - MUTMAX_BITS - 1];

		c_sleftz = 0;
		c_sleftr = 0;
	end
end

// latch values
always @ (posedge clock)
begin
	if (reset)
	begin
		// Photon variables
		x_mover <= 0;
		y_mover <= 0;
		z_mover <= 0;
		ux_mover <= 0;
		uy_mover <= 0;
		uz_mover <= 0;
		sz_mover <= 0;
		sr_mover <= 0;
		sleftz_mover <= 0;
		sleftr_mover <= 0;
		layer_mover <= 0;
		weight_mover <= 0;
		dead_mover <= 1'b1;
	end
	else
	begin
		if(enable)
		begin
			// Photon variables
			x_mover <= x_moverMux;
			y_mover <= y_moverMux;
			z_mover <= z_moverMux;
			ux_mover <= ux_moverMux;
			uy_mover <= uy_moverMux;
			uz_mover <= uz_moverMux;
			layer_mover <= layer_moverMux;
			weight_mover <= weight_moverMux;
			dead_mover <= dead_moverMux;

			sz_mover <= c_sz;
			sr_mover <= c_sr;
			sleftz_mover <= c_sleftz;
			sleftr_mover <= c_sleftr;
		end
	end
end

endmodule
