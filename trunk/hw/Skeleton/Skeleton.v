// Skeleton
// Reads constants and instantiates all modules used by the hardware components


module Skeleton (
	reset,
	clk,	

	constants,
	read_constants,

	result, 
	inc_result,

	calc_in_progress
	);

// Total number of constants
parameter LAST_CONSTANT = 105;
parameter NUM_FRESNELS = 128;
parameter NUM_TRIG_ELS = 1024;
parameter ABSORB_ADDR_WIDTH=16;
parameter ABSORB_WORD_WIDTH=64;
parameter BIT_WIDTH = 32;

input				reset;
input				clk;
input [31:0]		constants;
input				read_constants;
input				inc_result;

output				calc_in_progress;
output [31:0]		result;
reg					calc_in_progress;
reg [31:0]			result;


integer i;

wire [31:0] mem_fres_up, mem_fres_down, mem_sint, mem_cost;

// photon calculator

wire reset;

// Scatterer Reflector memory look-up
wire [12:0] tindex;
wire [9:0] fresIndex;

//   DeadOrAlive Module (nothing)

// Final results
wire [ABSORB_ADDR_WIDTH-1:0] absorb_rdaddress, absorb_wraddress;
wire absorb_wren;
wire [ABSORB_WORD_WIDTH-1:0] absorb_data;
wire [ABSORB_WORD_WIDTH-1:0] absorb_q;

// Flag when final results ready
wire done;
reg enable;
reg reset_calculator;

// Combinational drivers
reg [31:0]			c_const[LAST_CONSTANT - 1:0];
reg [12:0]			c_counter;
reg	c_toggle;

reg [ABSORB_ADDR_WIDTH-1:0] c_absorb_read_counter, c_absorb_write_counter;
reg [ABSORB_ADDR_WIDTH-1:0] absorb_rdaddress_mux, absorb_wraddress_mux;
reg [ABSORB_WORD_WIDTH-1:0] absorb_data_mux;
reg absorb_wren_mux;

reg [3:0]			c_state;

reg [31:0]			c_result;
reg					c_calc_in_progress;

reg wren_fres_up, wren_fres_down, wren_sinp, wren_cosp, wren_sint, wren_cost;
reg [2:0] mem_layer;

// Registered drivers
reg [31:0]			r_const[LAST_CONSTANT - 1:0];
reg [12:0]			r_counter;
reg [ABSORB_ADDR_WIDTH-1:0] r_absorb_read_counter;
reg [ABSORB_ADDR_WIDTH-1:0] r_absorb_write_counter;
reg [3:0]			r_state;
reg	r_toggle;

// Skeleton program states
parameter [3:0] ERROR_ST = 4'b0000, 
				READ1_ST = 4'b0001, 
				READ2_ST = 4'b0010, 
				READ3_ST = 4'b0011, 
				READ4_ST = 4'b0100, 
				READ5_ST = 4'b0101, 
				RESET_MEM_ST = 4'b0110,
				CALC_ST = 4'b1000, 
				DONE1_ST = 4'b1001, 
				DONE2_ST = 4'b1010, 
				DONE3_ST = 4'b1011, 
				DONE4_ST = 4'b1100, 
				DONE5_ST = 4'b1101, 
				DONE6_ST = 4'b1110;

// Instantiate lookup memories
dual_port_mem u_fres_up(clk, constants, {3'b0, fresIndex}, {3'b0, mem_layer, r_counter[6:0]}, wren_fres_up, mem_fres_up);
dual_port_mem u_fres_down(clk, constants, {3'b0, fresIndex}, {3'b0, mem_layer, r_counter[6:0]}, wren_fres_down, mem_fres_down);
dual_port_mem u_sint(clk, constants, tindex, {mem_layer, r_counter[9:0]}, wren_sint, mem_sint);
dual_port_mem u_cost(clk, constants, tindex, {mem_layer, r_counter[9:0]}, wren_cost, mem_cost);

// Reduce size of absorption matrix
dual absorptionMatrix(   .clock (clk), .data(absorb_data_mux[35:0]), 
                         .rdaddress(absorb_rdaddress_mux), .wraddress(absorb_wraddress_mux), 
                         .wren(absorb_wren_mux), .q(absorb_q[35:0]));
dual2 absorptionMatrix2(   .clock (clk), .data(absorb_data_mux[53:36]), 
                         .rdaddress(absorb_rdaddress_mux), .wraddress(absorb_wraddress_mux), 
                         .wren(absorb_wren_mux), .q(absorb_q[53:36]));
