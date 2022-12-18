
//synopsys translate_off
// `include "DW_sqrt.v"
// `include "DW_sqrt_seq.v"
// `include "DW_div.v"
// `include "DW_div_seq.v"
`include "/usr/synthesis/dw/sim_ver/DW_sqrt_seq.v"
`include "/usr/synthesis/dw/sim_ver/DW_div_seq.v"
//synopsys translate_on

module TRIANGLE(
    clk,
    rst_n,
    in_valid,
    coord_x,
    coord_y,
    out_valid,
    out_length,
	  out_incenter
);

input wire clk, rst_n, in_valid;
input wire [4:0] coord_x, coord_y;

output reg out_valid;
output reg [12:0] out_length, out_incenter;

// sqrt
parameter inst_width = 25; // 11 + 14
parameter inst_tc_mode = 0;
parameter inst_num_cyc_sqrt = 13; // 3 ~ (bit+1)/2
parameter inst_rst_mode = 0;
parameter inst_input_mode = 1;
parameter inst_output_mode = 0;
parameter inst_early_start = 0;
// div
parameter inst_a_width = 27;
parameter inst_b_width = 15;
//parameter inst_tc_mode = 0;
parameter inst_num_cyc_div = 14; // 3 ~ (bit+1)/2
//parameter inst_rst_mode = 0;
//parameter inst_input_mode = 1;
//parameter inst_output_mode = 0;
//parameter inst_early_start = 0;
reg reset_flag;
reg [6:0] counter;
reg [4:0] x_array[2:0];
reg [4:0] y_array[2:0];
wire [10:0] a_0;
wire [10:0] a_1;
wire [10:0] a_2;
wire [24:0] a_0_shift14;
wire [24:0] a_1_shift14;
wire [24:0] a_2_shift14;
wire start_sqrt;
wire complete_0;
wire complete_1;
wire complete_2;
wire [12:0] root_0;
wire [12:0] root_1;
wire [12:0] root_2;
wire start_div;
wire [19:0] top_x;
wire [19:0] top_y;
wire [26:0] top_x_shift7;
wire [26:0] top_y_shift7;
wire [14:0] sum_abc;
wire complete_x;
wire complete_y;
wire divide_by_0_x;
wire divide_by_0_y;
wire [26:0] quotient_x;
wire [26:0] quotient_y;
wire [14:0] remainder_x;
wire [14:0] remainder_y;

integer i;
assign start_sqrt = (reset_flag)&&(counter == 1);
assign start_div = (reset_flag)&&(counter == 15);
assign a_0 = (x_array[1]-x_array[2])*(x_array[1]-x_array[2]) + (y_array[1]-y_array[2])*(y_array[1]-y_array[2]);
assign a_1 = (x_array[0]-x_array[2])*(x_array[0]-x_array[2]) + (y_array[0]-y_array[2])*(y_array[0]-y_array[2]);
assign a_2 = (x_array[0]-x_array[1])*(x_array[0]-x_array[1]) + (y_array[0]-y_array[1])*(y_array[0]-y_array[1]);
assign a_0_shift14 = a_0 << 14;
assign a_1_shift14 = a_1 << 14;
assign a_2_shift14 = a_2 << 14;
assign top_x = root_0*x_array[0] + root_1*x_array[1] + root_2*x_array[2];
assign top_y = root_0*y_array[0] + root_1*y_array[1] + root_2*y_array[2];
assign top_x_shift7 = top_x << 7;
assign top_y_shift7 = top_y << 7;
assign sum_abc = root_0 + root_1 + root_2;

