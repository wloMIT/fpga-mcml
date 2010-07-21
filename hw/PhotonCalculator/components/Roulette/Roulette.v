//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Roulette Module                                             ////
////                                                              ////
////  Description:                                                ////
////  Implementation of Roulette Module                           ////
////                                                              ////
////  Author(s):                                                  ////
////      - William                                               ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

module Roulette ( //INPUTS
                     clock, reset, enable, 
                     x_RouletteMux, y_RouletteMux, z_RouletteMux,  
                     ux_RouletteMux, uy_RouletteMux, uz_RouletteMux, 
                     sz_RouletteMux, sr_RouletteMux, 
                     sleftz_RouletteMux, sleftr_RouletteMux, 
                     layer_RouletteMux, weight_absorber, dead_RouletteMux, 
			
		     //From Random Number Generator in Skeleton.v	
		     randnumber,
                     
                     //OUTPUTS
                     x_Roulette, y_Roulette, z_Roulette,
                     ux_Roulette, uy_Roulette, uz_Roulette, 
                     sz_Roulette, sr_Roulette, 
                     sleftz_Roulette, sleftr_Roulette, 
                     layer_Roulette, weight_Roulette, dead_Roulette
                     ); 

parameter BIT_WIDTH=32;
parameter LAYER_WIDTH=3; 

parameter LEFTSHIFT=3;         // 2^3=8=1/0.125 where 0.125 = CHANCE of roulette
parameter INTCHANCE=536870912; //Based on 32 bit rand num generator
parameter MIN_WEIGHT=200; 

input clock;        
input reset;
input enable;

input [BIT_WIDTH-1:0] x_RouletteMux;
input [BIT_WIDTH-1:0] y_RouletteMux;
input [BIT_WIDTH-1:0] z_RouletteMux;
input [BIT_WIDTH-1:0] ux_RouletteMux;
input [BIT_WIDTH-1:0] uy_RouletteMux;
input [BIT_WIDTH-1:0] uz_RouletteMux;
input [BIT_WIDTH-1:0] sz_RouletteMux;
input [BIT_WIDTH-1:0] sr_RouletteMux;
input [BIT_WIDTH-1:0] sleftz_RouletteMux;
input [BIT_WIDTH-1:0] sleftr_RouletteMux;
input [LAYER_WIDTH-1:0] layer_RouletteMux;
input [BIT_WIDTH-1:0] weight_absorber;
input [BIT_WIDTH-1:0] randnumber;
input dead_RouletteMux;
              
output [BIT_WIDTH-1:0] x_Roulette;
output [BIT_WIDTH-1:0] y_Roulette;
output [BIT_WIDTH-1:0] z_Roulette;
output [BIT_WIDTH-1:0] ux_Roulette;
output [BIT_WIDTH-1:0] uy_Roulette;
output [BIT_WIDTH-1:0] uz_Roulette;
output [BIT_WIDTH-1:0] sz_Roulette;
output [BIT_WIDTH-1:0] sr_Roulette;
output [BIT_WIDTH-1:0] sleftz_Roulette;
output [BIT_WIDTH-1:0] sleftr_Roulette;
output [LAYER_WIDTH-1:0]layer_Roulette;
output [BIT_WIDTH-1:0] weight_Roulette;
output dead_Roulette;

//------------Local Variables------------------------
reg dead_roulette; 
reg [BIT_WIDTH-1:0] weight_roulette; 
reg [31:0] randBits;             //Hard-coded bitwidth because rng is 32-bit

//------------REGISTERED Values------------------------
reg [BIT_WIDTH-1:0] x_Roulette;
reg [BIT_WIDTH-1:0] y_Roulette;
reg [BIT_WIDTH-1:0] z_Roulette;
reg [BIT_WIDTH-1:0] ux_Roulette;
reg [BIT_WIDTH-1:0] uy_Roulette;
reg [BIT_WIDTH-1:0] uz_Roulette;
reg [BIT_WIDTH-1:0] sz_Roulette;
reg [BIT_WIDTH-1:0] sr_Roulette;
reg [BIT_WIDTH-1:0] sleftz_Roulette;
reg [BIT_WIDTH-1:0] sleftr_Roulette;
reg [LAYER_WIDTH-1:0]layer_Roulette;
reg [BIT_WIDTH-1:0] weight_Roulette;
reg dead_Roulette;
   
always @ (*) begin 
  	randBits = randnumber;   //Reading from external random num generator
	weight_roulette=weight_absorber;	//Avoid inferring a latch
	dead_roulette=dead_RouletteMux; 
	
	if (reset) begin 
		//Local variables
		weight_roulette=0; 
		dead_roulette=0; 
		randBits=0; 
	end

	else if (enable) begin
		//DO ROULETTE!!!
		if (weight_absorber < MIN_WEIGHT && !dead_RouletteMux) begin
			//Replicate Operator (same as 32'b000000..., except more flexible)			
			if (weight_absorber== {BIT_WIDTH{1'b0}}) begin
				dead_roulette = 1;
				weight_roulette = weight_absorber;
			end
				
			else if (randBits < INTCHANCE) begin // survived the roulette
				dead_roulette=0;
				weight_roulette=weight_absorber << LEFTSHIFT; //To avoid mult
			end
			
			else begin
				dead_roulette=1;
				weight_roulette = weight_absorber;
			end
		end
		
		//No Roulette
		else  begin
			weight_roulette = weight_absorber;
			dead_roulette = 0;
		end
	end
end 

always @ (posedge clock) begin
	if (reset) begin
		x_Roulette <= 0;
		y_Roulette <= 0;
		z_Roulette <= 0;
		ux_Roulette <= 0;
		uy_Roulette <= 0;
		uz_Roulette <= 0;
		sz_Roulette <= 0;
		sr_Roulette <= 0;
		sleftz_Roulette <= 0;
		sleftr_Roulette <= 0;
		layer_Roulette <= 0;
		weight_Roulette <= 0;
		dead_Roulette <= 1'b1;
	end
	
	else if (enable) begin
		//Write through values from Roulette block
		dead_Roulette <= (dead_RouletteMux | dead_roulette);   //OR operator ???
		weight_Roulette <= weight_roulette; //weight_absorber.read();

		//Write through unchanged values
		x_Roulette <= x_RouletteMux;
		y_Roulette <= y_RouletteMux;
		z_Roulette <= z_RouletteMux;

		ux_Roulette <= ux_RouletteMux;
		uy_Roulette <= uy_RouletteMux;
		uz_Roulette <= uz_RouletteMux;
		sz_Roulette <= sz_RouletteMux;
		sr_Roulette <= sr_RouletteMux;
		sleftz_Roulette <= sleftz_RouletteMux;
		sleftr_Roulette <= sleftr_RouletteMux;
		layer_Roulette <= layer_RouletteMux;
	end
end

endmodule
