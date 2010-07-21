//////////////////////////////////////////////////////////////////////
////  DropSpinWrapper Module                                      ////
////                                                              ////
////  Description:                                                ////
////  Wraps everything in Drop, Spin                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

module DropSpinWrapper (
	clock, reset, enable,

   //From Hopper Module
   i_x,
	i_y,
	i_z,
	i_ux,
	i_uy,
	i_uz,
	i_sz,
	i_sr,
	i_sleftz,
	i_sleftr,
	i_weight,
	i_layer,
	i_dead,
	i_hit,
	
	
	//From System Register File (5 layers)- Absorber
	muaFraction1, muaFraction2, muaFraction3, muaFraction4, muaFraction5, 
 
 	//From System Register File - ScattererReflector 
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
 
	
 	
 	//////////////////////////////////////////////////////////////////////////////
   //I/O to on-chip mem
   /////////////////////////////////////////////////////////////////////////////

   data, 
   rdaddress, wraddress,
   wren, q,

   //From Memories
   up_rFresnel,
   down_rFresnel,
   sint,
   cost,
   rand2,
   rand3,
   rand5,
   //To Memories
   tindex,
   fresIndex,

 	
   //To DeadOrAlive Module
	o_x,
	o_y,
	o_z,
	o_ux,
	o_uy,
	o_uz,
	o_sz,
	o_sr,
	o_sleftz,
	o_sleftr,
	o_weight,
	o_layer,
	o_dead,
	o_hit
                    
	);
	
//////////////////////////////////////////////////////////////////////////////
//PARAMETERS
//////////////////////////////////////////////////////////////////////////////	
parameter BIT_WIDTH=32;
parameter LAYER_WIDTH=3;
parameter PIPE_DEPTH = 37;
parameter ADDR_WIDTH=16;          //TODO: TBD
parameter WORD_WIDTH=64;

//////////////////////////////////////////////////////////////////////////////
//INPUTS
//////////////////////////////////////////////////////////////////////////////
input clock, reset, enable;

//From Hopper Module
input	[BIT_WIDTH-1:0]			i_x;
input	[BIT_WIDTH-1:0]			i_y;
input	[BIT_WIDTH-1:0]			i_z;
input	[BIT_WIDTH-1:0]			i_ux;
input	[BIT_WIDTH-1:0]			i_uy;
input	[BIT_WIDTH-1:0]			i_uz;
input	[BIT_WIDTH-1:0]			i_sz;
input	[BIT_WIDTH-1:0]			i_sr;
input	[BIT_WIDTH-1:0]			i_sleftz;
input	[BIT_WIDTH-1:0]			i_sleftr;
input	[BIT_WIDTH-1:0]			i_weight;
input	[LAYER_WIDTH-1:0]		i_layer;
input					i_dead;
input					i_hit;


//From System Register File (5 layers)- Absorber
input	[BIT_WIDTH-1:0] muaFraction1, muaFraction2, muaFraction3, muaFraction4, muaFraction5; 

