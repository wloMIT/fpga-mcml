//  Photon Calculator
// Note: Use the same random number for fresnel (reflect) as for scatterer because they are mutually exclusive blocks
//       Also scatterer needs two

module PhotonCalculator (
	clock, reset, enable,

	// CONSTANTS
	total_photons,

	randseed1, randseed2, randseed3, randseed4, randseed5,
	
	initialWeight,

	//   Mover
	OneOver_MutMaxrad_0, OneOver_MutMaxrad_1, OneOver_MutMaxrad_2, OneOver_MutMaxrad_3, OneOver_MutMaxrad_4, OneOver_MutMaxrad_5,
	OneOver_MutMaxdep_0, OneOver_MutMaxdep_1, OneOver_MutMaxdep_2, OneOver_MutMaxdep_3, OneOver_MutMaxdep_4, OneOver_MutMaxdep_5,
	OneOver_Mut_0, OneOver_Mut_1, OneOver_Mut_2, OneOver_Mut_3, OneOver_Mut_4, OneOver_Mut_5,

	//   BoundaryChecker
	z1_0, z1_1, z1_2, z1_3, z1_4, z1_5,
	z0_0, z0_1, z0_2, z0_3, z0_4, z0_5,
	mut_0, mut_1, mut_2, mut_3, mut_4, mut_5,
	maxDepth_over_maxRadius,

	//   Hop (no constants)

	//   Scatterer Reflector Wrapper
	down_niOverNt_1, down_niOverNt_2, down_niOverNt_3, down_niOverNt_4, down_niOverNt_5,
	up_niOverNt_1, up_niOverNt_2, up_niOverNt_3, up_niOverNt_4, up_niOverNt_5,
	down_niOverNt_2_1, down_niOverNt_2_2, down_niOverNt_2_3, down_niOverNt_2_4, down_niOverNt_2_5,
	up_niOverNt_2_1, up_niOverNt_2_2, up_niOverNt_2_3, up_niOverNt_2_4, up_niOverNt_2_5,
	downCritAngle_0, downCritAngle_1, downCritAngle_2, downCritAngle_3, downCritAngle_4,
	upCritAngle_0, upCritAngle_1, upCritAngle_2, upCritAngle_3, upCritAngle_4,
	muaFraction1, muaFraction2, muaFraction3, muaFraction4, muaFraction5,
	  // Interface to memory look-up
	    // From Memories
	up_rFresnel, down_rFresnel, sint, cost,
		// To Memories
	tindex, fresIndex,

	// Roulette (no Constants)

	// Absorber
	absorb_data, absorb_rdaddress, absorb_wraddress, 
	absorb_wren, absorb_q,

	// Done signal
	done
	);
parameter BIT_WIDTH=32;
parameter LAYER_WIDTH=3;
parameter TRIG_WIDTH=10;
parameter PIPELINE_DEPTH_UPPER_LIMIT = 256;
parameter ABSORB_ADDR_WIDTH=16;
parameter ABSORB_WORD_WIDTH=64;
parameter WSCALE=1919999;


input clock, reset, enable;

// CONSTANTS
input [BIT_WIDTH-1:0] total_photons;

input [BIT_WIDTH-1:0] randseed1;
input [BIT_WIDTH-1:0] randseed2;
input [BIT_WIDTH-1:0] randseed3;
input [BIT_WIDTH-1:0] randseed4;
input [BIT_WIDTH-1:0] randseed5;

input [BIT_WIDTH-1:0] initialWeight;

//   Mover
input [BIT_WIDTH-1:0] OneOver_MutMaxrad_0, OneOver_MutMaxrad_1, OneOver_MutMaxrad_2, OneOver_MutMaxrad_3, OneOver_MutMaxrad_4, OneOver_MutMaxrad_5;
input [BIT_WIDTH-1:0] OneOver_MutMaxdep_0, OneOver_MutMaxdep_1, OneOver_MutMaxdep_2, OneOver_MutMaxdep_3, OneOver_MutMaxdep_4, OneOver_MutMaxdep_5;
input [BIT_WIDTH-1:0] OneOver_Mut_0, OneOver_Mut_1, OneOver_Mut_2, OneOver_Mut_3, OneOver_Mut_4, OneOver_Mut_5;