dual3 absorptionMatrix3(   .clock (clk), .data(absorb_data_mux[61:54]), 
                         .rdaddress(absorb_rdaddress_mux), .wraddress(absorb_wraddress_mux), 
                         .wren(absorb_wren_mux), .q(absorb_q[61:54]));

PhotonCalculator u_calc (
	.clock(clk), .reset(reset_calculator), .enable(enable),

	// CONSTANTS
	.total_photons(r_const[0]),
	
	.randseed1(r_const[19]), .randseed2(r_const[20]), .randseed3(r_const[21]), .randseed4(r_const[22]), .randseed5(r_const[23]),
	
	.initialWeight(r_const[104]),

	//   Mover
	.OneOver_MutMaxrad_0(r_const[32]), .OneOver_MutMaxrad_1(r_const[33]), .OneOver_MutMaxrad_2(r_const[34]), .OneOver_MutMaxrad_3(r_const[35]), .OneOver_MutMaxrad_4(r_const[36]), .OneOver_MutMaxrad_5(r_const[37]),
	.OneOver_MutMaxdep_0(r_const[38]), .OneOver_MutMaxdep_1(r_const[39]), .OneOver_MutMaxdep_2(r_const[40]), .OneOver_MutMaxdep_3(r_const[41]), .OneOver_MutMaxdep_4(r_const[42]), .OneOver_MutMaxdep_5(r_const[43]),
	.OneOver_Mut_0(r_const[26]), .OneOver_Mut_1(r_const[27]), .OneOver_Mut_2(r_const[28]), .OneOver_Mut_3(r_const[29]), .OneOver_Mut_4(r_const[30]), .OneOver_Mut_5(r_const[31]),

	//   BoundaryChecker
	.z1_0(r_const[50]), .z1_1(r_const[51]), .z1_2(r_const[52]), .z1_3(r_const[53]), .z1_4(r_const[54]), .z1_5(r_const[55]),
	.z0_0(r_const[44]), .z0_1(r_const[45]), .z0_2(r_const[46]), .z0_3(r_const[47]), .z0_4(r_const[48]), .z0_5(r_const[49]),
	.mut_0(32'b0), .mut_1(r_const[2]), .mut_2(r_const[3]), .mut_3(r_const[4]), .mut_4(r_const[5]), .mut_5(r_const[6]),
	.maxDepth_over_maxRadius(r_const[1]),

	//   Hop (no constants)

	//   Scatterer Reflector Wrapper
	.down_niOverNt_1(r_const[69]), .down_niOverNt_2(r_const[70]), .down_niOverNt_3(r_const[71]), .down_niOverNt_4(r_const[72]), .down_niOverNt_5(r_const[73]),
	.up_niOverNt_1(r_const[75]), .up_niOverNt_2(r_const[76]), .up_niOverNt_3(r_const[77]), .up_niOverNt_4(r_const[78]), .up_niOverNt_5(r_const[79]),
	.down_niOverNt_2_1({r_const[81],r_const[87]}), .down_niOverNt_2_2({r_const[82],r_const[88]}), .down_niOverNt_2_3({r_const[83],r_const[89]}), .down_niOverNt_2_4({r_const[84],r_const[90]}), .down_niOverNt_2_5({r_const[85],r_const[91]}),
	.up_niOverNt_2_1({r_const[93],r_const[99]}), .up_niOverNt_2_2({r_const[94],r_const[100]}), .up_niOverNt_2_3({r_const[95],r_const[101]}), .up_niOverNt_2_4({r_const[96],r_const[102]}), .up_niOverNt_2_5({r_const[97],r_const[103]}),
	.downCritAngle_0(r_const[7]), .downCritAngle_1(r_const[8]), .downCritAngle_2(r_const[9]), .downCritAngle_3(r_const[10]), .downCritAngle_4(r_const[11]),
	.upCritAngle_0(r_const[13]), .upCritAngle_1(r_const[14]), .upCritAngle_2(r_const[15]), .upCritAngle_3(r_const[16]), .upCritAngle_4(r_const[17]),
	.muaFraction1(r_const[57]), .muaFraction2(r_const[58]), .muaFraction3(r_const[59]), .muaFraction4(r_const[60]), .muaFraction5(r_const[61]),
	  // Interface to memory look-up
	    // From Memories
	.up_rFresnel(mem_fres_up), .down_rFresnel(mem_fres_down), .sint(mem_sint), .cost(mem_cost),
		// To Memories
	.tindex(tindex), .fresIndex(fresIndex),

	// DeadOrAlive (no Constants)

	// Absorber
	.absorb_data(absorb_data), .absorb_rdaddress(absorb_rdaddress), .absorb_wraddress(absorb_wraddress), 
	.absorb_wren(absorb_wren), .absorb_q(absorb_q),

	// Done signal
	.done(done)
	);

// Mux to read the absorbtion array
always @(*)
begin
	if(r_state == RESET_MEM_ST)
	begin
		absorb_wren_mux = 1'b1;
		absorb_data_mux = 64'b0;
		absorb_rdaddress_mux = r_absorb_read_counter;
		absorb_wraddress_mux = r_absorb_write_counter;
	end
	else if(done == 1'b1)
	begin
		absorb_rdaddress_mux = r_absorb_read_counter;
		absorb_wraddress_mux = absorb_wraddress;
		absorb_data_mux = absorb_data;
		absorb_wren_mux = 1'b0;
	end
	else
	begin
		absorb_rdaddress_mux = absorb_rdaddress;
		absorb_wraddress_mux = absorb_wraddress;
		absorb_data_mux = absorb_data;
		absorb_wren_mux = absorb_wren;
	end
end

// Skeleton SW/HW interface
//  1.  Read constants
//  2.  Wait for completion
//  3.  Write data back
always @(*)
	begin : FSM
		// Initialize data
		for(i = 0; i < LAST_CONSTANT; i = i + 1) begin
			c_const[i] = r_const[i];
		end
		c_counter = r_counter;
		c_absorb_read_counter = r_absorb_read_counter;
		c_result = result;
		c_calc_in_progress = 1'b0;
		c_state = r_state;
		wren_fres_up = 1'b0;
		wren_fres_down = 1'b0;
		wren_sint = 1'b0;
		wren_cost = 1'b0;
		c_absorb_write_counter = r_absorb_write_counter;
		c_toggle = r_toggle;
		
		mem_layer = r_counter[12:10];

		// Determine next state and which data changes
		case(r_state)
			ERROR_ST:
				begin
				end
			READ1_ST:
				begin			
					if(read_constants)
						begin
							c_const[r_counter] = constants;
							c_counter = r_counter + 13'b01;
						end
					else
						begin
							if(c_counter >= LAST_CONSTANT) 
								begin
									c_counter = 13'b0;
									c_state = READ2_ST;
								end
						end
				end
			READ2_ST:
				begin		
					mem_layer = r_counter[9:7];
					if(read_constants)
						begin
							wren_fres_up = 1'b1;
							c_counter = r_counter + 13'b01;
						end
					else
						begin
							if(c_counter >= 5*NUM_FRESNELS) 
								begin
									c_counter = 13'b0;
									c_state = READ3_ST;
								end
						end
				end
			READ3_ST:
				begin
					mem_layer = r_counter[9:7];
					if(read_constants)
						begin
							wren_fres_down = 1'b1;
							c_counter = r_counter + 13'b01;
						end
					else
						begin
							if(c_counter >= 5*NUM_FRESNELS) 
								begin
									c_counter = 13'b0;
									c_state = READ4_ST;
								end
						end
				end
			READ4_ST:
				begin
					
					if(read_constants)
						begin
							wren_cost = 1'b1;
							c_counter = r_counter + 13'b01;
						end
					else
						begin
							if(c_counter >= 5*NUM_TRIG_ELS) 
								begin
									c_counter = 13'b0;
									c_state = READ5_ST;
								end
						end
				end
			READ5_ST:
				begin			
					
					if(read_constants)
						begin
							wren_sint = 1'b1;
							c_counter = r_counter + 13'b01;
						end
					else
						begin
							if(c_counter >= 5*NUM_TRIG_ELS) 
								begin
									c_counter = 13'b0;
									c_absorb_read_counter = 13'b0;
									c_state = RESET_MEM_ST;
								end
						end
				end
			RESET_MEM_ST:
				begin
				    c_toggle = 1'b0;
					c_calc_in_progress = 1'b1;
					c_absorb_write_counter = r_absorb_write_counter + 16'b01;
					if(r_absorb_write_counter == 16'hFFFF)
					begin
						c_state = CALC_ST;
					end
				end
			CALC_ST:
				begin
					if(done == 1'b0)
						begin
							c_calc_in_progress = 1'b1;
							c_toggle = 1'b0;
						end
					else
						begin
							c_toggle = 1'b0;
							c_calc_in_progress = 1'b0;
							c_state = DONE6_ST;
							c_counter = 13'b0;
						end
				end
		// DEBUG STATES BEGIN
			DONE1_ST:
				begin
					c_result = {32'b0,r_const[r_counter]};
					if(inc_result)
						begin
							c_counter = r_counter + 13'b01;
						end
					c_state = DONE1_ST;
					if(c_counter >= LAST_CONSTANT) 
						begin
							c_counter = 13'b0;
							c_state = DONE2_ST;
						end
				end
			DONE2_ST:
				begin
					mem_layer = r_counter[9:7];
					//c_result = {32'b0,mem_fres_up};
					c_result = {32'b0,32'b0};
					if(inc_result)
						begin
							// stub, write constants back to see if read in properly
							c_counter = r_counter + 13'b01;
						end
					c_state = DONE2_ST;
					if(c_counter >= 5*NUM_FRESNELS) 
						begin
							c_counter = 13'b0;
							c_state = DONE3_ST;
						end
				end
			DONE3_ST:
				begin
					mem_layer = r_counter[9:7];
					//c_result = {32'b0,mem_fres_down};
					c_result = {32'b0,32'b0};
					if(inc_result)
						begin
							// stub, write constants back to see if read in properly
							c_counter = r_counter + 13'b01;
						end
					c_state = DONE3_ST;
					if(c_counter >= 5*NUM_FRESNELS) 
						begin
							c_counter = 13'b0;
							c_state = DONE4_ST;
						end
				end
			DONE4_ST:
				begin
					c_result = {32'b0,mem_cost};
					if(inc_result)
						begin
							// stub, write constants back to see if read in properly
							c_counter = r_counter + 13'b01;
						end
					c_state = DONE4_ST;
					if(c_counter >= 5*NUM_TRIG_ELS) 
						begin
							c_counter = 13'b0;
							c_state = DONE5_ST;
						end
				end
			DONE5_ST:
				begin
					c_result = {32'b0,mem_sint};
					if(inc_result)
						begin
							// stub, write constants back to see if read in properly
							c_counter = r_counter + 13'b01;
						end
					c_state = DONE5_ST;
					if(c_counter >= 5*NUM_TRIG_ELS) 
						begin
							c_counter = 13'b0;
							c_state = DONE6_ST;
						end
				end
			// DEBUG STATES END
			DONE6_ST:
				begin
					if(r_toggle == 1'b0)
						c_result = absorb_q[63:32];
					else
						c_result = absorb_q[31:0];
					if(inc_result)
						begin
							if(r_toggle == 1'b0)
							begin
								c_toggle = 1'b1;
							end
							else
							begin
								c_toggle = 1'b0;
								c_absorb_read_counter = r_absorb_read_counter + 16'b01;
							end
						end
					c_state = DONE6_ST;
				end
			default:
				begin
					c_state = ERROR_ST;
				end
		endcase
	end // FSM always



// Latch Data
always @(posedge clk)
	begin
		if(reset)
			begin
				r_counter <= 13'b0;
				for(i = 0; i < LAST_CONSTANT; i = i + 1) begin
					r_const[i] <= 32'b0;
				end
				r_state <= READ1_ST;
				result <= 32'b0;
				calc_in_progress <= 1'b0;
				r_absorb_read_counter <= 16'b0;
				enable <= 1'b0;
				r_absorb_write_counter <= 16'b0;
				reset_calculator <= 1'b1;
				r_toggle <= 1'b0;
			end
		else
			begin
				r_counter <= c_counter;
				for(i = 0; i < LAST_CONSTANT; i = i + 1) begin
					r_const[i] <= c_const[i];
				end

				r_state <= c_state;
				result <= c_result;
				calc_in_progress <= c_calc_in_progress;
				r_absorb_read_counter <= c_absorb_read_counter;
				r_absorb_write_counter <= c_absorb_write_counter;
				r_toggle <= c_toggle;
				//if(c_state == CALC_ST) 
				//begin
					enable <= 1'b1;
				//end
				//else
				//begin
				//	enable = 1'b0;
				//end
				if(c_state == RESET_MEM_ST) 
				begin
					reset_calculator <= 1'b1;
				end
				else
				begin
					reset_calculator <= 1'b0;
				end
			end
	end

endmodule
			
