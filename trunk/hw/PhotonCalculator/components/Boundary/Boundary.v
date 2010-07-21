// Boundary
// Author Jason Luu
// Description:
// Determine if the photon has crossed the layer boundary, if it did, move it to the boundary and set hit to 1
// Latency = latency of divide + 1
// The Pipeline for this file is huge with only a few signals that need to be pulled out at different times


module Boundary ( //INPUTS
				 clock, reset, enable,
				 x_mover, y_mover, z_mover,
				 ux_mover, uy_mover, uz_mover,
				 sz_mover, sr_mover,
				 sleftz_mover, sleftr_mover,
				 layer_mover, weight_mover, dead_mover,

				 //OUTPUTS
				 x_boundaryChecker, y_boundaryChecker, z_boundaryChecker,
				 ux_boundaryChecker, uy_boundaryChecker, uz_boundaryChecker,
				 sz_boundaryChecker, sr_boundaryChecker,
				 sleftz_boundaryChecker, sleftr_boundaryChecker,
				 layer_boundaryChecker, weight_boundaryChecker, dead_boundaryChecker, hit_boundaryChecker,

				 //CONSTANTS
				 z1_0, z1_1, z1_2, z1_3, z1_4, z1_5, 
				 z0_0, z0_1, z0_2, z0_3, z0_4, z0_5,
				 mut_0, mut_1, mut_2, mut_3, mut_4, mut_5, 
				 maxDepth_over_maxRadius
				 );

parameter BIT_WIDTH=32;
parameter LAYER_WIDTH=3;
parameter INTMAX=2147483647;
parameter INTMIN=-2147483648;
parameter DIVIDER_LATENCY=30;
parameter FINAL_LATENCY=28;
parameter MULT_LATENCY=1;
parameter ASPECT_RATIO = 7;
parameter TOTAL_LATENCY = DIVIDER_LATENCY + FINAL_LATENCY + MULT_LATENCY + MULT_LATENCY;

integer i, j;

input clock;
input reset;
input enable;

input [BIT_WIDTH-1:0] x_mover;
input [BIT_WIDTH-1:0] y_mover;
input [BIT_WIDTH-1:0] z_mover;
input [BIT_WIDTH-1:0] ux_mover;
input [BIT_WIDTH-1:0] uy_mover;
input [BIT_WIDTH-1:0] uz_mover;
input [BIT_WIDTH-1:0] sz_mover;
input [BIT_WIDTH-1:0] sr_mover;
input [BIT_WIDTH-1:0] sleftz_mover;
input [BIT_WIDTH-1:0] sleftr_mover;
input [LAYER_WIDTH-1:0] layer_mover;
input [BIT_WIDTH-1:0] weight_mover;
input	dead_mover;

output [BIT_WIDTH-1:0] x_boundaryChecker;
output [BIT_WIDTH-1:0] y_boundaryChecker;
output [BIT_WIDTH-1:0] z_boundaryChecker;
output [BIT_WIDTH-1:0] ux_boundaryChecker;
output [BIT_WIDTH-1:0] uy_boundaryChecker;
output [BIT_WIDTH-1:0] uz_boundaryChecker;
output [BIT_WIDTH-1:0] sz_boundaryChecker;
output [BIT_WIDTH-1:0] sr_boundaryChecker;
output [BIT_WIDTH-1:0] sleftz_boundaryChecker;
output [BIT_WIDTH-1:0] sleftr_boundaryChecker;
output [LAYER_WIDTH-1:0]layer_boundaryChecker;
output [BIT_WIDTH-1:0] weight_boundaryChecker;
output dead_boundaryChecker;
output hit_boundaryChecker;