//   BoundaryChecker
input [BIT_WIDTH-1:0] z1_0, z1_1, z1_2, z1_3, z1_4, z1_5;
input [BIT_WIDTH-1:0] z0_0, z0_1, z0_2, z0_3, z0_4, z0_5;
input [BIT_WIDTH-1:0] mut_0, mut_1, mut_2, mut_3, mut_4, mut_5;
input [BIT_WIDTH-1:0] maxDepth_over_maxRadius;

//   Hop (no constants)

//   Scatterer Reflector Absorber Wrapper
input [BIT_WIDTH-1:0] down_niOverNt_1, down_niOverNt_2, down_niOverNt_3, down_niOverNt_4, down_niOverNt_5;
input [BIT_WIDTH-1:0] up_niOverNt_1, up_niOverNt_2, up_niOverNt_3, up_niOverNt_4, up_niOverNt_5;
input [2*BIT_WIDTH-1:0] down_niOverNt_2_1, down_niOverNt_2_2, down_niOverNt_2_3, down_niOverNt_2_4, down_niOverNt_2_5;
input [2*BIT_WIDTH-1:0] up_niOverNt_2_1, up_niOverNt_2_2, up_niOverNt_2_3, up_niOverNt_2_4, up_niOverNt_2_5;
input [BIT_WIDTH-1:0] downCritAngle_0, downCritAngle_1, downCritAngle_2, downCritAngle_3, downCritAngle_4;
input [BIT_WIDTH-1:0] upCritAngle_0, upCritAngle_1, upCritAngle_2, upCritAngle_3, upCritAngle_4;
input [BIT_WIDTH-1:0] muaFraction1, muaFraction2, muaFraction3, muaFraction4, muaFraction5;

  // Memory look-up interface
input [BIT_WIDTH-1:0] up_rFresnel;
input [BIT_WIDTH-1:0] down_rFresnel;
input [BIT_WIDTH-1:0] sint;
input [BIT_WIDTH-1:0] cost;
	//To Memories
output [12:0] tindex;
output [9:0] fresIndex;

//   Roulette Module (nothing)

// Final results
output [ABSORB_ADDR_WIDTH-1:0] absorb_rdaddress, absorb_wraddress;
output absorb_wren;
output [ABSORB_WORD_WIDTH-1:0] absorb_data;
input [ABSORB_WORD_WIDTH-1:0] absorb_q;

// Flag when final results ready
output done;


// Local variables
// Wired nets
/*mover inputs*/
reg [BIT_WIDTH-1:0] x_moverMux;
reg [BIT_WIDTH-1:0] y_moverMux;
reg [BIT_WIDTH-1:0] z_moverMux;
reg [BIT_WIDTH-1:0] ux_moverMux;
reg [BIT_WIDTH-1:0] uy_moverMux;
reg [BIT_WIDTH-1:0] uz_moverMux;
reg [BIT_WIDTH-1:0] sz_moverMux;
reg [BIT_WIDTH-1:0] sr_moverMux;
reg [BIT_WIDTH-1:0] sleftz_moverMux;
reg [BIT_WIDTH-1:0] sleftr_moverMux;
reg [LAYER_WIDTH-1:0] layer_moverMux;
reg [BIT_WIDTH-1:0] weight_moverMux;
reg dead_moverMux;

/*mover outputs*/
wire [BIT_WIDTH-1:0] x_mover;
wire [BIT_WIDTH-1:0] y_mover;
wire [BIT_WIDTH-1:0] z_mover;
wire [BIT_WIDTH-1:0] ux_mover;
wire [BIT_WIDTH-1:0] uy_mover;
wire [BIT_WIDTH-1:0] uz_mover;
wire [BIT_WIDTH-1:0] sz_mover;
wire [BIT_WIDTH-1:0] sr_mover;
wire [BIT_WIDTH-1:0] sleftz_mover;
wire [BIT_WIDTH-1:0] sleftr_mover;
wire [LAYER_WIDTH-1:0] layer_mover;
wire [BIT_WIDTH-1:0] weight_mover;
wire dead_mover;