//From System Register File - ScattererReflector 
input	[BIT_WIDTH-1:0]	down_niOverNt_1;
input	[BIT_WIDTH-1:0]	down_niOverNt_2;
input	[BIT_WIDTH-1:0]	down_niOverNt_3;
input	[BIT_WIDTH-1:0]	down_niOverNt_4;
input	[BIT_WIDTH-1:0]	down_niOverNt_5;
input	[BIT_WIDTH-1:0]	up_niOverNt_1;
input	[BIT_WIDTH-1:0]	up_niOverNt_2;
input	[BIT_WIDTH-1:0]	up_niOverNt_3;
input	[BIT_WIDTH-1:0]	up_niOverNt_4;
input	[BIT_WIDTH-1:0]	up_niOverNt_5;
input	[WORD_WIDTH-1:0]	down_niOverNt_2_1;
input	[WORD_WIDTH-1:0]	down_niOverNt_2_2;
input	[WORD_WIDTH-1:0]	down_niOverNt_2_3;
input	[WORD_WIDTH-1:0]	down_niOverNt_2_4;
input	[WORD_WIDTH-1:0]	down_niOverNt_2_5;
input	[WORD_WIDTH-1:0]	up_niOverNt_2_1;
input	[WORD_WIDTH-1:0]	up_niOverNt_2_2;
input	[WORD_WIDTH-1:0]	up_niOverNt_2_3;
input	[WORD_WIDTH-1:0]	up_niOverNt_2_4;
input	[WORD_WIDTH-1:0]	up_niOverNt_2_5;
input	[BIT_WIDTH-1:0]	downCritAngle_0;
input	[BIT_WIDTH-1:0]	downCritAngle_1;
input	[BIT_WIDTH-1:0]	downCritAngle_2;
input	[BIT_WIDTH-1:0]	downCritAngle_3;
input	[BIT_WIDTH-1:0]	downCritAngle_4;
input	[BIT_WIDTH-1:0]	upCritAngle_0;
input	[BIT_WIDTH-1:0]	upCritAngle_1;
input	[BIT_WIDTH-1:0]	upCritAngle_2;
input	[BIT_WIDTH-1:0]	upCritAngle_3;
input	[BIT_WIDTH-1:0]	upCritAngle_4;

//Generated by random number generators controlled by skeleton
output	[12:0]		tindex;
output	[9:0]		fresIndex;


input	[31:0]		rand2;
input	[31:0]		rand3;
input	[31:0]		rand5;
input	[31:0]		sint;
input	[31:0]		cost;
input	[31:0]		up_rFresnel;
input	[31:0]		down_rFresnel;

 

//////////////////////////////////////////////////////////////////////////////
//OUTPUTS
/////////////////////////////////////////////////////////////////////////////
//To DeadOrAlive Module
output	[BIT_WIDTH-1:0]			o_x;
output	[BIT_WIDTH-1:0]			o_y;
output	[BIT_WIDTH-1:0]			o_z;
output	[BIT_WIDTH-1:0]			o_ux;
output	[BIT_WIDTH-1:0]			o_uy;
output	[BIT_WIDTH-1:0]			o_uz;
output	[BIT_WIDTH-1:0]			o_sz;
output	[BIT_WIDTH-1:0]			o_sr;
output	[BIT_WIDTH-1:0]			o_sleftz;
output	[BIT_WIDTH-1:0]			o_sleftr;
output	[BIT_WIDTH-1:0]			o_weight;
output	[LAYER_WIDTH-1:0]		o_layer;
output					o_dead;
output					o_hit;

wire	[BIT_WIDTH-1:0]			o_x;
wire	[BIT_WIDTH-1:0]			o_y;
wire	[BIT_WIDTH-1:0]			o_z;
reg	[BIT_WIDTH-1:0]			o_ux;
reg	[BIT_WIDTH-1:0]			o_uy;
reg	[BIT_WIDTH-1:0]			o_uz;
wire	[BIT_WIDTH-1:0]			o_sz;
wire	[BIT_WIDTH-1:0]			o_sr;
wire	[BIT_WIDTH-1:0]			o_sleftz;
wire	[BIT_WIDTH-1:0]			o_sleftr;
wire	[BIT_WIDTH-1:0]			o_weight;
reg	[LAYER_WIDTH-1:0]		o_layer;
reg					o_dead;
wire					o_hit;


//////////////////////////////////////////////////////////////////////////////
//I/O to on-chip mem
/////////////////////////////////////////////////////////////////////////////

output [WORD_WIDTH-1:0] data; 
output [ADDR_WIDTH-1:0] rdaddress, wraddress; 
output wren; 
input [WORD_WIDTH-1:0] q;