// Constants
input [BIT_WIDTH-1:0] z1_0;
input [BIT_WIDTH-1:0] z1_1;
input [BIT_WIDTH-1:0] z1_2;
input [BIT_WIDTH-1:0] z1_3;
input [BIT_WIDTH-1:0] z1_4;
input [BIT_WIDTH-1:0] z1_5;
input [BIT_WIDTH-1:0] z0_0;
input [BIT_WIDTH-1:0] z0_1;
input [BIT_WIDTH-1:0] z0_2;
input [BIT_WIDTH-1:0] z0_3;
input [BIT_WIDTH-1:0] z0_4;
input [BIT_WIDTH-1:0] z0_5;
input [BIT_WIDTH-1:0] mut_0;
input [BIT_WIDTH-1:0] mut_1;
input [BIT_WIDTH-1:0] mut_2;
input [BIT_WIDTH-1:0] mut_3;
input [BIT_WIDTH-1:0] mut_4;
input [BIT_WIDTH-1:0] mut_5;
input [BIT_WIDTH-1:0] maxDepth_over_maxRadius;


//WIRES FOR CONNECTING REGISTERS
reg	[BIT_WIDTH-1:0]				c_x	[TOTAL_LATENCY - 1:0];
reg	[BIT_WIDTH-1:0]				c_y	[TOTAL_LATENCY - 1:0];
reg	[BIT_WIDTH-1:0]				c_z	[TOTAL_LATENCY - 1:0];
reg	[BIT_WIDTH-1:0]				c_ux	[TOTAL_LATENCY - 1:0];
reg	[BIT_WIDTH-1:0]				c_uy	[TOTAL_LATENCY - 1:0];
reg	[BIT_WIDTH-1:0]				c_uz	[TOTAL_LATENCY - 1:0];
reg	[BIT_WIDTH-1:0]				c_sz	[TOTAL_LATENCY - 1:0];
reg	[BIT_WIDTH-1:0]				c_sr	[TOTAL_LATENCY - 1:0];
reg	[BIT_WIDTH-1:0]				c_sleftz	[TOTAL_LATENCY - 1:0];
reg	[BIT_WIDTH-1:0]				c_sleftr	[TOTAL_LATENCY - 1:0];
reg	[BIT_WIDTH-1:0]				c_weight	[TOTAL_LATENCY - 1:0];
reg	[LAYER_WIDTH-1:0]			c_layer	[TOTAL_LATENCY - 1:0];
reg								c_dead	[TOTAL_LATENCY - 1:0];
reg								c_hit	[TOTAL_LATENCY - 1:0];
reg	[BIT_WIDTH-1:0]				c_diff[TOTAL_LATENCY - 1:0];
reg	[BIT_WIDTH-1:0]				c_dl_b[TOTAL_LATENCY - 1:0];
reg	[2*BIT_WIDTH-1:0]			c_numer[TOTAL_LATENCY - 1:0];
reg	[BIT_WIDTH-1:0]				c_z1[TOTAL_LATENCY - 1:0];
reg	[BIT_WIDTH-1:0]				c_z0[TOTAL_LATENCY - 1:0];
reg	[BIT_WIDTH-1:0]				c_mut[TOTAL_LATENCY - 1:0];

