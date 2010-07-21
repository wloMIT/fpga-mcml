// Hop
// Author Jason Luu
// Description:
// Calculate the new coordinates of the photon, latency of one, registered outputs


module Hop(     //INPUTS
				 clock, reset, enable,
				 x_boundaryChecker, y_boundaryChecker, z_boundaryChecker,
				 ux_boundaryChecker, uy_boundaryChecker, uz_boundaryChecker,
				 sz_boundaryChecker, sr_boundaryChecker,
				 sleftz_boundaryChecker, sleftr_boundaryChecker,
				 layer_boundaryChecker, weight_boundaryChecker, dead_boundaryChecker,
				 hit_boundaryChecker,

				 //OUTPUTS
				 x_hop, y_hop, z_hop,
				 ux_hop, uy_hop, uz_hop,
				 sz_hop, sr_hop,
				 sleftz_hop, sleftr_hop,
				 layer_hop, weight_hop, dead_hop, hit_hop
				 );

parameter BIT_WIDTH=32;
parameter LAYER_WIDTH=3;
parameter INTMAX=2147483647;
parameter INTMIN=-2147483648;

input clock;
input reset;
input enable;

input [BIT_WIDTH-1:0] x_boundaryChecker;
input [BIT_WIDTH-1:0] y_boundaryChecker;
input [BIT_WIDTH-1:0] z_boundaryChecker;
input [BIT_WIDTH-1:0] ux_boundaryChecker;
input [BIT_WIDTH-1:0] uy_boundaryChecker;
input [BIT_WIDTH-1:0] uz_boundaryChecker;
input [BIT_WIDTH-1:0] sz_boundaryChecker;
input [BIT_WIDTH-1:0] sr_boundaryChecker;
input [BIT_WIDTH-1:0] sleftz_boundaryChecker;
input [BIT_WIDTH-1:0] sleftr_boundaryChecker;
input [LAYER_WIDTH-1:0] layer_boundaryChecker;
input [BIT_WIDTH-1:0] weight_boundaryChecker;
input	dead_boundaryChecker;
input	hit_boundaryChecker;

output [BIT_WIDTH-1:0] x_hop;
output [BIT_WIDTH-1:0] y_hop;
output [BIT_WIDTH-1:0] z_hop;
output [BIT_WIDTH-1:0] ux_hop;
output [BIT_WIDTH-1:0] uy_hop;
output [BIT_WIDTH-1:0] uz_hop;
output [BIT_WIDTH-1:0] sz_hop;
output [BIT_WIDTH-1:0] sr_hop;
output [BIT_WIDTH-1:0] sleftz_hop;
output [BIT_WIDTH-1:0] sleftr_hop;
output [LAYER_WIDTH-1:0]layer_hop;
output [BIT_WIDTH-1:0] weight_hop;
output dead_hop;
output hit_hop;

//------------Local Variables------------------------
reg [BIT_WIDTH-1:0] c_x;
reg [BIT_WIDTH-1:0] c_y;
reg [BIT_WIDTH-1:0] c_z;
reg c_dead;

reg [BIT_WIDTH:0] c_x_big;
reg [BIT_WIDTH:0] c_y_big;
reg [BIT_WIDTH:0] c_z_big;

wire [2*BIT_WIDTH-1:0] c_xmult_big;
wire [2*BIT_WIDTH-1:0] c_ymult_big;
wire [2*BIT_WIDTH-1:0] c_zmult_big;

//------------REGISTERED Values------------------------
reg [BIT_WIDTH-1:0] x_hop;
reg [BIT_WIDTH-1:0] y_hop;
reg [BIT_WIDTH-1:0] z_hop;
reg [BIT_WIDTH-1:0] ux_hop;
reg [BIT_WIDTH-1:0] uy_hop;
reg [BIT_WIDTH-1:0] uz_hop;
reg [BIT_WIDTH-1:0] sz_hop;
reg [BIT_WIDTH-1:0] sr_hop;
reg [BIT_WIDTH-1:0] sleftz_hop;
reg [BIT_WIDTH-1:0] sleftr_hop;
reg [LAYER_WIDTH-1:0]layer_hop;
reg [BIT_WIDTH-1:0] weight_hop;
reg	dead_hop;
reg	hit_hop;