// DW_sqrt_seq U0
DW_sqrt_seq #(inst_width, inst_tc_mode, inst_num_cyc_sqrt, inst_rst_mode,
inst_input_mode, inst_output_mode, inst_early_start)
U0 (.clk(clk), .rst_n(rst_n), .hold(1'b0), .start(start_sqrt), .a(a_0_shift14), 
.complete(complete_0), .root(root_0));
// DW_sqrt_seq U1
DW_sqrt_seq #(inst_width, inst_tc_mode, inst_num_cyc_sqrt, inst_rst_mode,
inst_input_mode, inst_output_mode, inst_early_start)
U1 (.clk(clk), .rst_n(rst_n), .hold(1'b0), .start(start_sqrt), .a(a_1_shift14), 
.complete(complete_1), .root(root_1));
// DW_sqrt_seq U2
DW_sqrt_seq #(inst_width, inst_tc_mode, inst_num_cyc_sqrt, inst_rst_mode,
inst_input_mode, inst_output_mode, inst_early_start)
U2 (.clk(clk), .rst_n(rst_n), .hold(1'b0), .start(start_sqrt), .a(a_2_shift14), 
.complete(complete_2), .root(root_2));
// DW_div_seq U_X
DW_div_seq #(inst_a_width, inst_b_width, inst_tc_mode, inst_num_cyc_div,
inst_rst_mode, inst_input_mode, inst_output_mode, inst_early_start)
U_X (.clk(clk), .rst_n(rst_n), .hold(1'b0),.start(start_div),
.a(top_x_shift7), .b(sum_abc), .complete(complete_x),
.divide_by_0(divide_by_0_x), .quotient(quotient_x), .remainder(remainder_x));
// DW_div_seq U_Y
DW_div_seq #(inst_a_width, inst_b_width, inst_tc_mode, inst_num_cyc_div,
inst_rst_mode, inst_input_mode, inst_output_mode, inst_early_start)
U_Y (.clk(clk), .rst_n(rst_n), .hold(1'b0),.start(start_div),
.a(top_y_shift7), .b(sum_abc), .complete(complete_y),
.divide_by_0(divide_by_0_y), .quotient(quotient_y), .remainder(remainder_y));

// reset_flag
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		reset_flag <= 0;
	else if (in_valid)
		reset_flag <= 1;
	else
		reset_flag <= reset_flag;
end
// x_array
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		for (i = 0; i < 3; i = i + 1)
			x_array[i] <= 0;
	end
	else if (in_valid) begin
		x_array[2] <= coord_x;
		for (i = 0; i < 2; i = i + 1) begin
			x_array[i] <= x_array[i+1];
		end
	end
	else begin
		for (i = 0; i < 3; i = i + 1) begin
			x_array[i] <= x_array[i];
		end
	end
end
// y_array
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		for (i = 0; i < 3; i = i + 1)
			y_array[i] <= 0;
	end
	else if (in_valid) begin
		y_array[2] <= coord_y;
		for (i = 0; i < 2; i = i + 1) begin
			y_array[i] <= y_array[i+1];
		end
	end
	else begin
		for (i = 0; i < 3; i = i + 1) begin
			y_array[i] <= y_array[i];
		end
	end
end
// counter
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		counter <= 0;
	else if (in_valid)
		counter <= 0;
	else
		counter <= counter + 1;
end
// out_valid
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		out_valid <= 0;
	else if ((counter == 29) || (counter == 30) || (counter == 31))
		out_valid <= 1;
	else
		out_valid <= 0;
end
// out_length
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		out_length <= 0;
	else if (counter == 29)
		// out_length <= root_0*128 + floating_0*4;
		// out_length <= root_0*128 + (sum_point_0 << 4);
		// out_length <= point_0 ;
		out_length <= root_0 ;
	else if (counter == 30)
		// out_length <= root_1*128 + floating_1*4;
		// out_length <= root_1*128 + 0*4;
		// out_length <= point_1;
		out_length <= root_1;
	else if (counter == 31)
		// out_length <= root_2*128 + floating_2*4;
		// out_length <= root_2*128 + 0*4;
		// out_length <= point_2;
		out_length <= root_2;
	else
		out_length <= 0;
end
// out_incenter
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		out_incenter <= 0;
	else if (counter == 29)
		// out_incenter <= {quotient_x,remainder_x};// 13bits = {12bits,8bits} = {6bits,7bits}
		// out_incenter <= quotient_x*128 + remainder_x*7/sum_abc;
		// out_incenter <= quotient_x*128 + (sum_point_x << 4);
		// out_incenter <= quotient_x*128 ;
		// out_incenter <= point_x;
		// out_incenter <= quotient_x*128 + point_x;
		out_incenter <= quotient_x;
	else if ((counter == 30) || (counter == 31))
		// out_incenter <= {quotient_y,remainder_y};
		// out_incenter <= quotient_y*128 + remainder_y*7/sum_abc;
		// out_incenter <= quotient_y*128 + (sum_point_y << 4);
		// out_incenter <= quotient_y*128;
		// out_incenter <= point_y;
		// out_incenter <= quotient_y*128 + point_y;
		out_incenter <= quotient_y;
	else
		out_incenter <= 0;
end


endmodule