//////////////////////////////////////////////////////////////////////////////
//Generate SHARED REGISTER PIPELINE 
//////////////////////////////////////////////////////////////////////////////
//WIRES FOR CONNECTING REGISTERS
wire	[BIT_WIDTH-1:0]			x	[PIPE_DEPTH:0];
wire	[BIT_WIDTH-1:0]			y	[PIPE_DEPTH:0];
wire	[BIT_WIDTH-1:0]			z	[PIPE_DEPTH:0];
wire	[BIT_WIDTH-1:0]			ux	[PIPE_DEPTH:0];
wire	[BIT_WIDTH-1:0]			uy	[PIPE_DEPTH:0];
wire	[BIT_WIDTH-1:0]			uz	[PIPE_DEPTH:0];
wire	[BIT_WIDTH-1:0]			sz	[PIPE_DEPTH:0];
wire	[BIT_WIDTH-1:0]			sr	[PIPE_DEPTH:0];
wire	[BIT_WIDTH-1:0]			sleftz	[PIPE_DEPTH:0];
wire	[BIT_WIDTH-1:0]			sleftr	[PIPE_DEPTH:0];
wire	[BIT_WIDTH-1:0]			weight	[PIPE_DEPTH:0];
wire	[LAYER_WIDTH-1:0]		layer	[PIPE_DEPTH:0];
wire					dead	[PIPE_DEPTH:0];
wire					hit	[PIPE_DEPTH:0];

//ASSIGNMENTS FROM INPUTS TO PIPE
assign x[0] = i_x;
assign y[0] = i_y;
assign z[0] = i_z;
assign ux[0] = i_ux;
assign uy[0] = i_uy;
assign uz[0] = i_uz;
assign sz[0] = i_sz;
assign sr[0] = i_sr;
assign sleftz[0] = i_sleftz;
assign sleftr[0] = i_sleftr;
assign weight[0] = i_weight;
assign layer[0] = i_layer;
assign dead[0] = i_dead;
assign hit[0] = i_hit;

//ASSIGNMENTS FROM PIPE TO OUTPUT
//TODO: Assign outputs from the correct module 
assign o_x =x[PIPE_DEPTH];
assign o_y =y[PIPE_DEPTH];
assign o_z =z[PIPE_DEPTH];
//assign o_ux =ux[PIPE_DEPTH]; Assigned by deadOrAliveMux
//assign o_uy =uy[PIPE_DEPTH]; Assigned by deadOrAliveMux
//assign o_uz =uz[PIPE_DEPTH]; Assigned by deadOrAliveMux
assign o_sz =sz[PIPE_DEPTH];
assign o_sr =sr[PIPE_DEPTH];
assign o_sleftz =sleftz[PIPE_DEPTH];
assign o_sleftr =sleftr[PIPE_DEPTH];
//assign o_weight =weight[PIPE_DEPTH]; Assigned by absorber module (below)
//assign o_layer =layer[PIPE_DEPTH]; Assigned by deadOrAliveMux
//assign o_dead =dead[PIPE_DEPTH]; Assigned by deadOrAliveMux
assign o_hit =hit[PIPE_DEPTH];


//GENERATE PIPELINE
genvar i;
generate
	for(i=PIPE_DEPTH; i>0; i=i-1) begin: regPipe
		case(i)
		
		default:
		PhotonBlock5 photon(
			//Inputs
			.clock(clock),
			.reset(reset),
			.enable(enable),
			
			.i_x(x[i-1]),
			.i_y(y[i-1]),
			.i_z(z[i-1]),
			.i_ux(ux[i-1]),
			.i_uy(uy[i-1]),
			.i_uz(uz[i-1]),
			.i_sz(sz[i-1]),
			.i_sr(sr[i-1]),
			.i_sleftz(sleftz[i-1]),
			.i_sleftr(sleftr[i-1]),
			.i_weight(weight[i-1]),
			.i_layer(layer[i-1]),
			.i_dead(dead[i-1]),
			.i_hit(hit[i-1]),
			
			//Outputs			
			.o_x(x[i]),
			.o_y(y[i]),
			.o_z(z[i]),
			.o_ux(ux[i]),
			.o_uy(uy[i]),
			.o_uz(uz[i]),
			.o_sz(sz[i]),
			.o_sr(sr[i]),
			.o_sleftz(sleftz[i]),
			.o_sleftr(sleftr[i]),
			.o_weight(weight[i]),
			.o_layer(layer[i]),
			.o_dead(dead[i]),
			.o_hit(hit[i])
		);
		endcase
	end
