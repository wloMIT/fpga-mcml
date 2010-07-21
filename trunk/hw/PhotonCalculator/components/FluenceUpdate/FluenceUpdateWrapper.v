//////////////////////////////////////////////////////////////////////
////  FresnelWrapper Module                                       ////
////                                                              ////
////  Description:                                                ////
////  Wraps everything in Fresnel + dual-port MEM                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

module FresnelWrapper (
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
 
 	//Dual-port Mem- For synthesis only
    absorb_data, absorb_rdaddress, absorb_wraddress, 
    absorb_wren, absorb_q,

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
parameter ADDR_WIDTH=16;          //256 x 256
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
input	[LAYER_WIDTH-1:0]			i_layer;
input				i_dead;
input				i_hit;


//From System Register File (5 layers)- Absorber
input	[BIT_WIDTH-1:0] muaFraction1, muaFraction2, muaFraction3, muaFraction4, muaFraction5; 


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
output	[LAYER_WIDTH-1:0]			o_layer;
output				o_dead;
output				o_hit;

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
wire	[LAYER_WIDTH-1:0]			layer	[PIPE_DEPTH:0];
wire				dead	[PIPE_DEPTH:0];
wire				hit	[PIPE_DEPTH:0];

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
assign o_x =x[PIPE_DEPTH];
assign o_y =y[PIPE_DEPTH];
assign o_z =z[PIPE_DEPTH];
assign o_ux =ux[PIPE_DEPTH];
assign o_uy =uy[PIPE_DEPTH];
assign o_uz =uz[PIPE_DEPTH];
assign o_sz =sz[PIPE_DEPTH];
assign o_sr =sr[PIPE_DEPTH];
assign o_sleftz =sleftz[PIPE_DEPTH];
assign o_sleftr =sleftr[PIPE_DEPTH];
//assign o_weight =weight[PIPE_DEPTH]; Assigned by absorber module (below)
assign o_layer =layer[PIPE_DEPTH];
assign o_dead =dead[PIPE_DEPTH];
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
assign z_pipe=z[14];  //Check square-root latency and modify z[14] if needed!!!!
assign layer_pipe=layer[4];


//////////////////////////////////////////////////////////////////////////////
//Connect up different modules
//////////////////////////////////////////////////////////////////////////////
wire [WORD_WIDTH-1:0] data; 
wire [ADDR_WIDTH-1:0] rdaddress, wraddress; 
wire wren; 
wire [WORD_WIDTH-1:0] q;

output [WORD_WIDTH-1:0] absorb_data; 
output [ADDR_WIDTH-1:0] absorb_rdaddress, absorb_wraddress; 
output absorb_wren; 
output [WORD_WIDTH-1:0] absorb_q;

assign absorb_data=data; 
assign absorb_rdaddress=rdaddress; 
assign absorb_wraddress=wraddress; 
assign absorb_wren=wren; 
assign absorb_q=q; 

//>>>>>>>>>>>>> Dual-port mem <<<<<<<<<<<<<<<<<<
dual absorptionMatrix(   .clock (clock), .data(data), 
                         .rdaddress(rdaddress), .wraddress(wraddress), 
                         .wren(wren), .q(q)); 


//>>>>>>>>>>>>> Absorber <<<<<<<<<<<<<<<<<<

Absorber absorb (    //INPUTS
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
