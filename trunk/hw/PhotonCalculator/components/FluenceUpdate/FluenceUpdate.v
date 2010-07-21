//////////////////////////////////////////////////////////////////////
////                                                              ////
////  FluenceUpdate Module                                        ////
////                                                              ////
////  Description:                                                ////
////  Implementation of FluenceUpdate Module                      ////
////                                                              ////
////  Author(s):                                                  ////
////      - William                                               ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

module FluenceUpdate (    //INPUTS
                     clock, reset, enable, 
                     
                     //From hopper
                     weight_hop, hit_hop, dead_hop,

                     //From Shared Registers
                     x_pipe, y_pipe, z_pipe, layer_pipe,
                     
                     //From System Register File (5 layers)
                     muaFraction1, muaFraction2, muaFraction3, muaFraction4, muaFraction5,  
                     
                     //I/O to on-chip mem -- check interface
                     data, rdaddress, wraddress, wren, q,
                     
                     //OUTPUT
                     weight_absorber
                     
                     ); 


//////////////////////////////////////////////////////////////////////////////
//PARAMETERS
//////////////////////////////////////////////////////////////////////////////
parameter NR=256;              
parameter NZ=256;              

parameter NR_EXP=8;              //meaning NR=2^NR_exp or 2^8=256
parameter RGRID_SCALE_EXP=21;    //2^21 = RGRID_SCALE
parameter ZGRID_SCALE_EXP=21;    //2^21 = ZGRID_SCALE


parameter BIT_WIDTH=32;
parameter BIT_WIDTH_2=64;
parameter WORD_WIDTH=64;
parameter ADDR_WIDTH=16;          //256x256=2^8*2^8=2^16


parameter LAYER_WIDTH=3; 
parameter PIPE_DEPTH = 37;        


//////////////////////////////////////////////////////////////////////////////
//INPUTS
//////////////////////////////////////////////////////////////////////////////
input clock;        
input	reset;
input enable;

//From hopper
input [BIT_WIDTH-1:0] weight_hop; 
input hit_hop; 
input dead_hop; 

//From Shared Reg
input signed [BIT_WIDTH-1:0] x_pipe;
input signed [BIT_WIDTH-1:0] y_pipe;
input [BIT_WIDTH-1:0] z_pipe;
input [LAYER_WIDTH-1:0] layer_pipe;

//From System Reg File
input [BIT_WIDTH-1:0] muaFraction1, muaFraction2, muaFraction3, muaFraction4, muaFraction5;  

//////////////////////////////////////////////////////////////////////////////
//OUTPUTS
//////////////////////////////////////////////////////////////////////////////
output [BIT_WIDTH-1:0] weight_absorber; 

//////////////////////////////////////////////////////////////////////////////
//I/O to on-chip mem -- check interface
//////////////////////////////////////////////////////////////////////////////
output [WORD_WIDTH-1:0] data; 
output [ADDR_WIDTH-1:0] rdaddress, wraddress; 
output wren;     reg wren; 
input [WORD_WIDTH-1:0] q;

//////////////////////////////////////////////////////////////////////////////
//Local AND Registered Value Variables
//////////////////////////////////////////////////////////////////////////////
//STAGE 1 - Do nothing

//STAGE 2
reg [BIT_WIDTH_2-1:0] x2_temp, y2_temp;   //From mult
reg [BIT_WIDTH_2-1:0] x2_P, y2_P;         //Registered Value

//STAGE 3
reg [BIT_WIDTH_2-1:0] r2_temp, r2_P;   
wire [BIT_WIDTH_2-1:0] r2_P_wire;  

//STAGE 4
reg [BIT_WIDTH-1:0]		fractionScaled; 
reg [BIT_WIDTH-1:0]		weight_P4; 
reg [BIT_WIDTH-1:0]		r_P; 
wire [BIT_WIDTH-1:0]		r_P_wire; 

reg [BIT_WIDTH_2-1:0] product64bit; 
reg [BIT_WIDTH-1:0] dwa_temp; 

//STAGE 14
reg [BIT_WIDTH-1:0]		ir_temp; 
reg [BIT_WIDTH-1:0]		iz_temp; 

//STAGE 15
reg [BIT_WIDTH-1:0]		ir_P; 
reg [BIT_WIDTH-1:0]		iz_P; 
reg [BIT_WIDTH-1:0]		ir_scaled; 
reg [ADDR_WIDTH-1:0] rADDR_temp; 
reg [ADDR_WIDTH-1:0] rADDR_16; 

//STAGE 16
reg [WORD_WIDTH-1:0] oldAbs_MEM;
reg [WORD_WIDTH-1:0] oldAbs_P; 
reg [ADDR_WIDTH-1:0] rADDR_17;
 