endgenerate	

//////////////////////////////////////////////////////////////////////////////
//Tapping into the Registered Pipeline
//***NOTE: Index must be incremented by 1 compared to SystemC version 
//////////////////////////////////////////////////////////////////////////////

//>>>>>>>>>>>>> Absorber <<<<<<<<<<<<<<<<<<
wire	[BIT_WIDTH-1:0]			x_pipe, y_pipe,	z_pipe;
wire	[LAYER_WIDTH-1:0]			layer_pipe;
assign x_pipe=x[2]; 
assign y_pipe=y[2]; 
assign z_pipe=z[14];  //TODO: Check square-root latency and modify z[14] if needed!!!!
assign layer_pipe=layer[4];

//>>>>>>>>>>>>> ScattererReflectorWrapper <<<<<<<<<<<<<<<<<<
wire	[BIT_WIDTH-1:0]			ux_scatterer;
wire	[BIT_WIDTH-1:0]			uy_scatterer;
wire	[BIT_WIDTH-1:0]			uz_scatterer;
wire	[BIT_WIDTH-1:0]			ux_reflector;
wire	[BIT_WIDTH-1:0]			uy_reflector;
wire	[BIT_WIDTH-1:0]			uz_reflector;
wire	[LAYER_WIDTH-1:0]			layer_reflector;
wire					dead_reflector;




//////////////////////////////////////////////////////////////////////////////
//Connect up different modules
//////////////////////////////////////////////////////////////////////////////

//>>>>>>>>>>>>> Absorber <<<<<<<<<<<<<<<<<<

FluenceUpdate absorb (    //INPUTS
                     .clock(clock) , .reset(reset), .enable(enable), 
                     
                     //From hopper
                     .weight_hop(i_weight), .hit_hop(i_hit), .dead_hop(i_dead),

                     //From Shared Registers
                     .x_pipe (x_pipe), .y_pipe (y_pipe), .z_pipe(z_pipe), .layer_pipe(layer_pipe),
                     
                     //From System Register File (5 layers)
                     .muaFraction1(muaFraction1), .muaFraction2(muaFraction2), .muaFraction3(muaFraction3), .muaFraction4(muaFraction4), .muaFraction5(muaFraction5),  
                     
                     //Dual-port Mem
                     .data(data), .rdaddress(rdaddress), .wraddress(wraddress), 
                     .wren(wren), .q(q),
                     
                     //OUTPUT
                     .weight_absorber(o_weight)

                     ); 

//>>>>>>>>>>>>> ScattererReflectorWrapper <<<<<<<<<<<<<<<<<<