mult_signed_32 u1(sr_boundaryChecker, ux_boundaryChecker, c_xmult_big);
mult_signed_32 u2(sr_boundaryChecker, uy_boundaryChecker, c_ymult_big);
mult_signed_32 u3(sz_boundaryChecker, uz_boundaryChecker, c_zmult_big);

// Determine new (x,y,z) coordinates
always @(*)
begin
	
	c_dead = dead_boundaryChecker;
		
	c_x_big = x_boundaryChecker + c_xmult_big[2*BIT_WIDTH-2:31];
	c_y_big = y_boundaryChecker + c_ymult_big[2*BIT_WIDTH-2:31];
	c_z_big = z_boundaryChecker + c_zmult_big[2*BIT_WIDTH-2:31];

	// Calculate x position, photon dies if outside grid
	c_x = c_x_big[BIT_WIDTH-1:0];
	
	if(c_x_big[BIT_WIDTH] != c_x_big[BIT_WIDTH-1] && x_boundaryChecker[BIT_WIDTH-1] == c_xmult_big[2*BIT_WIDTH-2])
	begin
		if(c_x_big[BIT_WIDTH] == 1'b0)
		begin
			c_dead = 1'b1;
			c_x = INTMAX;
		end
		else
		begin
			c_dead = 1'b1;
			c_x = INTMIN;
		end
	end

	c_y = c_y_big[BIT_WIDTH-1:0];	
	// Calculate y position, photon dies if outside grid
	if(c_y_big[BIT_WIDTH] != c_y_big[BIT_WIDTH-1] && y_boundaryChecker[BIT_WIDTH-1] == c_ymult_big[2*BIT_WIDTH-2])
	begin
		if(c_y_big[BIT_WIDTH] == 1'b0)
		begin
			c_dead = 1'b1;
			c_y = INTMAX;
		end
		else
		begin
			c_dead = 1'b1;
			c_y = INTMIN;
		end
	end
	
	// Calculate z position, photon dies if outside grid
	c_z = c_z_big[BIT_WIDTH-1:0];
	if(hit_boundaryChecker) 
	begin
		c_z = z_boundaryChecker;
	end
	else if(c_z_big[BIT_WIDTH] != c_z_big[BIT_WIDTH-1] && z_boundaryChecker[BIT_WIDTH-1] == c_zmult_big[2*BIT_WIDTH-2])
	begin
		c_dead = 1'b1;
		c_z = INTMAX;
	end
	else if (c_z_big[BIT_WIDTH-1] == 1'b1)
	begin
		c_dead = 1'b1;
		c_z = 0;
	end
end

// latch values
always @ (posedge clock)
begin
	if (reset)
	begin
		// Photon variables
		x_hop <= 0;
		y_hop <= 0;
		z_hop <= 0;
		ux_hop <= 0;
		uy_hop <= 0;
		uz_hop <= 0;
		sz_hop <= 0;
		sr_hop <= 0;
		sleftz_hop <= 0;
		sleftr_hop <= 0;
		layer_hop <= 0;
		weight_hop <= 0;
		dead_hop <= 1'b1;
		hit_hop <= 1'b0;
	end
	else
	begin
		if(enable)
		begin
			// Photon variables
			ux_hop <= ux_boundaryChecker;
			uy_hop <= uy_boundaryChecker;
			uz_hop <= uz_boundaryChecker;
			sz_hop <= sz_boundaryChecker;
			sr_hop <= sr_boundaryChecker;
			sleftz_hop <= sleftz_boundaryChecker;
			sleftr_hop <= sleftr_boundaryChecker;
			layer_hop <= layer_boundaryChecker;
			weight_hop <= weight_boundaryChecker;
			hit_hop <= hit_boundaryChecker;

			x_hop <= c_x;
			y_hop <= c_y;
			z_hop <= c_z;
			dead_hop <= c_dead;
		end			
	end
end

endmodule