//STAGE 17
reg [BIT_WIDTH-1:0] weight_P; 
reg [BIT_WIDTH-1:0] dwa_P; 
reg [BIT_WIDTH-1:0] newWeight; 

reg [WORD_WIDTH-1:0] newAbs_P; 
reg [WORD_WIDTH-1:0] newAbs_temp; 

reg [ADDR_WIDTH-1:0] wADDR; 


//////////////////////////////////////////////////////////////////////////////
//PIPELINE weight, hit, dead
//////////////////////////////////////////////////////////////////////////////
//WIRES FOR CONNECTING REGISTERS
wire	[BIT_WIDTH-1:0]			weight	[PIPE_DEPTH:0];
wire	hit	[PIPE_DEPTH:0];
wire	dead	[PIPE_DEPTH:0];

//ASSIGNMENTS FROM INPUTS TO PIPE
assign weight[0] = weight_hop;
assign hit[0] = hit_hop;
assign dead[0] = dead_hop;

//ASSIGNMENTS FROM PIPE TO OUTPUT
assign weight_absorber =weight[PIPE_DEPTH];

//GENERATE PIPELINE
genvar i;
generate
	for(i=PIPE_DEPTH; i>0; i=i-1) begin: weightHitDeadPipe
		case(i)  
		
		//REGISTER 17 on diagram!!
		18:   
		begin
		   
		PhotonBlock2 photon(
			//Inputs
			.clock(clock),
			.reset(reset),
			.enable(enable),
			
			.i_x(newWeight),
			.i_y(hit[17]),
			.i_z(dead[17]),
			
			//Outputs			
			.o_x(weight[18]),
			.o_y(hit[18]),
			.o_z(dead[18])
		);
		    
		end
		default:
		begin
		PhotonBlock2 photon(
			//Inputs
			.clock(clock),
			.reset(reset),
			.enable(enable),
			
			.i_x(weight[i-1]),
			.i_y(hit[i-1]),
			.i_z(dead[i-1]),
			
			//Outputs			
			.o_x(weight[i]),
			.o_y(hit[i]),
			.o_z(dead[i])
		);
		end
		endcase
	end
endgenerate	

//////////////////////////////////////////////////////////////////////////////
//PIPELINE ir,iz,dwa
//////////////////////////////////////////////////////////////////////////////
//WIRES FOR CONNECTING REGISTERS
wire	[BIT_WIDTH-1:0]			ir	[PIPE_DEPTH:0];
wire	[BIT_WIDTH-1:0]			iz	[PIPE_DEPTH:0];
wire	[BIT_WIDTH-1:0]			dwa	[PIPE_DEPTH:0];

//ASSIGNMENTS FROM INPUTS TO PIPE
assign ir[0] = 0;
assign iz[0] = 0;
assign dwa[0] = 0;

//GENERATE PIPELINE
generate
	for(i=PIPE_DEPTH; i>0; i=i-1) begin: IrIzDwaPipe
		case(i)
		    
		//NOTE: STAGE 14 --> REGISTER 14 on diagram !!   ir, iz 
		15:   
		begin

		PhotonBlock1 photon(
			//Inputs
			.clock(clock),
			.reset(reset),
			.enable(enable),
			
			.i_x(ir_temp),
			.i_y(iz_temp),
			.i_z(dwa[14]),
			
			//Outputs			
			.o_x(ir[15]),
			.o_y(iz[15]),
			.o_z(dwa[15])
		);		
		
		end    
		
		//NOTE: STAGE 4 --> REGISTER 4 on diagram !!   dwa  
		5:   
		begin
		    
		PhotonBlock1 photon(
			//Inputs
			.clock(clock),
			.reset(reset),
			.enable(enable),
			
			.i_x(ir[4]),
			.i_y(iz[4]),
			.i_z(dwa_temp),
			
			//Outputs			
			.o_x(ir[5]),
			.o_y(iz[5]),
			.o_z(dwa[5])
		);		    
		
		end    
				
		default:
		begin
		    	    
		PhotonBlock1 photon(
			//Inputs
			.clock(clock),
			.reset(reset),
			.enable(enable),
			
			.i_x(ir[i-1]),
			.i_y(iz[i-1]),
			.i_z(dwa[i-1]),
			
			//Outputs			
			.o_x(ir[i]),
			.o_y(iz[i]),
			.o_z(dwa[i])
		);
		end
		endcase
	end
endgenerate	

//////////////////////////////////////////////////////////////////////////////
//STAGE BY STAGE PIPELINE DESIGN
//////////////////////////////////////////////////////////////////////////////