ScattererReflectorWrapper scattererReflector(
	//Inputs
	.clock(clock),
	.reset(reset),
	.enable(enable),
		//Inputs
		
		//Photon values
		.i_uz1_pipeWrapper(uz[1]),
		.i_hit2_pipeWrapper(hit[1]),
		.i_ux3_pipeWrapper(ux[3]),
		.i_uz3_pipeWrapper(uz[3]),
		.i_layer3_pipeWrapper(layer[3]),
		.i_hit4_pipeWrapper(hit[3]),
		.i_hit6_pipeWrapper(hit[5]),
		.i_hit16_pipeWrapper(hit[15]),
		.i_layer31_pipeWrapper(layer[31]),
		.i_uy32_pipeWrapper(uy[32]),
		.i_uz32_pipeWrapper(uz[32]),
		.i_hit33_pipeWrapper(hit[32]),
		.i_ux33_pipeWrapper(ux[33]),
		.i_uy33_pipeWrapper(uy[33]),
		.i_hit34_pipeWrapper(hit[33]),
		.i_ux35_pipeWrapper(ux[35]),
		.i_uy35_pipeWrapper(uy[35]),
		.i_uz35_pipeWrapper(uz[35]),
		.i_layer35_pipeWrapper(layer[35]),
		.i_hit36_pipeWrapper(hit[35]),
		.i_ux36_pipeWrapper(ux[36]),
		.i_uy36_pipeWrapper(uy[36]),
		.i_uz36_pipeWrapper(uz[36]),
		.i_layer36_pipeWrapper(layer[36]),
		.i_dead36_pipeWrapper(dead[36]),
	
		//Memory Interface
			//Outputs
		.tindex(tindex),
		.fresIndex(fresIndex),
			//Inputs
		.rand2(rand2),
		.rand3(rand3),
		.rand5(rand5),
		.sint(sint),
		.cost(cost),
		.up_rFresnel(up_rFresnel),
		.down_rFresnel(down_rFresnel),
		
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
		
		//Outputs
		.ux_scatterer(ux_scatterer),
		.uy_scatterer(uy_scatterer),
		.uz_scatterer(uz_scatterer),
		
		.ux_reflector(ux_reflector),
		.uy_reflector(uy_reflector),
		.uz_reflector(uz_reflector),
		.layer_reflector(layer_reflector),
		.dead_reflector(dead_reflector)
	);
	
	
//////////////////////////////////////////////////////////////////////
////  dead or alive MUX                                           ////
////                                                              ////
////  Description:                                                ////
////    Used to determine whether the output from the scatterer   ////
////    or the reflector should be used in any clock cycle        ////
//////////////////////////////////////////////////////////////////////

always @ (*) begin
   case (hit[PIPE_DEPTH])   
   0: begin
       o_ux = ux_scatterer;
       o_uy = uy_scatterer;
       o_uz = uz_scatterer;
       o_layer = layer[PIPE_DEPTH];
       o_dead = dead[PIPE_DEPTH];          
   end
   1: begin
      o_ux = ux_reflector;
      o_uy = uy_reflector;
      o_uz = uz_reflector;
      o_layer = layer_reflector;
      o_dead = dead_reflector;
   end   
   endcase 
    
end





endmodule

//////////////////////////////////////////////////////////////////////
////  PhotonBlock Module                                          ////
////                                                              ////
////  Description:                                                ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

//Photons that make up the register pipeline
module PhotonBlock5(
	//Inputs
	clock,
	reset,
	enable,
	
	i_x,
	i_y,
	i_z,
	i_ux,
	i_uy,
	i_uz,
	i_sz,
	i_sr,
	i_sleftz,
	i_sleftr,
	i_weight,
	i_layer,
	i_dead,
	i_hit,
	//Outputs
	o_x,
	o_y,
	o_z,
	o_ux,
	o_uy,
	o_uz,
	o_sz,
	o_sr,
	o_sleftz,
	o_sleftr,
	o_weight,
	o_layer,
	o_dead,
	o_hit
	);

parameter BIT_WIDTH=32;
parameter LAYER_WIDTH=3;

input				clock;
input				reset;
input				enable;

input	[BIT_WIDTH-1:0]			i_x;
input	[BIT_WIDTH-1:0]			i_y;
input	[BIT_WIDTH-1:0]			i_z;
input	[BIT_WIDTH-1:0]			i_ux;
input	[BIT_WIDTH-1:0]			i_uy;
input	[BIT_WIDTH-1:0]			i_uz;
input	[BIT_WIDTH-1:0]			i_sz;
input	[BIT_WIDTH-1:0]			i_sr;
input	[BIT_WIDTH-1:0]			i_sleftz;
input	[BIT_WIDTH-1:0]			i_sleftr;
input	[BIT_WIDTH-1:0]			i_weight;
input	[LAYER_WIDTH-1:0]			i_layer;
input				i_dead;
input				i_hit;