/*boundary checker outputs*/
wire [BIT_WIDTH-1:0] x_boundaryChecker;
wire [BIT_WIDTH-1:0] y_boundaryChecker;
wire [BIT_WIDTH-1:0] z_boundaryChecker;
wire [BIT_WIDTH-1:0] ux_boundaryChecker;
wire [BIT_WIDTH-1:0] uy_boundaryChecker;
wire [BIT_WIDTH-1:0] uz_boundaryChecker;
wire [BIT_WIDTH-1:0] sz_boundaryChecker;
wire [BIT_WIDTH-1:0] sr_boundaryChecker;
wire [BIT_WIDTH-1:0] sleftz_boundaryChecker;
wire [BIT_WIDTH-1:0] sleftr_boundaryChecker;
wire [LAYER_WIDTH-1:0] layer_boundaryChecker;
wire [BIT_WIDTH-1:0] weight_boundaryChecker;
wire dead_boundaryChecker;
wire hit_boundaryChecker;

/*hop outputs*/
wire [BIT_WIDTH-1:0] x_hop;
wire [BIT_WIDTH-1:0] y_hop;
wire [BIT_WIDTH-1:0] z_hop;
wire [BIT_WIDTH-1:0] ux_hop;
wire [BIT_WIDTH-1:0] uy_hop;
wire [BIT_WIDTH-1:0] uz_hop;
wire [BIT_WIDTH-1:0] sz_hop;
wire [BIT_WIDTH-1:0] sr_hop;
wire [BIT_WIDTH-1:0] sleftz_hop;
wire [BIT_WIDTH-1:0] sleftr_hop;
wire [LAYER_WIDTH-1:0] layer_hop;
wire [BIT_WIDTH-1:0] weight_hop;
wire dead_hop;
wire hit_hop;

/*Drop spin outputs*/
wire [BIT_WIDTH-1:0] x_dropSpin;
wire [BIT_WIDTH-1:0] y_dropSpin;
wire [BIT_WIDTH-1:0] z_dropSpin;
wire [BIT_WIDTH-1:0] ux_dropSpin;
wire [BIT_WIDTH-1:0] uy_dropSpin;
wire [BIT_WIDTH-1:0] uz_dropSpin;
wire [BIT_WIDTH-1:0] sz_dropSpin;
wire [BIT_WIDTH-1:0] sr_dropSpin;
wire [BIT_WIDTH-1:0] sleftz_dropSpin;
wire [BIT_WIDTH-1:0] sleftr_dropSpin;
wire [LAYER_WIDTH-1:0] layer_dropSpin;
wire [BIT_WIDTH-1:0] weight_dropSpin;
wire dead_dropSpin;

/*Dead or Alive outputs*/
wire [BIT_WIDTH-1:0] x_Roulette;
wire [BIT_WIDTH-1:0] y_Roulette;
wire [BIT_WIDTH-1:0] z_Roulette;
wire [BIT_WIDTH-1:0] ux_Roulette;
wire [BIT_WIDTH-1:0] uy_Roulette;
wire [BIT_WIDTH-1:0] uz_Roulette;
wire [BIT_WIDTH-1:0] sz_Roulette;
wire [BIT_WIDTH-1:0] sr_Roulette;
wire [BIT_WIDTH-1:0] sleftz_Roulette;
wire [BIT_WIDTH-1:0] sleftr_Roulette;
wire [LAYER_WIDTH-1:0] layer_Roulette;
wire [BIT_WIDTH-1:0] weight_Roulette;
wire dead_Roulette;

// internals
wire [BIT_WIDTH-1:0] rand1, rand2, rand3, rand4, rand5;
wire [BIT_WIDTH-1:0] logrand;

// Combinational Drivers
reg [BIT_WIDTH-1:0] c_num_photons_left;
reg [BIT_WIDTH-1:0] c_counter;
reg c_done;

// Registered Drivers
reg r_done;
reg loadseed;
reg delay_loadseed;


reg [BIT_WIDTH-1:0] r_num_photons_left;
reg [BIT_WIDTH-1:0] r_counter;

assign done = r_done;

