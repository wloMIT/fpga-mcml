// Log Calc
// Author Jason Luu
// Description:
// Calculate the logarithm of the input
// Latency of 2, unregistered inputs, registered outputs


module LogCalc(clock, reset, enable, in_x, log_x);

parameter BIT_WIDTH=32;
parameter MANTISSA_PRECISION=10;
parameter LOG2_BIT_WIDTH = 6;
parameter LOG2=93032639;

input clock, reset, enable;
input [BIT_WIDTH - 1:0] in_x;
output [BIT_WIDTH - 1:0] log_x;

wire [BIT_WIDTH - 1:0] mantissa;

reg unsigned [BIT_WIDTH - 1:0] c_mantissa_val;

reg unsigned [BIT_WIDTH - 1:0] c_log_x;
reg unsigned [LOG2_BIT_WIDTH - 1:0] c_indexFirstOne;
reg unsigned [BIT_WIDTH - 1:0] c_temp_shift_x;
reg unsigned [MANTISSA_PRECISION - 1:0] c_shifted_x;

reg unsigned [LOG2_BIT_WIDTH - 1:0] r_indexFirstOne;
reg unsigned [BIT_WIDTH - 1:0] log_x;


integer i;

Log_mantissa u1(c_shifted_x, clock, mantissa);

// priority encoder
always @(*)
begin
	c_indexFirstOne = 6'b0; 
	for(i = 0; i < BIT_WIDTH; i = i + 1)
	begin
		if(in_x[i])
			c_indexFirstOne = i;
	end
end

// shift operation based on priority encoder results
always@(*)
begin
	c_temp_shift_x = in_x >> (c_indexFirstOne - MANTISSA_PRECISION + 1);
	if(c_indexFirstOne >= MANTISSA_PRECISION)
	begin
		c_shifted_x = c_temp_shift_x[MANTISSA_PRECISION - 1:0];
	end
	else
		c_shifted_x = in_x[MANTISSA_PRECISION - 1:0];
	begin
	end
end

// calculate log
always @(*)
begin
	if(r_indexFirstOne >= MANTISSA_PRECISION)
	begin
		c_log_x =  mantissa - ((MANTISSA_PRECISION - 1) * LOG2) + (r_indexFirstOne * LOG2);
	end
	else
	begin
		c_log_x = mantissa;
	end
end

// latch values
always @(posedge clock)
begin
	if(reset)
		begin
			log_x <= 0;
			r_indexFirstOne <= 0;
		end
	else
		begin
			if(enable)
			begin
				r_indexFirstOne <= c_indexFirstOne;
				log_x <= c_log_x;
			end
		end
end


endmodule
