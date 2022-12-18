module CS_IP
// #(parameter WIDTH_DATA = 64, parameter WIDTH_RESULT = 4)
#(parameter WIDTH_DATA = 128, parameter WIDTH_RESULT = 8)

(
    data,
    in_valid,
    clk,
    rst_n,
    result,
    out_valid
);

input [(WIDTH_DATA-1):0] data;
input in_valid, clk, rst_n;

output reg [(WIDTH_RESULT-1):0] result;
output reg out_valid;

generate
// WIDTH_DATA = 64, 128, 256
// WIDTH_RESULT = 1, 2, 4, 8, 16, 32 , 64, 128, 256
reg in_valid_store;
reg [(WIDTH_DATA-1):0] data_store;

wire [255:0] zero_256;
wire [255:0] data_256;
wire [128:0]  sum_256;
wire [127:0] data_128;
wire [ 64:0]  sum_128;
wire [ 63:0]  data_64;
wire [ 32:0]   sum_64;
wire [ 31:0]  data_32;
wire [ 16:0]   sum_32;
wire [ 15:0]  data_16;
wire [  8:0]   sum_16;
wire [  7:0]   data_8;
wire [  4:0]    sum_8;
wire [  3:0]   data_4;
wire [  2:0]    sum_4;
wire [  1:0]   data_2;
wire [  1:0]    sum_2;
wire           data_1;
wire [255:0]  out_256;
wire [127:0]  out_128;
wire [ 63:0]   out_64;
wire [ 31:0]   out_32;
wire [ 15:0]   out_16;
wire [  7:0]    out_8;
wire [  3:0]    out_4;
wire [  1:0]    out_2;
wire            out_1;

assign zero_256 = 256'b0;
// assign data_256 = zero_256          +     data       ;
assign data_256 = zero_256          +      data_store;
assign  sum_256 = data_256[255:128] + data_256[127:0];
assign data_128 =  sum_256    [128] +  sum_256[127:0];
assign  sum_128 = data_128[127: 64] + data_128[ 63:0];
assign  data_64 =  sum_128     [64] +  sum_128[ 63:0];
assign   sum_64 =  data_64[ 63: 32] +  data_64[ 31:0];
assign  data_32 =   sum_64     [32] +   sum_64[ 31:0];
assign   sum_32 =  data_32[ 31: 16] +  data_32[ 15:0];
assign  data_16 =   sum_32     [16] +   sum_32[ 15:0];
assign   sum_16 =  data_16[ 15:  8] +  data_16[  7:0];
assign   data_8 =   sum_16      [8] +   sum_16[  7:0];
assign    sum_8 =   data_8[  7:  4] +   data_8[  3:0];
assign   data_4 =    sum_8      [4] +    sum_8[  3:0];
assign    sum_4 =   data_4[  3:  2] +   data_4[  1:0];
assign   data_2 =    sum_4      [2] +    sum_4[  1:0];
assign    sum_2 =   data_2[      1] +   data_2[    0];
assign   data_1 =    sum_2      [1] +    sum_2[    0];
assign  out_256 = ~ data_256;
assign  out_128 = ~ data_128;
assign   out_64 = ~  data_64;
assign   out_32 = ~  data_32;
assign   out_16 = ~  data_16;
assign    out_8 = ~   data_8;
assign    out_4 = ~   data_4;
assign    out_2 = ~   data_2;
assign    out_1 = ~   data_1;

// data_store
always @(posedge clk or negedge rst_n) begin
// always @(*) begin // latch
	if (!rst_n) 
		data_store <= 0;
	else if (in_valid)
		data_store <= data;
	else
		data_store <= data_store;
end
// in_valid_store
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) 
		in_valid_store <= 0;
	else
		in_valid_store <= in_valid;
end
// out_valid
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		out_valid <= 0;
	else if (in_valid_store)
		out_valid <= 1;
	else
		out_valid <= 0;
end
// result
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) 
		result <= 0;
	else if (in_valid_store) begin
		// result = 0;
		if (WIDTH_RESULT == 256)
			result <= out_256;
		else if (WIDTH_RESULT == 128)
			result <= out_128;
		else if (WIDTH_RESULT == 64)
			result <= out_64;
		else if (WIDTH_RESULT == 32)
			result <= out_32;
		else if (WIDTH_RESULT == 16)
			result <= out_16;
		else if (WIDTH_RESULT == 8)
			result <= out_8;
		else if (WIDTH_RESULT == 4)
			result <= out_4;
		else if (WIDTH_RESULT == 2)
			result <= out_2;
		else if (WIDTH_RESULT == 1)
			result <= out_1;
		else
			result <= 0;
	end
	else
		result <= 0;
end

endgenerate


endmodule