output	[BIT_WIDTH-1:0]			o_x;
output	[BIT_WIDTH-1:0]			o_y;
output	[BIT_WIDTH-1:0]			o_z;
output	[BIT_WIDTH-1:0]			o_ux;
output	[BIT_WIDTH-1:0]			o_uy;
output	[BIT_WIDTH-1:0]			o_uz;
output	[BIT_WIDTH-1:0]			o_sz;
output	[BIT_WIDTH-1:0]			o_sr;
output	[BIT_WIDTH-1:0]			o_sleftz;
output	[BIT_WIDTH-1:0]			o_sleftr;
output	[BIT_WIDTH-1:0]			o_weight;
output	[LAYER_WIDTH-1:0]			o_layer;
output				o_dead;
output				o_hit;


wire				clock;
wire				reset;
wire				enable;

wire	[BIT_WIDTH-1:0]			i_x;
wire	[BIT_WIDTH-1:0]			i_y;
wire	[BIT_WIDTH-1:0]			i_z;
wire	[BIT_WIDTH-1:0]			i_ux;
wire	[BIT_WIDTH-1:0]			i_uy;
wire	[BIT_WIDTH-1:0]			i_uz;
wire	[BIT_WIDTH-1:0]			i_sz;
wire	[BIT_WIDTH-1:0]			i_sr;
wire	[BIT_WIDTH-1:0]			i_sleftz;
wire	[BIT_WIDTH-1:0]			i_sleftr;
wire	[BIT_WIDTH-1:0]			i_weight;
wire	[LAYER_WIDTH-1:0]			i_layer;
wire				i_dead;
wire				i_hit;


reg	[BIT_WIDTH-1:0]			o_x;
reg	[BIT_WIDTH-1:0]			o_y;
reg	[BIT_WIDTH-1:0]			o_z;
reg	[BIT_WIDTH-1:0]			o_ux;
reg	[BIT_WIDTH-1:0]			o_uy;
reg	[BIT_WIDTH-1:0]			o_uz;
reg	[BIT_WIDTH-1:0]			o_sz;
reg	[BIT_WIDTH-1:0]			o_sr;
reg	[BIT_WIDTH-1:0]			o_sleftz;
reg	[BIT_WIDTH-1:0]			o_sleftr;
reg	[BIT_WIDTH-1:0]			o_weight;
reg	[LAYER_WIDTH-1:0]			o_layer;
reg				o_dead;
reg				o_hit;


always @ (posedge clock)
	if(reset) begin
		o_x		<=	{BIT_WIDTH{1'b0}};
		o_y		<=	{BIT_WIDTH{1'b0}};
		o_z		<=	{BIT_WIDTH{1'b0}};
		o_ux		<=	{BIT_WIDTH{1'b0}};
		o_uy		<=	{BIT_WIDTH{1'b0}};
		o_uz		<=	{BIT_WIDTH{1'b0}};
		o_sz		<=	{BIT_WIDTH{1'b0}};
		o_sr		<=	{BIT_WIDTH{1'b0}};
		o_sleftz	<=	{BIT_WIDTH{1'b0}};
		o_sleftr	<=	{BIT_WIDTH{1'b0}};
		o_weight	<=	{BIT_WIDTH{1'b0}};
		o_layer		<=	{LAYER_WIDTH{1'b0}};
		o_dead		<=	1'b1;
		o_hit		<=	1'b0;
	end else if(enable) begin
		o_x		<=	i_x;
		o_y		<=	i_y;
		o_z		<=	i_z;
		o_ux		<=	i_ux;
		o_uy		<=	i_uy;
		o_uz		<=	i_uz;
		o_sz		<=	i_sz;
		o_sr		<=	i_sr;
		o_sleftz	<=	i_sleftz;
		o_sleftr	<=	i_sleftr;
		o_weight	<=	i_weight;
		o_layer		<=	i_layer;
		o_dead		<=	i_dead;
		o_hit		<=	i_hit;
	end
endmodule
