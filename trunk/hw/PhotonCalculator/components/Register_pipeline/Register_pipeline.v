
//Photons that make up the register pipeline
module PhotonBlock(
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

input				clock;
input				reset;
input				enable;

input	[31:0]			i_x;
input	[31:0]			i_y;
input	[31:0]			i_z;
input	[31:0]			i_ux;
input	[31:0]			i_uy;
input	[31:0]			i_uz;
input	[31:0]			i_sz;
input	[31:0]			i_sr;
input	[31:0]			i_sleftz;
input	[31:0]			i_sleftr;
input	[31:0]			i_weight;
input	[2:0]			i_layer;
input				i_dead;
input				i_hit;


output	[31:0]			o_x;
output	[31:0]			o_y;
output	[31:0]			o_z;
output	[31:0]			o_ux;
output	[31:0]			o_uy;
output	[31:0]			o_uz;
output	[31:0]			o_sz;
output	[31:0]			o_sr;
output	[31:0]			o_sleftz;
output	[31:0]			o_sleftr;
output	[31:0]			o_weight;
output	[2:0]			o_layer;
output				o_dead;
output				o_hit;


wire				clock;
wire				reset;
wire				enable;

wire	[31:0]			i_x;
wire	[31:0]			i_y;
wire	[31:0]			i_z;
wire	[31:0]			i_ux;
wire	[31:0]			i_uy;
wire	[31:0]			i_uz;
wire	[31:0]			i_sz;
wire	[31:0]			i_sr;
wire	[31:0]			i_sleftz;
wire	[31:0]			i_sleftr;
wire	[31:0]			i_weight;
wire	[2:0]			i_layer;
wire				i_dead;
wire				i_hit;


reg	[31:0]			o_x;
reg	[31:0]			o_y;
reg	[31:0]			o_z;
reg	[31:0]			o_ux;
reg	[31:0]			o_uy;
reg	[31:0]			o_uz;
reg	[31:0]			o_sz;
reg	[31:0]			o_sr;
reg	[31:0]			o_sleftz;
reg	[31:0]			o_sleftr;
reg	[31:0]			o_weight;
reg	[2:0]			o_layer;
reg				o_dead;
reg				o_hit;




always @ (posedge clock)
	if(reset) begin
		o_x		<=	32'h00000000;
		o_y		<=	32'h00000000;
		o_z		<=	32'h00000000;
		o_ux		<=	32'h00000000;
		o_uy		<=	32'h00000000;
		o_uz		<=	32'h00000000;
		o_sz		<=	32'h00000000;
		o_sr		<=	32'h00000000;
		o_sleftz	<=	32'h00000000;
		o_sleftr	<=	32'h00000000;
		o_weight	<=	32'h00000000;
		o_layer		<=	3'b001;
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





//An array of photons that passes previous values to next,
//creating a pipeline.

module Register_pipeline (
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
parameter PIPE_DEPTH = 50;

//PINS
input				clock;
input				reset;
input				enable;

input	[31:0]			i_x;
input	[31:0]			i_y;
input	[31:0]			i_z;
input	[31:0]			i_ux;
input	[31:0]			i_uy;
input	[31:0]			i_uz;
input	[31:0]			i_sz;
input	[31:0]			i_sr;
input	[31:0]			i_sleftz;
input	[31:0]			i_sleftr;
input	[31:0]			i_weight;
input	[2:0]			i_layer;
input				i_dead;
input				i_hit;


output	[31:0]			o_x;
output	[31:0]			o_y;
output	[31:0]			o_z;
output	[31:0]			o_ux;
output	[31:0]			o_uy;
output	[31:0]			o_uz;
output	[31:0]			o_sz;
output	[31:0]			o_sr;
output	[31:0]			o_sleftz;
output	[31:0]			o_sleftr;
output	[31:0]			o_weight;
output	[2:0]			o_layer;
output				o_dead;
output				o_hit;

//PIN TYPES
wire				clock;
wire				reset;
wire				enable;

wire	[31:0]			i_x;
wire	[31:0]			i_y;
wire	[31:0]			i_z;
wire	[31:0]			i_ux;
wire	[31:0]			i_uy;
wire	[31:0]			i_uz;
wire	[31:0]			i_sz;
wire	[31:0]			i_sr;
wire	[31:0]			i_sleftz;
wire	[31:0]			i_sleftr;
wire	[31:0]			i_weight;
wire	[2:0]			i_layer;
wire				i_dead;
wire				i_hit;


wire	[31:0]			o_x;
wire	[31:0]			o_y;
wire	[31:0]			o_z;
wire	[31:0]			o_ux;
wire	[31:0]			o_uy;
wire	[31:0]			o_uz;
wire	[31:0]			o_sz;
wire	[31:0]			o_sr;
wire	[31:0]			o_sleftz;
wire	[31:0]			o_sleftr;
wire	[31:0]			o_weight;
wire	[2:0]			o_layer;
wire				o_dead;
wire				o_hit;





//WIRES FOR CONNECTING REGISTERS
wire	[31:0]			x	[PIPE_DEPTH:0];
wire	[31:0]			y	[PIPE_DEPTH:0];
wire	[31:0]			z	[PIPE_DEPTH:0];
wire	[31:0]			ux	[PIPE_DEPTH:0];
wire	[31:0]			uy	[PIPE_DEPTH:0];
wire	[31:0]			uz	[PIPE_DEPTH:0];
wire	[31:0]			sz	[PIPE_DEPTH:0];
wire	[31:0]			sr	[PIPE_DEPTH:0];
wire	[31:0]			sleftz	[PIPE_DEPTH:0];
wire	[31:0]			sleftr	[PIPE_DEPTH:0];
wire	[31:0]			weight	[PIPE_DEPTH:0];
wire	[2:0]			layer	[PIPE_DEPTH:0];
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
assign o_weight =weight[PIPE_DEPTH];
assign o_layer =layer[PIPE_DEPTH];
assign o_dead =dead[PIPE_DEPTH];
assign o_hit =hit[PIPE_DEPTH];


//GENERATE PIPELINE
genvar i;
generate
	for(i=PIPE_DEPTH; i>0; i=i-1) begin: regPipe
		case(i)
		
		default:
		PhotonBlock photon(
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
	
endmodule