///////////////STAGE 2 - square of x and y/////////////////////////
always @(*) begin
	if (reset)	begin      
		x2_temp=0;      
		y2_temp=0;
	end
	else	begin
	   x2_temp=x_pipe*x_pipe;     
	   y2_temp=y_pipe*y_pipe;
	end 
end

///////////////STAGE 3 - square of r/////////////////////////
always @(*) begin
	if (reset)
		r2_temp=0; 
	else 
		r2_temp=x2_P+y2_P; 
end

///////////////STAGE 4 - Find r and dwa/////////////////////////
//Create MUX
always@(*)  
   case(layer_pipe) 
       1: fractionScaled=muaFraction1; 
       2: fractionScaled=muaFraction2; 
       3: fractionScaled=muaFraction3; 
       4: fractionScaled=muaFraction4; 
       5: fractionScaled=muaFraction5; 
       default: fractionScaled=0; //Sys Reset case
   endcase


always @(*) begin
	if (reset) begin
	   weight_P4=0; 
		r_P=0;  
      product64bit=0; 
      dwa_temp=0; 
   end
	else begin
	   weight_P4=weight[4];    
		r_P=r_P_wire;  //Connect to sqrt block
      product64bit=weight_P4*fractionScaled; 
  
      //Checking corner cases
      if (dead[4]==1)       //Dead photon
         dwa_temp=weight_P4;//drop all its weight
      else if (hit[4]==1)   //Hit Boundary 
         dwa_temp=0;        //Don't add to absorption array
      else
         dwa_temp=product64bit[63:32]; 	  
	end	
end

assign r2_P_wire=r2_P; 

Sqrt_64b	squareRoot (
				.clk(clock),
				.radical(r2_P_wire),
				.q(r_P_wire),
				.remainder()
			);
			
///////////////STAGE 14 - Find ir and iz/////////////////////////
always @(*) begin
	if (reset) begin
		ir_temp=0; 
		iz_temp=0;
	end	
	else begin 
		ir_temp=r_P>>RGRID_SCALE_EXP; 
		iz_temp=z_pipe>>ZGRID_SCALE_EXP;
		
		//Checking corner cases!!!
		if (dead[14]==1) begin 
         ir_temp=NR-1;    
         iz_temp=NZ-1; 
		end
		else if (hit[14]==1) begin 
		   ir_temp=0;
		   iz_temp=0; 
		end 

      if (iz_temp>=NZ) 
         iz_temp=NZ-1;    
      
      if (ir_temp>=NR) 
         ir_temp=NR-1; 
          		
	end	
end

///////////////STAGE 15 - Compute MEM address/////////////////////////
always @(*) begin
	if (reset) begin
	   ir_P=0; 
	   iz_P=0; 
	   ir_scaled=0; 
      rADDR_temp=0; 
   end
	else begin
	   ir_P=ir[15]; 
	   iz_P=iz[15]; 
	   ir_scaled=ir_P<<NR_EXP;  
      rADDR_temp=ir_scaled+iz_P; 		
   end
end

///////////////STAGE 16 - MEM read/////////////////////////
always @(*) begin
	if (reset)
		oldAbs_MEM=0; 
	else begin
	   //Check Corner cases (RAW hazards) 
      if (ir[16]==ir[17] && iz[16]==iz[17]) 
         oldAbs_MEM=newAbs_temp; 
      else if (ir[16]==ir[18] && iz[16]==iz[18])   
         oldAbs_MEM=newAbs_P;       //RAW hazard
      else 
         oldAbs_MEM=q;   //Connect to REAL dual-port MEM 
	end
	
end

///////////////STAGE 17 - Update Weight/////////////////////////
//TO BE TESTED!!!
always @(*) begin
	if(reset) begin
	   dwa_P=0;   //How to specify Base 10??? 
		weight_P=0; 
		newWeight = 0;
		newAbs_temp =0; 
   end
	else begin
	   dwa_P=dwa[17];
	   weight_P=weight[17]; 
		newWeight=weight_P-dwa_P; 
		newAbs_temp=oldAbs_P+dwa_P;   //Check bit width casting (64-bit<--64-bit+32-bit)
   end 
end    
		