// Connect blocks
LogCalc log_u1(.clock(clock), .reset(reset), .enable(1'b1), .in_x(rand1), .log_x(logrand));
rng rand_u1(.clk(clock), .en(1'b1), .resetn(~reset), .loadseed_i(loadseed), .seed_i(randseed1), .number_o(rand1));
rng rand_u2(.clk(clock), .en(1'b1), .resetn(~reset), .loadseed_i(loadseed), .seed_i(randseed2), .number_o(rand2));
rng rand_u3(.clk(clock), .en(1'b1), .resetn(~reset), .loadseed_i(loadseed), .seed_i(randseed3), .number_o(rand3));
rng rand_u4(.clk(clock), .en(1'b1), .resetn(~reset), .loadseed_i(loadseed), .seed_i(randseed4), .number_o(rand4));
rng rand_u5(.clk(clock), .en(1'b1), .resetn(~reset), .loadseed_i(loadseed), .seed_i(randseed5), .number_o(rand5));

Move mover(		 .clock(clock), .reset(reset), .enable(enable),
				 .x_moverMux(x_moverMux), .y_moverMux(y_moverMux), .z_moverMux(z_moverMux),
				 .ux_moverMux(ux_moverMux), .uy_moverMux(uy_moverMux), .uz_moverMux(uz_moverMux),
				 .sz_moverMux(sz_moverMux), .sr_moverMux(sr_moverMux),
				 .sleftz_moverMux(sleftz_moverMux), .sleftr_moverMux(sleftr_moverMux),
				 .layer_moverMux(layer_moverMux), .weight_moverMux(weight_moverMux), .dead_moverMux(dead_moverMux),

				 .log_rand_num(logrand),

				 //OUTPUTS
				 .x_mover(x_mover), .y_mover(y_mover), .z_mover(z_mover),
				 .ux_mover(ux_mover), .uy_mover(uy_mover), .uz_mover(uz_mover),
				 .sz_mover(sz_mover), .sr_mover(sr_mover),
				 .sleftz_mover(sleftz_mover), .sleftr_mover(sleftr_mover),
				 .layer_mover(layer_mover), .weight_mover(weight_mover), .dead_mover(dead_mover),

				 // CONSTANTS
				 .OneOver_MutMaxrad_0(OneOver_MutMaxrad_0), .OneOver_MutMaxrad_1(OneOver_MutMaxrad_1), .OneOver_MutMaxrad_2(OneOver_MutMaxrad_2), .OneOver_MutMaxrad_3(OneOver_MutMaxrad_3), .OneOver_MutMaxrad_4(OneOver_MutMaxrad_4), .OneOver_MutMaxrad_5(OneOver_MutMaxrad_5),
				 .OneOver_MutMaxdep_0(OneOver_MutMaxdep_0), .OneOver_MutMaxdep_1(OneOver_MutMaxdep_1), .OneOver_MutMaxdep_2(OneOver_MutMaxdep_2), .OneOver_MutMaxdep_3(OneOver_MutMaxdep_3), .OneOver_MutMaxdep_4(OneOver_MutMaxdep_4), .OneOver_MutMaxdep_5(OneOver_MutMaxdep_5),
				 .OneOver_Mut_0(OneOver_Mut_0), .OneOver_Mut_1(OneOver_Mut_1), .OneOver_Mut_2(OneOver_Mut_2), .OneOver_Mut_3(OneOver_Mut_3), .OneOver_Mut_4(OneOver_Mut_4), .OneOver_Mut_5(OneOver_Mut_5)
		);

Boundary boundaryChecker ( //INPUTS
				 .clock(clock), .reset(reset), .enable(enable),
				 .x_mover(x_mover), .y_mover(y_mover), .z_mover(z_mover),
				 .ux_mover(ux_mover), .uy_mover(uy_mover), .uz_mover(uz_mover),
				 .sz_mover(sz_mover), .sr_mover(sr_mover),
				 .sleftz_mover(sleftz_mover), .sleftr_mover(sleftr_mover),
				 .layer_mover(layer_mover), .weight_mover(weight_mover), .dead_mover(dead_mover),

				 //OUTPUTS
				 .x_boundaryChecker(x_boundaryChecker), .y_boundaryChecker(y_boundaryChecker), .z_boundaryChecker(z_boundaryChecker),
				 .ux_boundaryChecker(ux_boundaryChecker), .uy_boundaryChecker(uy_boundaryChecker), .uz_boundaryChecker(uz_boundaryChecker),
				 .sz_boundaryChecker(sz_boundaryChecker), .sr_boundaryChecker(sr_boundaryChecker),
				 .sleftz_boundaryChecker(sleftz_boundaryChecker), .sleftr_boundaryChecker(sleftr_boundaryChecker),
				 .layer_boundaryChecker(layer_boundaryChecker), .weight_boundaryChecker(weight_boundaryChecker), .dead_boundaryChecker(dead_boundaryChecker), .hit_boundaryChecker(hit_boundaryChecker),

				 //CONSTANTS
				 .z1_0(z1_0), .z1_1(z1_1), .z1_2(z1_2), .z1_3(z1_3), .z1_4(z1_4), .z1_5(z1_5),
				 .z0_0(z0_0), .z0_1(z0_1), .z0_2(z0_2), .z0_3(z0_3), .z0_4(z0_4), .z0_5(z0_5),
				 .mut_0(mut_0), .mut_1(mut_1), .mut_2(mut_2), .mut_3(mut_3), .mut_4(mut_4), .mut_5(mut_5),
				 .maxDepth_over_maxRadius(maxDepth_over_maxRadius)
				 );

Hop hopper (     //INPUTS
				 .clock(clock), .reset(reset), .enable(enable),
				 .x_boundaryChecker(x_boundaryChecker), .y_boundaryChecker(y_boundaryChecker), .z_boundaryChecker(z_boundaryChecker),
				 .ux_boundaryChecker(ux_boundaryChecker), .uy_boundaryChecker(uy_boundaryChecker), .uz_boundaryChecker(uz_boundaryChecker),
				 .sz_boundaryChecker(sz_boundaryChecker), .sr_boundaryChecker(sr_boundaryChecker),
				 .sleftz_boundaryChecker(sleftz_boundaryChecker), .sleftr_boundaryChecker(sleftr_boundaryChecker),
				 .layer_boundaryChecker(layer_boundaryChecker), .weight_boundaryChecker(weight_boundaryChecker), .dead_boundaryChecker(dead_boundaryChecker),
				 .hit_boundaryChecker(hit_boundaryChecker),

				 //OUTPUTS
				 .x_hop(x_hop), .y_hop(y_hop), .z_hop(z_hop),
				 .ux_hop(ux_hop), .uy_hop(uy_hop), .uz_hop(uz_hop),
				 .sz_hop(sz_hop), .sr_hop(sr_hop),
				 .sleftz_hop(sleftz_hop), .sleftr_hop(sleftr_hop),
				 .layer_hop(layer_hop), .weight_hop(weight_hop), .dead_hop(dead_hop), .hit_hop(hit_hop)
				 );

Roulette Roulette ( //INPUTS
                     .clock(clock), .reset(reset), .enable(enable),
                     .x_RouletteMux(x_dropSpin), .y_RouletteMux(y_dropSpin), .z_RouletteMux(z_dropSpin),
                     .ux_RouletteMux(ux_dropSpin), .uy_RouletteMux(uy_dropSpin), .uz_RouletteMux(uz_dropSpin),
                     .sz_RouletteMux(sz_dropSpin), .sr_RouletteMux(sr_dropSpin),
                     .sleftz_RouletteMux(sleftz_dropSpin), .sleftr_RouletteMux(sleftr_dropSpin),
                     .layer_RouletteMux(layer_dropSpin), .weight_absorber(weight_dropSpin), .dead_RouletteMux(dead_dropSpin),
					 .randnumber(rand4),

                     //OUTPUTS
                     .x_Roulette(x_Roulette), .y_Roulette(y_Roulette), .z_Roulette(z_Roulette),
                     .ux_Roulette(ux_Roulette), .uy_Roulette(uy_Roulette), .uz_Roulette(uz_Roulette),
                     .sz_Roulette(sz_Roulette), .sr_Roulette(sr_Roulette),
                     .sleftz_Roulette(sleftz_Roulette), .sleftr_Roulette(sleftr_Roulette),
                     .layer_Roulette(layer_Roulette), .weight_Roulette(weight_Roulette), .dead_Roulette(dead_Roulette)
					 );


DropSpinWrapper dropSpin (
	.clock(clock), .reset(reset), .enable(enable),

   //From Hopper Module
    .i_x(x_hop),
	.i_y(y_hop),
	.i_z(z_hop),
	.i_ux(ux_hop),
	.i_uy(uy_hop),
	.i_uz(uz_hop),
	.i_sz(sz_hop),
	.i_sr(sr_hop),
	.i_sleftz(sleftz_hop),
	.i_sleftr(sleftr_hop),
	.i_weight(weight_hop),
	.i_layer(layer_hop),
	.i_dead(dead_hop),
	.i_hit(hit_hop),	
	
	//From System Register File (5 layers)- Absorber
	.muaFraction1(muaFraction1), .muaFraction2(muaFraction2), .muaFraction3(muaFraction3), .muaFraction4(muaFraction4), .muaFraction5(muaFraction5),
 
 	//From System Register File - ScattererReflector 
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
 
	//Generated by random number generators controlled by skeleton
	.up_rFresnel(up_rFresnel),
	.down_rFresnel(down_rFresnel),
	.sint(sint),
	.cost(cost),
	.rand2(rand2),
	.rand3(rand3),
	.rand5(rand5),
	//To Memories
	.tindex(tindex),
	.fresIndex(fresIndex),

	// port to memory
	 .data(absorb_data), .rdaddress(absorb_rdaddress), .wraddress(absorb_wraddress), 
	 .wren(absorb_wren), .q(absorb_q),
	 
   //To Roulette Module
	.o_x(x_dropSpin),
	.o_y(y_dropSpin),
	.o_z(z_dropSpin),
	.o_ux(ux_dropSpin),
	.o_uy(uy_dropSpin),
	.o_uz(uz_dropSpin),
	.o_sz(sz_dropSpin),
	.o_sr(sr_dropSpin),
	.o_sleftz(sleftz_dropSpin),
	.o_sleftr(sleftr_dropSpin),
	.o_weight(weight_dropSpin),
	.o_layer(layer_dropSpin),
	.o_dead(dead_dropSpin),
	.o_hit(hit_dropSpin)
                    
	);


// Determine how many photons left
always @(*)
begin
	c_num_photons_left = r_num_photons_left;
	c_counter = 0;

	if(dead_Roulette == 1'b1 && r_done == 1'b0)
	begin
		if(r_num_photons_left > 0)
		begin
			c_num_photons_left = r_num_photons_left - 1;
		end
		else
		begin
			c_counter = r_counter + 1;
		end
	end
end

// Only state info is done
always @(*)
begin
	c_done = r_done;
	if(r_counter > PIPELINE_DEPTH_UPPER_LIMIT)
	begin
		c_done = 1'b1;
	end
end

// Create mux to mover
always @(*)
begin
	if(dead_Roulette)
	begin
		x_moverMux = 0;
		y_moverMux = 0;
		z_moverMux = 0;
		ux_moverMux = 0;
		uy_moverMux = 0;
		uz_moverMux = 32'h7fffffff;
		sz_moverMux = 0;
		sr_moverMux = 0;
		sleftz_moverMux = 0;
		sleftr_moverMux = 0;
		layer_moverMux = 3'b01;
		weight_moverMux = initialWeight;
		if(r_num_photons_left > 0)
		begin
			dead_moverMux = 1'b0;
		end
		else
		begin
			dead_moverMux = 1'b1;
		end
	end
	else
	begin
		x_moverMux = x_Roulette;
		y_moverMux = y_Roulette;
		z_moverMux = z_Roulette;
		ux_moverMux = ux_Roulette;
		uy_moverMux = uy_Roulette;
		uz_moverMux = uz_Roulette;
		sz_moverMux = sz_Roulette;
		sr_moverMux = sr_Roulette;
		sleftz_moverMux = sleftz_Roulette;
		sleftr_moverMux = sleftr_Roulette;
		layer_moverMux = layer_Roulette;
		weight_moverMux = weight_Roulette;
		dead_moverMux = dead_Roulette;
	end
end

// register state
always @(posedge clock)
begin
	if(reset)
	begin
		r_num_photons_left <= total_photons;
		r_counter <= 0;
		r_done <= 1'b0;
		delay_loadseed <= 1'b1;
		loadseed <= 1'b1;
	end
	else
	begin
		if(enable)
		begin
			r_num_photons_left <= c_num_photons_left;
			r_counter <= c_counter;
			r_done <= c_done;
			delay_loadseed <= 1'b0;
			loadseed <= delay_loadseed;
		end
	end
end

endmodule