reg	[BIT_WIDTH-1:0]				r_x	[TOTAL_LATENCY - 1:0];
reg	[BIT_WIDTH-1:0]				r_y	[TOTAL_LATENCY - 1:0];
reg	[BIT_WIDTH-1:0]				r_z	[TOTAL_LATENCY - 1:0];
reg	[BIT_WIDTH-1:0]				r_ux	[TOTAL_LATENCY - 1:0];
reg	[BIT_WIDTH-1:0]				r_uy	[TOTAL_LATENCY - 1:0];
reg	[BIT_WIDTH-1:0]				r_uz	[TOTAL_LATENCY - 1:0];
reg	[BIT_WIDTH-1:0]				r_sz	[TOTAL_LATENCY - 1:0];
reg	[BIT_WIDTH-1:0]				r_sr	[TOTAL_LATENCY - 1:0];
reg	[BIT_WIDTH-1:0]				r_sleftz	[TOTAL_LATENCY - 1:0];
reg	[BIT_WIDTH-1:0]				r_sleftr	[TOTAL_LATENCY - 1:0];
reg	[BIT_WIDTH-1:0]				r_weight	[TOTAL_LATENCY - 1:0];
reg	[LAYER_WIDTH-1:0]			r_layer	[TOTAL_LATENCY - 1:0];
reg								r_dead	[TOTAL_LATENCY - 1:0];
reg								r_hit	[TOTAL_LATENCY - 1:0];
reg	[BIT_WIDTH-1:0]				r_diff[TOTAL_LATENCY - 1:0];
reg	[BIT_WIDTH-1:0]				r_dl_b[TOTAL_LATENCY - 1:0];
reg	[2*BIT_WIDTH-1:0]			r_numer[TOTAL_LATENCY - 1:0];
reg	[BIT_WIDTH-1:0]				r_z1[TOTAL_LATENCY - 1:0];
reg	[BIT_WIDTH-1:0]				r_z0[TOTAL_LATENCY - 1:0];
reg	[BIT_WIDTH-1:0]				r_mut[TOTAL_LATENCY - 1:0];

wire	[2*BIT_WIDTH-1:0]			sleftz_big;
wire	[2*BIT_WIDTH-1:0]			sleftr_big;
wire	[2*BIT_WIDTH-1:0]			sr_big;
wire	[BIT_WIDTH-1:0]				remainder_div1;
wire	[2*BIT_WIDTH-1:0]			quotient_div1;

//ASSIGNMENTS FROM PIPE TO OUTPUT
assign x_boundaryChecker = r_x[TOTAL_LATENCY - 1];
assign y_boundaryChecker = r_y[TOTAL_LATENCY - 1];
assign z_boundaryChecker = r_z[TOTAL_LATENCY - 1];
assign ux_boundaryChecker = r_ux[TOTAL_LATENCY - 1];
assign uy_boundaryChecker = r_uy[TOTAL_LATENCY - 1];
assign uz_boundaryChecker = r_uz[TOTAL_LATENCY - 1];
assign sz_boundaryChecker = r_sz[TOTAL_LATENCY - 1];
assign sr_boundaryChecker = r_sr[TOTAL_LATENCY - 1];
assign sleftz_boundaryChecker = r_sleftz[TOTAL_LATENCY - 1];
assign sleftr_boundaryChecker = r_sleftr[TOTAL_LATENCY - 1];
assign weight_boundaryChecker = r_weight[TOTAL_LATENCY - 1];
assign layer_boundaryChecker = r_layer[TOTAL_LATENCY - 1];
assign dead_boundaryChecker = r_dead[TOTAL_LATENCY - 1];
assign hit_boundaryChecker = r_hit[TOTAL_LATENCY - 1];

// divider
signed_div_30 divide_u1 (
	.clock(clock),
	.denom(c_uz[0]),
	.numer(c_numer[0]),
	.quotient(quotient_div1),
	.remain(remainder_div1));

// multipliers
mult_signed_32_bc mult_u1(
	.clock(clock),
	.dataa(c_diff[DIVIDER_LATENCY]),
	.datab(c_mut[DIVIDER_LATENCY]),
	.result(sleftz_big));

mult_signed_32_bc mult_u2(
	.clock(clock),
	.dataa(maxDepth_over_maxRadius),
	.datab(c_sleftz[DIVIDER_LATENCY + MULT_LATENCY]),
	.result(sleftr_big));

mult_signed_32_bc mult_u3(
	.clock(clock),
	.dataa(maxDepth_over_maxRadius),
	.datab(c_dl_b[DIVIDER_LATENCY]),
	.result(sr_big));

