
// synopsys translate_off 
`ifdef RTL
`include "GATED_OR.v"
`else
`include "Netlist/GATED_OR_SYN.v"
`endif
// synopsys translate_on
module SP(
	// Input signals
	clk,
	rst_n,
    cg_en,
	in_valid,
	in_data,
	in_mode,
	// Output signals
	out_valid,
	out_data
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, cg_en, in_valid;
input [2:0] in_mode;
input [8:0] in_data;
output reg out_valid;
output reg [8:0] out_data;

parameter S_IDLE    = 'd0;
parameter S_INPUT   = 'd1;
parameter S_INVERSE = 'd2;
parameter S_MULT    = 'd3;
parameter S_SORT    = 'd4;
parameter S_SUM     = 'd5;
parameter S_OUTPUT  = 'd6;

reg sleep_inverse;
reg sleep_mult;
reg sleep_sort;
reg sleep_sum;
wire clock_gated_inverse;
wire clock_gated_mult;
wire clock_gated_sort;
wire clock_gated_sum;

reg [8:0] stack_a[5:0];
reg [8:0] stack_b[5:0];
reg [8:0] stack_c[5:0];
reg [8:0] stack_d[5:0];
reg [8:0] stack_e[5:0];
reg [2:0] mode_store;

reg [2:0] counter;
reg [2:0] counter_in;
reg [3:0] counter_inverse;
reg [2:0] counter_mult;
reg [2:0] counter_sort;
reg [2:0] counter_sum;
reg [2:0] counter_out;

wire [8:0] p;
// inverse
reg [8:0] a0,b0;
reg [8:0] a1,b1;
reg [8:0] a2,b2;
reg [8:0] a3,b3;
reg [8:0] a4,b4;
reg [8:0] a5,b5;
wire [17:0] mult_a0b0;
wire [17:0] mult_a1b1;
wire [17:0] mult_a2b2;
wire [17:0] mult_a3b3;
wire [17:0] mult_a4b4;
wire [17:0] mult_a5b5;
wire [10:0] mult_a0b0_cal;
wire [10:0] mult_a1b1_cal;
wire [10:0] mult_a2b2_cal;
wire [10:0] mult_a3b3_cal;
wire [10:0] mult_a4b4_cal;
wire [10:0] mult_a5b5_cal;
wire [9:0] mult_a0b0_cal2;
wire [9:0] mult_a1b1_cal2;
wire [9:0] mult_a2b2_cal2;
wire [9:0] mult_a3b3_cal2;
wire [9:0] mult_a4b4_cal2;
wire [9:0] mult_a5b5_cal2;
wire [8:0] mult_a0b0_cal3;
wire [8:0] mult_a1b1_cal3;
wire [8:0] mult_a2b2_cal3;
wire [8:0] mult_a3b3_cal3;
wire [8:0] mult_a4b4_cal3;
wire [8:0] mult_a5b5_cal3;
reg [8:0] mult_a0b0_mod;
reg [8:0] mult_a1b1_mod;
reg [8:0] mult_a2b2_mod;
reg [8:0] mult_a3b3_mod;
reg [8:0] mult_a4b4_mod;
reg [8:0] mult_a5b5_mod;
wire [17:0] squa_b0;
wire [17:0] squa_b1;
wire [17:0] squa_b2;
wire [17:0] squa_b3;
wire [17:0] squa_b4;
wire [17:0] squa_b5;
wire [10:0] squa_b0_cal;
wire [10:0] squa_b1_cal;
wire [10:0] squa_b2_cal;
wire [10:0] squa_b3_cal;
wire [10:0] squa_b4_cal;
wire [10:0] squa_b5_cal;
wire [9:0] squa_b0_cal2;
wire [9:0] squa_b1_cal2;
wire [9:0] squa_b2_cal2;
wire [9:0] squa_b3_cal2;
wire [9:0] squa_b4_cal2;
wire [9:0] squa_b5_cal2;
wire [8:0] squa_b0_cal3;
wire [8:0] squa_b1_cal3;
wire [8:0] squa_b2_cal3;
wire [8:0] squa_b3_cal3;
wire [8:0] squa_b4_cal3;
wire [8:0] squa_b5_cal3;
reg [8:0] squa_b0_mod;
reg [8:0] squa_b1_mod;
reg [8:0] squa_b2_mod;
reg [8:0] squa_b3_mod;
reg [8:0] squa_b4_mod;
reg [8:0] squa_b5_mod;
// mult
reg [8:0] mult_temp_c0;
reg [8:0] mult_temp_c1;
reg [8:0] mult_temp_c2;
reg [8:0] mult_temp_c3;
reg [8:0] mult_temp_c4;
reg [8:0] mult_temp_c5;
wire [17:0] mult_c0temp;
wire [17:0] mult_c1temp;
wire [17:0] mult_c2temp;
wire [17:0] mult_c3temp;
wire [17:0] mult_c4temp;
wire [17:0] mult_c5temp;
wire [10:0] mult_c0temp_cal;
wire [10:0] mult_c1temp_cal;
wire [10:0] mult_c2temp_cal;
wire [10:0] mult_c3temp_cal;
wire [10:0] mult_c4temp_cal;
wire [10:0] mult_c5temp_cal;
wire [9:0] mult_c0temp_cal2;
wire [9:0] mult_c1temp_cal2;
wire [9:0] mult_c2temp_cal2;
wire [9:0] mult_c3temp_cal2;
wire [9:0] mult_c4temp_cal2;
wire [9:0] mult_c5temp_cal2;
wire [8:0] mult_c0temp_cal3;
wire [8:0] mult_c1temp_cal3;
wire [8:0] mult_c2temp_cal3;
wire [8:0] mult_c3temp_cal3;
wire [8:0] mult_c4temp_cal3;
wire [8:0] mult_c5temp_cal3;
reg [8:0] mult_c0temp_mod;
reg [8:0] mult_c1temp_mod;
reg [8:0] mult_c2temp_mod;
reg [8:0] mult_c3temp_mod;
reg [8:0] mult_c4temp_mod;
reg [8:0] mult_c5temp_mod;
// sum
reg [8:0] sum_temp_e0;
reg [8:0] sum_temp_e1;
reg [8:0] sum_temp_e2;
reg [8:0] sum_temp_e3;
reg [8:0] sum_temp_e4;
reg [8:0] sum_temp_e5;
wire [9:0] sum_e0temp;
wire [9:0] sum_e1temp;
wire [9:0] sum_e2temp;
wire [9:0] sum_e3temp;
wire [9:0] sum_e4temp;
wire [9:0] sum_e5temp;
wire [8:0] sum_e0temp_cal;
wire [8:0] sum_e1temp_cal;
wire [8:0] sum_e2temp_cal;
wire [8:0] sum_e3temp_cal;
wire [8:0] sum_e4temp_cal;
wire [8:0] sum_e5temp_cal;
reg [8:0] sum_e0temp_mod;
reg [8:0] sum_e1temp_mod;
reg [8:0] sum_e2temp_mod;
reg [8:0] sum_e3temp_mod;
reg [8:0] sum_e4temp_mod;
reg [8:0] sum_e5temp_mod;

reg [3:0] curr_state;
reg [3:0] next_state;
integer i;
assign p = 9'd509;
// inverse
assign mult_a0b0 = a0*b0;
assign mult_a1b1 = a1*b1;
assign mult_a2b2 = a2*b2;
assign mult_a3b3 = a3*b3;
assign mult_a4b4 = a4*b4;
assign mult_a5b5 = a5*b5;
assign mult_a0b0_cal = {mult_a0b0[17:9],1'b0} + mult_a0b0[17:9] + mult_a0b0[8:0];
assign mult_a1b1_cal = {mult_a1b1[17:9],1'b0} + mult_a1b1[17:9] + mult_a1b1[8:0];
assign mult_a2b2_cal = {mult_a2b2[17:9],1'b0} + mult_a2b2[17:9] + mult_a2b2[8:0];
assign mult_a3b3_cal = {mult_a3b3[17:9],1'b0} + mult_a3b3[17:9] + mult_a3b3[8:0];
assign mult_a4b4_cal = {mult_a4b4[17:9],1'b0} + mult_a4b4[17:9] + mult_a4b4[8:0];
assign mult_a5b5_cal = {mult_a5b5[17:9],1'b0} + mult_a5b5[17:9] + mult_a5b5[8:0];
assign mult_a0b0_cal2 = {mult_a0b0_cal[10:9],1'b0} + mult_a0b0_cal[10:9] + mult_a0b0_cal[8:0];
assign mult_a1b1_cal2 = {mult_a1b1_cal[10:9],1'b0} + mult_a1b1_cal[10:9] + mult_a1b1_cal[8:0];
assign mult_a2b2_cal2 = {mult_a2b2_cal[10:9],1'b0} + mult_a2b2_cal[10:9] + mult_a2b2_cal[8:0];
assign mult_a3b3_cal2 = {mult_a3b3_cal[10:9],1'b0} + mult_a3b3_cal[10:9] + mult_a3b3_cal[8:0];
assign mult_a4b4_cal2 = {mult_a4b4_cal[10:9],1'b0} + mult_a4b4_cal[10:9] + mult_a4b4_cal[8:0];
assign mult_a5b5_cal2 = {mult_a5b5_cal[10:9],1'b0} + mult_a5b5_cal[10:9] + mult_a5b5_cal[8:0];
assign mult_a0b0_cal3 = {mult_a0b0_cal2[9],1'b0} + mult_a0b0_cal2[9] + mult_a0b0_cal2[8:0];
assign mult_a1b1_cal3 = {mult_a1b1_cal2[9],1'b0} + mult_a1b1_cal2[9] + mult_a1b1_cal2[8:0];
assign mult_a2b2_cal3 = {mult_a2b2_cal2[9],1'b0} + mult_a2b2_cal2[9] + mult_a2b2_cal2[8:0];
assign mult_a3b3_cal3 = {mult_a3b3_cal2[9],1'b0} + mult_a3b3_cal2[9] + mult_a3b3_cal2[8:0];
assign mult_a4b4_cal3 = {mult_a4b4_cal2[9],1'b0} + mult_a4b4_cal2[9] + mult_a4b4_cal2[8:0];
assign mult_a5b5_cal3 = {mult_a5b5_cal2[9],1'b0} + mult_a5b5_cal2[9] + mult_a5b5_cal2[8:0];

assign squa_b0 = b0*b0;
assign squa_b1 = b1*b1;
assign squa_b2 = b2*b2;
assign squa_b3 = b3*b3;
assign squa_b4 = b4*b4;
assign squa_b5 = b5*b5;
assign squa_b0_cal = {squa_b0[17:9],1'b0} + squa_b0[17:9] + squa_b0[8:0];
assign squa_b1_cal = {squa_b1[17:9],1'b0} + squa_b1[17:9] + squa_b1[8:0];
assign squa_b2_cal = {squa_b2[17:9],1'b0} + squa_b2[17:9] + squa_b2[8:0];
assign squa_b3_cal = {squa_b3[17:9],1'b0} + squa_b3[17:9] + squa_b3[8:0];
assign squa_b4_cal = {squa_b4[17:9],1'b0} + squa_b4[17:9] + squa_b4[8:0];
assign squa_b5_cal = {squa_b5[17:9],1'b0} + squa_b5[17:9] + squa_b5[8:0];
assign squa_b0_cal2 = {squa_b0_cal[10:9],1'b0} + squa_b0_cal[10:9] + squa_b0_cal[8:0];
assign squa_b1_cal2 = {squa_b1_cal[10:9],1'b0} + squa_b1_cal[10:9] + squa_b1_cal[8:0];
assign squa_b2_cal2 = {squa_b2_cal[10:9],1'b0} + squa_b2_cal[10:9] + squa_b2_cal[8:0];
assign squa_b3_cal2 = {squa_b3_cal[10:9],1'b0} + squa_b3_cal[10:9] + squa_b3_cal[8:0];
assign squa_b4_cal2 = {squa_b4_cal[10:9],1'b0} + squa_b4_cal[10:9] + squa_b4_cal[8:0];
assign squa_b5_cal2 = {squa_b5_cal[10:9],1'b0} + squa_b5_cal[10:9] + squa_b5_cal[8:0];
assign squa_b0_cal3 = {squa_b0_cal2[9],1'b0} + squa_b0_cal2[9] + squa_b0_cal2[8:0];
assign squa_b1_cal3 = {squa_b1_cal2[9],1'b0} + squa_b1_cal2[9] + squa_b1_cal2[8:0];
assign squa_b2_cal3 = {squa_b2_cal2[9],1'b0} + squa_b2_cal2[9] + squa_b2_cal2[8:0];
assign squa_b3_cal3 = {squa_b3_cal2[9],1'b0} + squa_b3_cal2[9] + squa_b3_cal2[8:0];
assign squa_b4_cal3 = {squa_b4_cal2[9],1'b0} + squa_b4_cal2[9] + squa_b4_cal2[8:0];
assign squa_b5_cal3 = {squa_b5_cal2[9],1'b0} + squa_b5_cal2[9] + squa_b5_cal2[8:0];
// mult
assign mult_c0temp = stack_c[0]*mult_temp_c0;
assign mult_c1temp = stack_c[1]*mult_temp_c1;
assign mult_c2temp = stack_c[2]*mult_temp_c2;
assign mult_c3temp = stack_c[3]*mult_temp_c3;
assign mult_c4temp = stack_c[4]*mult_temp_c4;
assign mult_c5temp = stack_c[5]*mult_temp_c5;
assign mult_c0temp_cal = {mult_c0temp[17:9],1'b0} + mult_c0temp[17:9] + mult_c0temp[8:0];
assign mult_c1temp_cal = {mult_c1temp[17:9],1'b0} + mult_c1temp[17:9] + mult_c1temp[8:0];
assign mult_c2temp_cal = {mult_c2temp[17:9],1'b0} + mult_c2temp[17:9] + mult_c2temp[8:0];
assign mult_c3temp_cal = {mult_c3temp[17:9],1'b0} + mult_c3temp[17:9] + mult_c3temp[8:0];
assign mult_c4temp_cal = {mult_c4temp[17:9],1'b0} + mult_c4temp[17:9] + mult_c4temp[8:0];
assign mult_c5temp_cal = {mult_c5temp[17:9],1'b0} + mult_c5temp[17:9] + mult_c5temp[8:0];
assign mult_c0temp_cal2 = {mult_c0temp_cal[10:9],1'b0} + mult_c0temp_cal[10:9] + mult_c0temp_cal[8:0];
assign mult_c1temp_cal2 = {mult_c1temp_cal[10:9],1'b0} + mult_c1temp_cal[10:9] + mult_c1temp_cal[8:0];
assign mult_c2temp_cal2 = {mult_c2temp_cal[10:9],1'b0} + mult_c2temp_cal[10:9] + mult_c2temp_cal[8:0];
assign mult_c3temp_cal2 = {mult_c3temp_cal[10:9],1'b0} + mult_c3temp_cal[10:9] + mult_c3temp_cal[8:0];
assign mult_c4temp_cal2 = {mult_c4temp_cal[10:9],1'b0} + mult_c4temp_cal[10:9] + mult_c4temp_cal[8:0];
assign mult_c5temp_cal2 = {mult_c5temp_cal[10:9],1'b0} + mult_c5temp_cal[10:9] + mult_c5temp_cal[8:0];
assign mult_c0temp_cal3 = {mult_c0temp_cal2[9],1'b0} + mult_c0temp_cal2[9] + mult_c0temp_cal2[8:0];
assign mult_c1temp_cal3 = {mult_c1temp_cal2[9],1'b0} + mult_c1temp_cal2[9] + mult_c1temp_cal2[8:0];
assign mult_c2temp_cal3 = {mult_c2temp_cal2[9],1'b0} + mult_c2temp_cal2[9] + mult_c2temp_cal2[8:0];
assign mult_c3temp_cal3 = {mult_c3temp_cal2[9],1'b0} + mult_c3temp_cal2[9] + mult_c3temp_cal2[8:0];
assign mult_c4temp_cal3 = {mult_c4temp_cal2[9],1'b0} + mult_c4temp_cal2[9] + mult_c4temp_cal2[8:0];
assign mult_c5temp_cal3 = {mult_c5temp_cal2[9],1'b0} + mult_c5temp_cal2[9] + mult_c5temp_cal2[8:0];
// sum
assign sum_e0temp = stack_e[0]+sum_temp_e0;
assign sum_e1temp = stack_e[1]+sum_temp_e1;
assign sum_e2temp = stack_e[2]+sum_temp_e2;
assign sum_e3temp = stack_e[3]+sum_temp_e3;
assign sum_e4temp = stack_e[4]+sum_temp_e4;
assign sum_e5temp = stack_e[5]+sum_temp_e5;
assign sum_e0temp_cal = {sum_e0temp[9],1'b0} + sum_e0temp[9] + sum_e0temp[8:0];
assign sum_e1temp_cal = {sum_e1temp[9],1'b0} + sum_e1temp[9] + sum_e1temp[8:0];
assign sum_e2temp_cal = {sum_e2temp[9],1'b0} + sum_e2temp[9] + sum_e2temp[8:0];
assign sum_e3temp_cal = {sum_e3temp[9],1'b0} + sum_e3temp[9] + sum_e3temp[8:0];
assign sum_e4temp_cal = {sum_e4temp[9],1'b0} + sum_e4temp[9] + sum_e4temp[8:0];
assign sum_e5temp_cal = {sum_e5temp[9],1'b0} + sum_e5temp[9] + sum_e5temp[8:0];


GATED_OR GATED_INVERSE (.CLOCK(clk), .SLEEP_CTRL(cg_en & sleep_inverse), .RST_N(rst_n), .CLOCK_GATED(clock_gated_inverse));
GATED_OR GATED_MULT    (.CLOCK(clk), .SLEEP_CTRL(cg_en & sleep_mult),    .RST_N(rst_n), .CLOCK_GATED(clock_gated_mult));
GATED_OR GATED_SORT    (.CLOCK(clk), .SLEEP_CTRL(cg_en & sleep_sort),    .RST_N(rst_n), .CLOCK_GATED(clock_gated_sort));
GATED_OR GATED_SUM     (.CLOCK(clk), .SLEEP_CTRL(cg_en & sleep_sum),     .RST_N(rst_n), .CLOCK_GATED(clock_gated_sum));

// sleep_inverse
always@(*) begin
	if ((counter_in == 6) || (curr_state == S_INVERSE) || (curr_state == S_IDLE))
		sleep_inverse <= 0;
	else
		sleep_inverse <= 1;
end
// sleep_mult
always@(*) begin
	if ((counter_in == 6) || (counter_inverse == 8) || (curr_state == S_MULT) || (curr_state == S_IDLE))
		sleep_mult <= 0;
	else
		sleep_mult <= 1;
end
// sleep_sort
always@(*) begin
	if ((counter_in == 6) || (counter_inverse == 8) || (counter_mult == 5) || (curr_state == S_SORT) || (curr_state == S_IDLE))
		sleep_sort <= 0;
	else
		sleep_sort <= 1;
end
// sleep_sum
always@(*) begin
	if ((curr_state == S_SUM) || (curr_state == S_IDLE))
		sleep_sum <= 0;
	else
		sleep_sum <= 1;
end

// a0
always@(posedge clock_gated_inverse or negedge rst_n) begin
	if(!rst_n)
		a0 <= 0;
	else if (counter_in == 6)
		a0 <= 1;
	else if((curr_state == S_INVERSE) && (counter_inverse == 2))
		a0 <= a0;
	else if(curr_state == S_INVERSE)
		a0 <= mult_a0b0_mod;
	else
		a0 <= a0;
end
// b0
always@(posedge clock_gated_inverse or negedge rst_n) begin
	if(!rst_n)
		b0 <= 0;
	else if (counter_in == 6)
		b0 <= stack_a[0];
	else if(curr_state == S_INVERSE)
		b0 <= squa_b0_mod;
	else
		b0 <= b0;
end
// a1
always@(posedge clock_gated_inverse or negedge rst_n) begin
	if(!rst_n)
		a1 <= 0;
	else if (counter_in == 6)
		a1 <= 1;
	else if((curr_state == S_INVERSE) && (counter_inverse == 2))
		a1 <= a1;
	else if(curr_state == S_INVERSE)
		a1 <= mult_a1b1_mod;
	else
		a1 <= a1;
end
// b1
always@(posedge clock_gated_inverse or negedge rst_n) begin
	if(!rst_n)
		b1 <= 0;
	else if (counter_in == 6)
		b1 <= stack_a[1];
	else if(curr_state == S_INVERSE)
		b1 <= squa_b1_mod;
	else
		b1 <= b1;
end
// a2
always@(posedge clock_gated_inverse or negedge rst_n) begin
	if(!rst_n)
		a2 <= 0;
	else if (counter_in == 6)
		a2 <= 1;
	else if((curr_state == S_INVERSE) && (counter_inverse == 2))
		a2 <= a2;
	else if(curr_state == S_INVERSE)
		a2 <= mult_a2b2_mod;
	else
		a2 <= a2;
end
// b2
always@(posedge clock_gated_inverse or negedge rst_n) begin
	if(!rst_n)
		b2 <= 0;
	else if (counter_in == 6)
		b2 <= stack_a[2];
	else if(curr_state == S_INVERSE)
		b2 <= squa_b2_mod;
	else
		b2 <= b2;
end
// a3
always@(posedge clock_gated_inverse or negedge rst_n) begin
	if(!rst_n)
		a3 <= 0;
	else if (counter_in == 6)
		a3 <= 1;
	else if((curr_state == S_INVERSE) && (counter_inverse == 2))
		a3 <= a3;
	else if(curr_state == S_INVERSE)
		a3 <= mult_a3b3_mod;
	else
		a3 <= a3;
end
// b3
always@(posedge clock_gated_inverse or negedge rst_n) begin
	if(!rst_n)
		b3 <= 0;
	else if (counter_in == 6)
		b3 <= stack_a[3];
	else if(curr_state == S_INVERSE)
		b3 <= squa_b3_mod;
	else
		b3 <= b3;
end
// a4
always@(posedge clock_gated_inverse or negedge rst_n) begin
	if(!rst_n)
		a4 <= 0;
	else if (counter_in == 6)
		a4 <= 1;
	else if((curr_state == S_INVERSE) && (counter_inverse == 2))
		a4 <= a4;
	else if(curr_state == S_INVERSE)
		a4 <= mult_a4b4_mod;
	else
		a4 <= a4;
end
// b4
always@(posedge clock_gated_inverse or negedge rst_n) begin
	if(!rst_n)
		b4 <= 0;
	else if (counter_in == 6)
		b4 <= stack_a[4];
	else if(curr_state == S_INVERSE)
		b4 <= squa_b4_mod;
	else
		b4 <= b4;
end
// a5
always@(posedge clock_gated_inverse or negedge rst_n) begin
	if(!rst_n)
		a5 <= 0;
	else if (counter_in == 6)
		a5 <= 1;
	else if((curr_state == S_INVERSE) && (counter_inverse == 2))
		a5 <= a5;
	else if(curr_state == S_INVERSE)
		a5 <= mult_a5b5_mod;
	else
		a5 <= a5;
end
// b5
always@(posedge clock_gated_inverse or negedge rst_n) begin
	if(!rst_n)
		b5 <= 0;
	else if (counter_in == 6)
		b5 <= stack_a[5];
	else if(curr_state == S_INVERSE)
		b5 <= squa_b5_mod;
	else
		b5 <= b5;
end
// mult_a0b0_mod
always @(*) begin
	case (mult_a0b0_cal3)
		9'd511: mult_a0b0_mod = 9'd2;
		9'd510: mult_a0b0_mod = 9'd1;
		9'd509: mult_a0b0_mod = 9'd0;
		default: mult_a0b0_mod = mult_a0b0_cal3;
	endcase
end
// mult_a1b1_mod
always @(*) begin
	case (mult_a1b1_cal3)
		9'd511: mult_a1b1_mod = 9'd2;
		9'd510: mult_a1b1_mod = 9'd1;
		9'd509: mult_a1b1_mod = 9'd0;
		default: mult_a1b1_mod = mult_a1b1_cal3;
	endcase
end
// mult_a2b2_mod
always @(*) begin
	case (mult_a2b2_cal3)
		9'd511: mult_a2b2_mod = 9'd2;
		9'd510: mult_a2b2_mod = 9'd1;
		9'd509: mult_a2b2_mod = 9'd0;
		default: mult_a2b2_mod = mult_a2b2_cal3;
	endcase
end
// mult_a3b3_mod
always @(*) begin
	case (mult_a3b3_cal3)
		9'd511: mult_a3b3_mod = 9'd2;
		9'd510: mult_a3b3_mod = 9'd1;
		9'd509: mult_a3b3_mod = 9'd0;
		default: mult_a3b3_mod = mult_a3b3_cal3;
	endcase
end
// mult_a4b4_mod
always @(*) begin
	case (mult_a4b4_cal3)
		9'd511: mult_a4b4_mod = 9'd2;
		9'd510: mult_a4b4_mod = 9'd1;
		9'd509: mult_a4b4_mod = 9'd0;
		default: mult_a4b4_mod = mult_a4b4_cal3;
	endcase
end
// mult_a5b5_mod
always @(*) begin
	case (mult_a5b5_cal3)
		9'd511: mult_a5b5_mod = 9'd2;
		9'd510: mult_a5b5_mod = 9'd1;
		9'd509: mult_a5b5_mod = 9'd0;
		default: mult_a5b5_mod = mult_a5b5_cal3;
	endcase
end
// squa_b0_mod
always @(*) begin
	case (squa_b0_cal3)
		9'd511: squa_b0_mod = 9'd2;
		9'd510: squa_b0_mod = 9'd1;
		9'd509: squa_b0_mod = 9'd0;
		default: squa_b0_mod = squa_b0_cal3;
	endcase
end
// squa_b1_mod
always @(*) begin
	case (squa_b1_cal3)
		9'd511: squa_b1_mod = 9'd2;
		9'd510: squa_b1_mod = 9'd1;
		9'd509: squa_b1_mod = 9'd0;
		default: squa_b1_mod = squa_b1_cal3;
	endcase
end
// squa_b2_mod
always @(*) begin
	case (squa_b2_cal3)
		9'd511: squa_b2_mod = 9'd2;
		9'd510: squa_b2_mod = 9'd1;
		9'd509: squa_b2_mod = 9'd0;
		default: squa_b2_mod = squa_b2_cal3;
	endcase
end
// squa_b3_mod
always @(*) begin
	case (squa_b3_cal3)
		9'd511: squa_b3_mod = 9'd2;
		9'd510: squa_b3_mod = 9'd1;
		9'd509: squa_b3_mod = 9'd0;
		default: squa_b3_mod = squa_b3_cal3;
	endcase
end
// squa_b4_mod
always @(*) begin
	case (squa_b4_cal3)
		9'd511: squa_b4_mod = 9'd2;
		9'd510: squa_b4_mod = 9'd1;
		9'd509: squa_b4_mod = 9'd0;
		default: squa_b4_mod = squa_b4_cal3;
	endcase
end
// squa_b5_mod
always @(*) begin
	case (squa_b5_cal3)
		9'd511: squa_b5_mod = 9'd2;
		9'd510: squa_b5_mod = 9'd1;
		9'd509: squa_b5_mod = 9'd0;
		default: squa_b5_mod = squa_b5_cal3;
	endcase
end

// mult_temp_c0
always @(posedge clock_gated_mult or negedge rst_n) begin
	if (!rst_n)
		mult_temp_c0 <= 0;
	else if ((curr_state == S_MULT) && (counter_mult == 0))
		mult_temp_c0 <= stack_b[1];
	else if ((curr_state == S_MULT) && (counter_mult == 1))
		mult_temp_c0 <= stack_b[2];
	else if ((curr_state == S_MULT) && (counter_mult == 2))
		mult_temp_c0 <= stack_b[3];
	else if ((curr_state == S_MULT) && (counter_mult == 3))
		mult_temp_c0 <= stack_b[4];
	else if ((curr_state == S_MULT) && (counter_mult == 4))
		mult_temp_c0 <= stack_b[5];
	else
		mult_temp_c0 <= mult_temp_c0;
end
// mult_temp_c1
always @(posedge clock_gated_mult or negedge rst_n) begin
	if (!rst_n)
		mult_temp_c1 <= 0;
	else if ((curr_state == S_MULT) && (counter_mult == 0))
		mult_temp_c1 <= stack_b[0];
	else if ((curr_state == S_MULT) && (counter_mult == 1))
		mult_temp_c1 <= stack_b[2];
	else if ((curr_state == S_MULT) && (counter_mult == 2))
		mult_temp_c1 <= stack_b[3];
	else if ((curr_state == S_MULT) && (counter_mult == 3))
		mult_temp_c1 <= stack_b[4];
	else if ((curr_state == S_MULT) && (counter_mult == 4))
		mult_temp_c1 <= stack_b[5];
	else
		mult_temp_c1 <= mult_temp_c1;
end
// mult_temp_c2
always @(posedge clock_gated_mult or negedge rst_n) begin
	if (!rst_n)
		mult_temp_c2 <= 0;
	else if ((curr_state == S_MULT) && (counter_mult == 0))
		mult_temp_c2 <= stack_b[0];
	else if ((curr_state == S_MULT) && (counter_mult == 1))
		mult_temp_c2 <= stack_b[1];
	else if ((curr_state == S_MULT) && (counter_mult == 2))
		mult_temp_c2 <= stack_b[3];
	else if ((curr_state == S_MULT) && (counter_mult == 3))
		mult_temp_c2 <= stack_b[4];
	else if ((curr_state == S_MULT) && (counter_mult == 4))
		mult_temp_c2 <= stack_b[5];
	else
		mult_temp_c2 <= mult_temp_c2;
end
// mult_temp_c3
always @(posedge clock_gated_mult or negedge rst_n) begin
	if (!rst_n)
		mult_temp_c3 <= 0;
	else if ((curr_state == S_MULT) && (counter_mult == 0))
		mult_temp_c3 <= stack_b[0];
	else if ((curr_state == S_MULT) && (counter_mult == 1))
		mult_temp_c3 <= stack_b[1];
	else if ((curr_state == S_MULT) && (counter_mult == 2))
		mult_temp_c3 <= stack_b[2];
	else if ((curr_state == S_MULT) && (counter_mult == 3))
		mult_temp_c3 <= stack_b[4];
	else if ((curr_state == S_MULT) && (counter_mult == 4))
		mult_temp_c3 <= stack_b[5];
	else
		mult_temp_c3 <= mult_temp_c3;
end
// mult_temp_c4
always @(posedge clock_gated_mult or negedge rst_n) begin
	if (!rst_n)
		mult_temp_c4 <= 0;
	else if ((curr_state == S_MULT) && (counter_mult == 0))
		mult_temp_c4 <= stack_b[0];
	else if ((curr_state == S_MULT) && (counter_mult == 1))
		mult_temp_c4 <= stack_b[1];
	else if ((curr_state == S_MULT) && (counter_mult == 2))
		mult_temp_c4 <= stack_b[2];
	else if ((curr_state == S_MULT) && (counter_mult == 3))
		mult_temp_c4 <= stack_b[3];
	else if ((curr_state == S_MULT) && (counter_mult == 4))
		mult_temp_c4 <= stack_b[5];
	else
		mult_temp_c4 <= mult_temp_c4;
end
// mult_temp_c5
always @(posedge clock_gated_mult or negedge rst_n) begin
	if (!rst_n)
		mult_temp_c5 <= 0;
	else if ((curr_state == S_MULT) && (counter_mult == 0))
		mult_temp_c5 <= stack_b[0];
	else if ((curr_state == S_MULT) && (counter_mult == 1))
		mult_temp_c5 <= stack_b[1];
	else if ((curr_state == S_MULT) && (counter_mult == 2))
		mult_temp_c5 <= stack_b[2];
	else if ((curr_state == S_MULT) && (counter_mult == 3))
		mult_temp_c5 <= stack_b[3];
	else if ((curr_state == S_MULT) && (counter_mult == 4))
		mult_temp_c5 <= stack_b[4];
	else
		mult_temp_c5 <= mult_temp_c5;
end
// mult_c0temp_mod
always @(*) begin
	case (mult_c0temp_cal3)
		9'd511: mult_c0temp_mod = 9'd2;
		9'd510: mult_c0temp_mod = 9'd1;
		9'd509: mult_c0temp_mod = 9'd0;
		default: mult_c0temp_mod = mult_c0temp_cal3;
	endcase
	// if (mult_c0temp_cal3 == 9'd511)
		// mult_c0temp_mod = 9'd2;
	// else if (mult_c0temp_cal3 == 9'd510)
		// mult_c0temp_mod = 9'd1;
	// else if (mult_c0temp_cal3 == 9'd509)
		// mult_c0temp_mod = 9'd0;
	// else
		// mult_c0temp_mod = mult_c0temp_cal3;
end
// mult_c1temp_mod
always @(*) begin
	case (mult_c1temp_cal3)
		9'd511: mult_c1temp_mod = 9'd2;
		9'd510: mult_c1temp_mod = 9'd1;
		9'd509: mult_c1temp_mod = 9'd0;
		default: mult_c1temp_mod = mult_c1temp_cal3;
	endcase
end
// mult_c2temp_mod
always @(*) begin
	case (mult_c2temp_cal3)
		9'd511: mult_c2temp_mod = 9'd2;
		9'd510: mult_c2temp_mod = 9'd1;
		9'd509: mult_c2temp_mod = 9'd0;
		default: mult_c2temp_mod = mult_c2temp_cal3;
	endcase
end
// mult_c3temp_mod
always @(*) begin
	case (mult_c3temp_cal3)
		9'd511: mult_c3temp_mod = 9'd2;
		9'd510: mult_c3temp_mod = 9'd1;
		9'd509: mult_c3temp_mod = 9'd0;
		default: mult_c3temp_mod = mult_c3temp_cal3;
	endcase
end
// mult_c4temp_mod
always @(*) begin
	case (mult_c4temp_cal3)
		9'd511: mult_c4temp_mod = 9'd2;
		9'd510: mult_c4temp_mod = 9'd1;
		9'd509: mult_c4temp_mod = 9'd0;
		default: mult_c4temp_mod = mult_c4temp_cal3;
	endcase
end
// mult_c5temp_mod
always @(*) begin
	case (mult_c5temp_cal3)
		9'd511: mult_c5temp_mod = 9'd2;
		9'd510: mult_c5temp_mod = 9'd1;
		9'd509: mult_c5temp_mod = 9'd0;
		default: mult_c5temp_mod = mult_c5temp_cal3;
	endcase
end

// sum_temp_e0
always @(posedge clock_gated_sum or negedge rst_n) begin
	if (!rst_n)
		sum_temp_e0 <= 0;
	else if ((curr_state == S_SUM) && (counter_sum == 0))
		sum_temp_e0 <= stack_a[0];
	else if ((curr_state == S_SUM) && (counter_sum == 1))
		sum_temp_e0 <= stack_b[0];
	else if ((curr_state == S_SUM) && (counter_sum == 2))
		sum_temp_e0 <= stack_c[0];
	else if ((curr_state == S_SUM) && (counter_sum == 3))
		sum_temp_e0 <= stack_d[0];
	else
		sum_temp_e0 <= sum_temp_e0;
end
// sum_temp_e1
always @(posedge clock_gated_sum or negedge rst_n) begin
	if (!rst_n)
		sum_temp_e1 <= 0;
	else if ((curr_state == S_SUM) && (counter_sum == 0))
		sum_temp_e1 <= stack_a[1];
	else if ((curr_state == S_SUM) && (counter_sum == 1))
		sum_temp_e1 <= stack_b[1];
	else if ((curr_state == S_SUM) && (counter_sum == 2))
		sum_temp_e1 <= stack_c[1];
	else if ((curr_state == S_SUM) && (counter_sum == 3))
		sum_temp_e1 <= stack_d[1];
	else
		sum_temp_e1 <= sum_temp_e1;
end
// sum_temp_e2
always @(posedge clock_gated_sum or negedge rst_n) begin
	if (!rst_n)
		sum_temp_e2 <= 0;
	else if ((curr_state == S_SUM) && (counter_sum == 0))
		sum_temp_e2 <= stack_a[2];
	else if ((curr_state == S_SUM) && (counter_sum == 1))
		sum_temp_e2 <= stack_b[2];
	else if ((curr_state == S_SUM) && (counter_sum == 2))
		sum_temp_e2 <= stack_c[2];
	else if ((curr_state == S_SUM) && (counter_sum == 3))
		sum_temp_e2 <= stack_d[2];
	else
		sum_temp_e2 <= sum_temp_e2;
end
// sum_temp_e3
always @(posedge clock_gated_sum or negedge rst_n) begin
	if (!rst_n)
		sum_temp_e3 <= 0;
	else if ((curr_state == S_SUM) && (counter_sum == 0))
		sum_temp_e3 <= stack_a[3];
	else if ((curr_state == S_SUM) && (counter_sum == 1))
		sum_temp_e3 <= stack_b[3];
	else if ((curr_state == S_SUM) && (counter_sum == 2))
		sum_temp_e3 <= stack_c[3];
	else if ((curr_state == S_SUM) && (counter_sum == 3))
		sum_temp_e3 <= stack_d[3];
	else
		sum_temp_e3 <= sum_temp_e3;
end
// sum_temp_e4
always @(posedge clock_gated_sum or negedge rst_n) begin
	if (!rst_n)
		sum_temp_e4 <= 0;
	else if ((curr_state == S_SUM) && (counter_sum == 0))
		sum_temp_e4 <= stack_a[4];
	else if ((curr_state == S_SUM) && (counter_sum == 1))
		sum_temp_e4 <= stack_b[4];
	else if ((curr_state == S_SUM) && (counter_sum == 2))
		sum_temp_e4 <= stack_c[4];
	else if ((curr_state == S_SUM) && (counter_sum == 3))
		sum_temp_e4 <= stack_d[4];
	else
		sum_temp_e4 <= sum_temp_e4;
end
// sum_temp_e5
always @(posedge clock_gated_sum or negedge rst_n) begin
	if (!rst_n)
		sum_temp_e5 <= 0;
	else if ((curr_state == S_SUM) && (counter_sum == 0))
		sum_temp_e5 <= stack_a[5];
	else if ((curr_state == S_SUM) && (counter_sum == 1))
		sum_temp_e5 <= stack_b[5];
	else if ((curr_state == S_SUM) && (counter_sum == 2))
		sum_temp_e5 <= stack_c[5];
	else if ((curr_state == S_SUM) && (counter_sum == 3))
		sum_temp_e5 <= stack_d[5];
	else
		sum_temp_e5 <= sum_temp_e5;
end
// sum_e0temp_mod
always @(*) begin
	case (sum_e0temp_cal)
		9'd511: sum_e0temp_mod = 9'd2;
		9'd510: sum_e0temp_mod = 9'd1;
		9'd509: sum_e0temp_mod = 9'd0;
		default: sum_e0temp_mod = sum_e0temp_cal;
	endcase
end
// sum_e1temp_mod
always @(*) begin
	case (sum_e1temp_cal)
		9'd511: sum_e1temp_mod = 9'd2;
		9'd510: sum_e1temp_mod = 9'd1;
		9'd509: sum_e1temp_mod = 9'd0;
		default: sum_e1temp_mod = sum_e1temp_cal;
	endcase
end
// sum_e2temp_mod
always @(*) begin
	case (sum_e2temp_cal)
		9'd511: sum_e2temp_mod = 9'd2;
		9'd510: sum_e2temp_mod = 9'd1;
		9'd509: sum_e2temp_mod = 9'd0;
		default: sum_e2temp_mod = sum_e2temp_cal;
	endcase
end
// sum_e3temp_mod
always @(*) begin
	case (sum_e3temp_cal)
		9'd511: sum_e3temp_mod = 9'd2;
		9'd510: sum_e3temp_mod = 9'd1;
		9'd509: sum_e3temp_mod = 9'd0;
		default: sum_e3temp_mod = sum_e3temp_cal;
	endcase
end
// sum_e4temp_mod
always @(*) begin
	case (sum_e4temp_cal)
		9'd511: sum_e4temp_mod = 9'd2;
		9'd510: sum_e4temp_mod = 9'd1;
		9'd509: sum_e4temp_mod = 9'd0;
		default: sum_e4temp_mod = sum_e4temp_cal;
	endcase
end
// sum_e5temp_mod
always @(*) begin
	case (sum_e5temp_cal)
		9'd511: sum_e5temp_mod = 9'd2;
		9'd510: sum_e5temp_mod = 9'd1;
		9'd509: sum_e5temp_mod = 9'd0;
		default: sum_e5temp_mod = sum_e5temp_cal;
	endcase
end

// mode_store
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		mode_store <= 0;
	else if(in_valid && counter_in == 0)
		mode_store <= in_mode;
	else
		mode_store <= mode_store;
end
// stack_a
always@(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (i = 0; i < 6; i = i + 1) begin
			stack_a[i] <= 0;
		end
	end
	else if (in_valid == 1) begin
		stack_a[5] <= in_data;
		for (i = 0; i < 5; i = i + 1) begin
			stack_a[i] <= stack_a[i+1];
		end
	end
	else begin
		for (i = 0; i < 6; i = i + 1) begin
			stack_a[i] <= stack_a[i];
		end
	end
end
// stack_b
always@(posedge clock_gated_inverse or negedge rst_n) begin
	if (!rst_n) begin
		for (i = 0; i < 6; i = i + 1) begin
			stack_b[i] <= 0;
		end
	end
	else if (counter_in == 6) begin
		for (i = 0; i < 6; i = i + 1) begin
			stack_b[i] <= stack_a[i];
		end
	end
	else if (curr_state == S_INVERSE) begin
		stack_b[0] <= mult_a0b0_mod; // a0;
		stack_b[1] <= mult_a1b1_mod; // a1;
		stack_b[2] <= mult_a2b2_mod; // a2;
		stack_b[3] <= mult_a3b3_mod; // a3;
		stack_b[4] <= mult_a4b4_mod; // a4;
		stack_b[5] <= mult_a5b5_mod; // a5;
	end
	else begin
		for (i = 0; i < 6; i = i + 1) begin
			stack_b[i] <= stack_b[i];
		end
	end
end
// stack_c
always@(posedge clock_gated_mult or negedge rst_n) begin
	if (!rst_n) begin
		for (i = 0; i < 6; i = i + 1) begin
			stack_c[i] <= 0;
		end
	end
	else if (counter_in == 6) begin
		for (i = 0; i < 6; i = i + 1) begin
			stack_c[i] <= stack_a[i];
		end
	end
	else if (counter_inverse == 8) begin
		stack_c[0] <= mult_a0b0_mod;
		stack_c[1] <= mult_a1b1_mod;
		stack_c[2] <= mult_a2b2_mod;
		stack_c[3] <= mult_a3b3_mod;
		stack_c[4] <= mult_a4b4_mod;
		stack_c[5] <= mult_a5b5_mod;
	end
	else if ((curr_state == S_MULT) && (counter_mult == 0))begin
		stack_c[0] <= 9'd1;
		stack_c[1] <= 9'd1;
		stack_c[2] <= 9'd1;
		stack_c[3] <= 9'd1;
		stack_c[4] <= 9'd1;
		stack_c[5] <= 9'd1;
	end
	else if (curr_state == S_MULT) begin
		stack_c[0] <= mult_c0temp_mod;
		stack_c[1] <= mult_c1temp_mod;
		stack_c[2] <= mult_c2temp_mod;
		stack_c[3] <= mult_c3temp_mod;
		stack_c[4] <= mult_c4temp_mod;
		stack_c[5] <= mult_c5temp_mod;
	end
	else begin
		for (i = 0; i < 6; i = i + 1) begin
			stack_c[i] <= stack_c[i];
		end
	end
end
// stack_d
always@(posedge clock_gated_sort or negedge rst_n) begin
	if (!rst_n) begin
		for (i = 0; i < 6; i = i + 1) begin
			stack_d[i] <= 0;
		end
	end
	else if (counter_in == 6) begin
		for (i = 0; i < 6; i = i + 1) begin
			stack_d[i] <= stack_a[i];
		end
	end
	else if (counter_inverse == 8) begin
		stack_d[0] <= mult_a0b0_mod;
		stack_d[1] <= mult_a1b1_mod;
		stack_d[2] <= mult_a2b2_mod;
		stack_d[3] <= mult_a3b3_mod;
		stack_d[4] <= mult_a4b4_mod;
		stack_d[5] <= mult_a5b5_mod;
	end
	else if (counter_mult == 5) begin
		stack_d[0] <= mult_c0temp_mod;
		stack_d[1] <= mult_c1temp_mod;
		stack_d[2] <= mult_c2temp_mod;
		stack_d[3] <= mult_c3temp_mod;
		stack_d[4] <= mult_c4temp_mod;
		stack_d[5] <= mult_c5temp_mod;
	end
	else if ((curr_state == S_SORT) && (counter_sort == 0))begin
		stack_d[0] <= stack_c[0];
		stack_d[1] <= stack_c[1];
		stack_d[2] <= stack_c[2];
		stack_d[3] <= stack_c[3];
		stack_d[4] <= stack_c[4];
		stack_d[5] <= stack_c[5];
	end
	else if ((curr_state == S_SORT) && (counter_sort[0] == 1)) begin
		stack_d[0] <= (stack_d[0] > stack_d[1]) ? stack_d[1] : stack_d[0];
		stack_d[1] <= (stack_d[0] > stack_d[1]) ? stack_d[0] : stack_d[1];
		stack_d[2] <= (stack_d[2] > stack_d[3]) ? stack_d[3] : stack_d[2];
		stack_d[3] <= (stack_d[2] > stack_d[3]) ? stack_d[2] : stack_d[3];
		stack_d[4] <= (stack_d[4] > stack_d[5]) ? stack_d[5] : stack_d[4];
		stack_d[5] <= (stack_d[4] > stack_d[5]) ? stack_d[4] : stack_d[5];
	end
	else if ((curr_state == S_SORT) && (counter_sort[0] == 0)) begin
		stack_d[1] <= (stack_d[1] > stack_d[2]) ? stack_d[2] : stack_d[1];
		stack_d[2] <= (stack_d[1] > stack_d[2]) ? stack_d[1] : stack_d[2];
		stack_d[3] <= (stack_d[3] > stack_d[4]) ? stack_d[4] : stack_d[3];
		stack_d[4] <= (stack_d[3] > stack_d[4]) ? stack_d[3] : stack_d[4];
	end
	else begin
		for (i = 0; i < 6; i = i + 1) begin
			stack_d[i] <= stack_d[i];
		end
	end
end
// stack_e
always@(posedge clock_gated_sum or negedge rst_n) begin
	if (!rst_n) begin
		for (i = 0; i < 6; i = i + 1) begin
			stack_e[i] <= 0;
		end
	end
	else if ((curr_state == S_SUM) && (counter_sum == 0))begin
		stack_e[0] <= 9'd0;
		stack_e[1] <= 9'd0;
		stack_e[2] <= 9'd0;
		stack_e[3] <= 9'd0;
		stack_e[4] <= 9'd0;
		stack_e[5] <= 9'd0;
	end
	else if (curr_state == S_SUM) begin
		stack_e[0] <= sum_e0temp_mod;
		stack_e[1] <= sum_e1temp_mod;
		stack_e[2] <= sum_e2temp_mod;
		stack_e[3] <= sum_e3temp_mod;
		stack_e[4] <= sum_e4temp_mod;
		stack_e[5] <= sum_e5temp_mod;
	end
	else begin
		for (i = 0; i < 6; i = i + 1) begin
			stack_e[i] <= stack_e[i];
		end
	end
end
// counter
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		counter <= 0;
	else
		counter <= counter + 1;
end
// counter_in
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        counter_in <= 0;
    else if (in_valid)
		counter_in <= counter_in + 1;
	else
		counter_in <= 0;
end
// counter_inverse
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        counter_inverse <= 0;
	else if (curr_state == S_IDLE)
		counter_inverse <= 0;
    else if (curr_state == S_INVERSE)
		counter_inverse <= counter_inverse + 1;
	else
		counter_inverse <= counter_inverse;
end
// counter_mult
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        counter_mult <= 0;
	else if (curr_state == S_IDLE)
		counter_mult <= 0;
    else if (curr_state == S_MULT)
		counter_mult <= counter_mult + 1;
	else
		counter_mult <= counter_mult;
end
// counter_sort
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        counter_sort <= 0;
	else if (curr_state == S_IDLE)
		counter_sort <= 0;
    else if (curr_state == S_SORT)
		counter_sort <= counter_sort + 1;
	else
		counter_sort <= counter_sort;
end
// counter_sum
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        counter_sum <= 0;
	else if (curr_state == S_IDLE)
		counter_sum <= 0;
    else if (curr_state == S_SUM)
		counter_sum <= counter_sum + 1;
	else
		counter_sum <= counter_sum;
end
// counter_out
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        counter_out <= 0;
	// else if (curr_state == S_IDLE)
	else if (curr_state == S_INPUT)
		counter_out <= 0;
    else if (curr_state == S_OUTPUT)
		counter_out <= counter_out + 1;
	else
		counter_out <= counter_out;
end
// out_valid
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		out_valid <= 0;
	else if (curr_state == S_OUTPUT)
		out_valid <= 1;
	else
		out_valid <= 0;
end
// always @(*) begin
	// if (curr_state == S_OUTPUT)
		// out_valid <= 1;
	// else
		// out_valid <= 0;
// end
// out_data
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		out_data <= 0;
	else if ((curr_state == S_OUTPUT) && (counter_out == 0))
		out_data <= stack_e[0];
	else if ((curr_state == S_OUTPUT) && (counter_out == 1))
		out_data <= stack_e[1];
	else if ((curr_state == S_OUTPUT) && (counter_out == 2))
		out_data <= stack_e[2];
	else if ((curr_state == S_OUTPUT) && (counter_out == 3))
		out_data <= stack_e[3];
	else if ((curr_state == S_OUTPUT) && (counter_out == 4))
		out_data <= stack_e[4];
	else if ((curr_state == S_OUTPUT) && (counter_out == 5))
		out_data <= stack_e[5];
	else
		out_data <= 0;
end
// always @(*) begin
	// if ((curr_state == S_OUTPUT) && (counter_out == 0))
		// out_data <= stack_e[0];
	// else if ((curr_state == S_OUTPUT) && (counter_out == 1))
		// out_data <= stack_e[1];
	// else if ((curr_state == S_OUTPUT) && (counter_out == 2))
		// out_data <= stack_e[2];
	// else if ((curr_state == S_OUTPUT) && (counter_out == 3))
		// out_data <= stack_e[3];
	// else if ((curr_state == S_OUTPUT) && (counter_out == 4))
		// out_data <= stack_e[4];
	// else if ((curr_state == S_OUTPUT) && (counter_out == 5))
		// out_data <= stack_e[5];
	// else
		// out_data <= 0;
// end
// curr_state
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		curr_state <= S_IDLE;
	else
		curr_state <= next_state;
end
// next_state
always@(*) begin
	case(curr_state)
	S_IDLE: begin // 0
		if (in_valid)
			next_state = S_INPUT;
		else
			next_state = S_IDLE;
	end
	S_INPUT: begin // 1
		if ((counter_in == 6) && (mode_store[0] == 1))
			next_state = S_INVERSE;
		else if ((counter_in == 6) && (mode_store[1] == 1))
			next_state = S_MULT;
		else if ((counter_in == 6) && (mode_store[2] == 1))
			next_state = S_SORT;
		else if (counter_in == 6)
			next_state = S_SUM;
		else
			next_state = S_INPUT;
	end
	S_INVERSE: begin // 2
		if ((counter_inverse == 8) && (mode_store[1] == 1))
			next_state = S_MULT;
		else if ((counter_inverse == 8) && (mode_store[2] == 1))
			next_state = S_SORT;
		else if (counter_inverse == 8)
			next_state = S_SUM;
		else
			next_state = S_INVERSE;
	end
	S_MULT: begin // 3
		if ((counter_mult == 5) && (mode_store[2] == 1))
			next_state = S_SORT;
		else if (counter_mult == 5)
			next_state = S_SUM;
		else
			next_state = S_MULT;
	end
	S_SORT: begin // 4
		if (counter_sort == 6)
			next_state = S_SUM;
		else
			next_state = S_SORT;
	end
	S_SUM: begin // 6
		if (counter_sum == 4)
			next_state = S_OUTPUT;
		else
			next_state = S_SUM;
	end
	S_OUTPUT: begin // 7
		if (counter_out == 5)
			next_state = S_IDLE;
		else
			next_state = S_OUTPUT;
	end
	default: next_state = curr_state;
	endcase
end

endmodule