//////////////////////////////////////////////////////////////////////////////
//STAGE BY STAGE - EXTRA REGISTERS
//////////////////////////////////////////////////////////////////////////////   
always @ (posedge clock) 
begin
	if (reset) begin	    
	  //Stage 2
	  x2_P<=0;         
	  y2_P<=0;
	  
	  //Stage 3
	  r2_P<=0;	  
	  
	  //Stage 15
     rADDR_16<=0; 

	  //Stage 16 
	  oldAbs_P<=0; 
	  rADDR_17<=0; 
	  
	  //Stage 17
	  newAbs_P<=0; 
	  wADDR <=0; 
	end
	
	else if (enable) begin	    
	  //Stage 2
	  x2_P<=x2_temp;    //From comb logic above
	  y2_P<=y2_temp;    
      
 	  //Stage 3
 	  r2_P<=r2_temp;   

	  //Stage 15
     rADDR_16<=rADDR_temp; 
     
     //Stage 16 
	  oldAbs_P<=oldAbs_MEM; 
	  rADDR_17<=rADDR_16; 
	  	     
     //Stage 17
     newAbs_P<=newAbs_temp; 
     wADDR <=rADDR_17; 
	end
end

//////////////////////////////////////////////////////////////////////////////
//INTERFACE to on-chip MEM
//////////////////////////////////////////////////////////////////////////////   
always @ (posedge clock) 
begin
	if (reset) 
		  wren <=0; 
	else
		  wren<=1;          //Memory enabled every cycle after global enable 
end	
	    
assign rdaddress=rADDR_temp; 
assign wraddress=rADDR_17; 

assign data=newAbs_temp; 

endmodule


//////////////////////////////////////////////////////////////////////
////  INTERNAL                                                    ////
////  Pipeline Module - Type 1 (for 32-bit, 32-bit, 32-bit case)  ////
////                                                              ////
////  Description:                                                ////
////  Implementation of Internal Pipeline Module                  ////
////                                                              ////
////  To Do:                                                      ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

//Photons that make up the register pipeline
module PhotonBlock1(
	//Inputs
	clock,
	reset,
	enable,
	
   i_x, 
   i_y, 
   i_z, 

	//Outputs
	o_x,
	o_y,
	o_z
	);

//////////////////////////////////////////////////////////////////////////////
//PARAMETERS
//////////////////////////////////////////////////////////////////////////////
parameter BIT_WIDTH=32;

input				clock;
input				reset;
input				enable;

input	[BIT_WIDTH-1:0]			i_x;
input	[BIT_WIDTH-1:0]			i_y;
input	[BIT_WIDTH-1:0]			i_z;


output	[BIT_WIDTH-1:0]			o_x;
output	[BIT_WIDTH-1:0]			o_y;
output	[BIT_WIDTH-1:0]			o_z;

wire				clock;
wire				reset;
wire				enable;

wire	[BIT_WIDTH-1:0]			i_x;
wire	[BIT_WIDTH-1:0]			i_y;
wire	[BIT_WIDTH-1:0]			i_z;

reg	[BIT_WIDTH-1:0]			o_x;
reg	[BIT_WIDTH-1:0]			o_y;
reg	[BIT_WIDTH-1:0]			o_z;

always @ (posedge clock)
	if(reset) begin
		o_x		<=	{BIT_WIDTH{1'b0}} ;
		o_y		<=	{BIT_WIDTH{1'b0}};
		o_z		<=	{BIT_WIDTH{1'b0}};
	end else if(enable) begin
		o_x		<=	i_x;
		o_y		<=	i_y;
		o_z		<=	i_z;
	end
endmodule


//////////////////////////////////////////////////////////////////////
////  INTERNAL                                                    ////
////  Pipeline Module - Type 2 (for 32-bit, 1-bit, 1-bit case)    ////
////                                                              ////
////  Description:                                                ////
////  Implementation of Internal Pipeline Module                  ////
////                                                              ////
////  To Do:                                                      ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

//Photons that make up the register pipeline
module PhotonBlock2(
	//Inputs
	clock,
	reset,
	enable,
	
   i_x, 
   i_y, 
   i_z, 

	//Outputs
	o_x,
	o_y,
	o_z
	);

//////////////////////////////////////////////////////////////////////////////
//PARAMETERS
//////////////////////////////////////////////////////////////////////////////
parameter BIT_WIDTH=32;

input				clock;
input				reset;
input				enable;

input	[BIT_WIDTH-1:0]			i_x;
input	i_y;
input	i_z;


output	[BIT_WIDTH-1:0]			o_x;
output	o_y;
output	o_z;

wire				clock;
wire				reset;
wire				enable;

wire	[BIT_WIDTH-1:0]			i_x;
wire	i_y;
wire	i_z;

reg	[BIT_WIDTH-1:0]			o_x;
reg	o_y;
reg	o_z;

always @ (posedge clock)
	if(reset) begin
		o_x		<=	{BIT_WIDTH{1'b0}} ;
		o_y		<=	1'b0;
		o_z		<=	1'b0;
	end else if(enable) begin
		o_x		<=	i_x;
		o_y		<=	i_y;
		o_z		<=	i_z;
	end
endmodule