// multiplexor to find z1 and z0
always @(*)
begin
	case(c_layer[0])
		3'b000:
		begin
			c_z1[0] = z1_0;
			c_z0[0] = z0_0;
			c_mut[0] = mut_0;
		end
		3'b001:
		begin
			c_z1[0] = z1_1;
			c_z0[0] = z0_1;
			c_mut[0] = mut_1;
		end
		3'b010:
		begin
			c_z1[0] = z1_2;
			c_z0[0] = z0_2;
			c_mut[0] = mut_2;
		end
		3'b011:
		begin
			c_z1[0] = z1_3;
			c_z0[0] = z0_3;
			c_mut[0] = mut_3;
		end
		3'b100:
		begin
			c_z1[0] = z1_4;
			c_z0[0] = z0_4;
			c_mut[0] = mut_4;
		end
		3'b101:
		begin
			c_z1[0] = z1_5;
			c_z0[0] = z0_5;
			c_mut[0] = mut_5;
		end
		default:
		begin
			c_z1[0] = 0;
			c_z0[0] = 0;
			c_mut[0] = 0;
		end
	endcase
end

// set numerator
always @(*)
begin
	c_numer[0] = 63'b0;
	if(c_uz[0][31] == 1'b0)
	begin
		c_numer[0][63:32] = c_z1[0] - c_z[0];
	end
	if(c_uz[0][31] == 1'b1)
	begin
		c_numer[0][63:32] = c_z0[0] - c_z[0];
	end
end

// initialize uninitialized data in pipeline
always @(*)
begin
	c_x[0] = x_mover;
	c_y[0] = y_mover;
	c_z[0] = z_mover;
	c_ux[0] = ux_mover;
	c_uy[0] = uy_mover;
	c_uz[0] = uz_mover;
	c_sz[0] = sz_mover;
	c_sr[0] = sr_mover;
	c_sleftz[0] = sleftz_mover;
	c_sleftr[0] = sleftr_mover;
	c_weight[0] = weight_mover;
	c_layer[0] = layer_mover;
	c_dead[0] = dead_mover;
	c_hit[0] = 1'b0;
	c_diff[0] = 32'b0;
	c_dl_b[0] = 32'b0;
end

// Determine new (x,y,z) coordinates
always @(*)
begin
	// default
	// setup standard pipeline
	for(i = 1; i < TOTAL_LATENCY; i = i + 1)
	begin
		c_x[i]	= r_x[i-1];
		c_y[i]	= r_y[i-1];
		c_z[i]	= r_z[i-1];
		c_ux[i]	= r_ux[i-1];
		c_uy[i]	= r_uy[i-1];
		c_uz[i]	= r_uz[i-1];
		c_sz[i]	= r_sz[i-1];
		c_sr[i]	= r_sr[i-1];
		c_sleftz[i]	= r_sleftz[i-1];
		c_sleftr[i]	= r_sleftr[i-1];
		c_weight[i]	= r_weight[i-1];
		c_layer[i]	= r_layer[i-1];
		c_dead[i]	= r_dead[i-1];
		c_hit[i]	= r_hit[i-1];
		c_diff[i] = r_diff[i-1];
		c_dl_b[i] = r_dl_b[i-1];
		c_numer[i] = r_numer[i-1];
		c_z1[i] = r_z1[i-1];
		c_z0[i] = r_z0[i-1];
		c_mut[i] = r_mut[i-1];
	end

	// Pull out and replace signals in pipe
	/* STAGE 1: Division completed */
	c_dl_b[DIVIDER_LATENCY] = quotient_div1[32:1];
	c_diff[DIVIDER_LATENCY] = c_sz[DIVIDER_LATENCY] - c_dl_b[DIVIDER_LATENCY];

	if(c_uz[DIVIDER_LATENCY] != 32'b0 && c_sz[DIVIDER_LATENCY] > c_dl_b[DIVIDER_LATENCY] && quotient_div1[63:32] == 32'b0)
	begin
		/* not horizontal & crossing. */
		c_hit[DIVIDER_LATENCY] = 1'b1;
	end

	/* STAGE 2: First multiply completed */
	if(c_hit[DIVIDER_LATENCY + MULT_LATENCY] == 1'b1)
	begin
		/*step left = (original step - distance travelled) * scaling factor*/

		c_sleftz[DIVIDER_LATENCY + MULT_LATENCY] = sleftz_big[2*BIT_WIDTH-2:BIT_WIDTH - 1];
		if(c_uz[DIVIDER_LATENCY + MULT_LATENCY][BIT_WIDTH-1] == 1'b0) 
		begin
			c_z[DIVIDER_LATENCY + MULT_LATENCY] = c_z1[DIVIDER_LATENCY + MULT_LATENCY];
		end
		else
		begin
			c_z[DIVIDER_LATENCY + MULT_LATENCY] = c_z0[DIVIDER_LATENCY + MULT_LATENCY];
		end

		c_sz[DIVIDER_LATENCY + MULT_LATENCY] = c_dl_b[DIVIDER_LATENCY + MULT_LATENCY];
		c_sr[DIVIDER_LATENCY + MULT_LATENCY] = sr_big[2*BIT_WIDTH-2 - ASPECT_RATIO:BIT_WIDTH - 1 - ASPECT_RATIO];
	end

	/* STAGE 3: Second multiply completed */
	if(c_hit[DIVIDER_LATENCY + 2*MULT_LATENCY] == 1'b1)
	begin
		/*additional scaling factor on dl_b to switch to r-dimension scale*/
		c_sleftr[DIVIDER_LATENCY + 2*MULT_LATENCY] = sleftr_big[2*BIT_WIDTH-2 - ASPECT_RATIO:BIT_WIDTH - 1 - ASPECT_RATIO];

	end
end

// latch values
always @ (posedge clock)
begin
	for(j = 0; j < TOTAL_LATENCY; j = j + 1)
	begin
		if (reset)
		begin
			r_x[j]	<= 32'b0;
			r_y[j]	<= 32'b0;
			r_z[j]	<= 32'b0;
			r_ux[j]	<= 32'b0;
			r_uy[j]	<= 32'b0;
			r_uz[j]	<= 32'b0;
			r_sz[j]	<= 32'b0;
			r_sr[j]	<= 32'b0;
			r_sleftz[j]	<= 32'b0;
			r_sleftr[j]	<= 32'b0;
			r_weight[j]	<= 32'b0;
			r_layer[j]	<= 3'b0;
			r_dead[j]	<= 1'b1;
			r_hit[j]	<= 1'b0;
			r_diff[j] <= 32'b0;
			r_dl_b[j] <= 32'b0;
			r_numer[j] <= 64'b0;
			r_z1[j] <= 32'b0;
			r_z0[j] <= 32'b0;
			r_mut[j] <= 32'b0;
		end
		else
		begin
			if(enable)
			begin
				r_x[j]	<= c_x[j];
				r_y[j]	<= c_y[j];
				r_z[j]	<= c_z[j];
				r_ux[j]	<= c_ux[j];
				r_uy[j]	<= c_uy[j];
				r_uz[j]	<= c_uz[j];
				r_sz[j]	<= c_sz[j];
				r_sr[j]	<= c_sr[j];
				r_sleftz[j]	<= c_sleftz[j];
				r_sleftr[j]	<= c_sleftr[j];
				r_weight[j]	<= c_weight[j];
				r_layer[j]	<= c_layer[j];
				r_dead[j]	<= c_dead[j];
				r_hit[j]	<= c_hit[j];
				r_diff[j] <= c_diff[j];
				r_dl_b[j] <= c_dl_b[j];
				r_numer[j] <= c_numer[j];
				r_z1[j] <= c_z1[j];
				r_z0[j] <= c_z0[j];
				r_mut[j] <= c_mut[j];
			end
		end
	end
end

endmodule
