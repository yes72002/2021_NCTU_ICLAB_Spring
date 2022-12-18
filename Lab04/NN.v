
// -----------------------------------------------------------------------------------
// File name        : NN_1.v
// Title            : 2021 ICLAB Spring Course
// Lab04            : Artificial Neural Network
// Developers       : NCTU
// -----------------------------------------------------------------------------------
// Revision History :
// NN_1        : 01 pass, 02 pass, 03 pass. But too many cycle.
// (2021.03.28): area = 405175, timing = 0.00 = 19.58-19.58 , slack(MET), execution cycle = 9
// -----------------------------------------------------------------------------------
// Project	:	Mod. Author	:	Mod. Date
// ICLAB	:	Yuan-Jin Li	:	2021.03.28
// -----------------------------------------------------------------------------------
//synopsys translate_off
`include "/usr/synthesis/dw/sim_ver/DW_fp_add.v"
`include "/usr/synthesis/dw/sim_ver/DW_fp_mult.v"
//synopsys translate_on

module NN(
	// Input signals
	clk,
	rst_n,
	in_valid_d,
	in_valid_t,
	in_valid_w1,
	in_valid_w2,
	data_point,
	target,
	weight1,
	weight2,
	// Output signals
	out_valid,
	out
);
//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------

// IEEE floating point paramenters
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch = 2;

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION
//---------------------------------------------------------------------
input  clk, rst_n, in_valid_d, in_valid_t, in_valid_w1, in_valid_w2;
input [inst_sig_width+inst_exp_width:0] data_point, target;
input [inst_sig_width+inst_exp_width:0] weight1, weight2;
output reg	out_valid;
output reg [inst_sig_width+inst_exp_width:0] out;

//---------------------------------------------------------------------
//   WIRE AND REG DECLARATION
//---------------------------------------------------------------------
reg [inst_sig_width+inst_exp_width:0] w1[11:0]; // weight1
reg [inst_sig_width+inst_exp_width:0] w2[2:0];  // weight2
reg [inst_sig_width+inst_exp_width:0] s[3:0];   // data_point
reg [inst_sig_width+inst_exp_width:0] t0;       // target
wire [inst_sig_width+inst_exp_width:0] ReLU;
reg [inst_sig_width+inst_exp_width:0] y[3:0];   // y10,	y11, y12, y20
wire dReLU;
reg [2:0] g;                                    // g10,	g11, g12
reg flag;
reg [2:0] count_in;
reg [5:0] count_out;
reg [inst_sig_width+inst_exp_width:0] mult0_a,mult1_a,mult2_a,mult3_a;
reg [inst_sig_width+inst_exp_width:0] mult0_b,mult1_b,mult2_b,mult3_b;
wire [inst_sig_width+inst_exp_width:0] mult0_z,mult1_z,mult2_z,mult3_z;
reg [inst_sig_width+inst_exp_width:0] add0_a,add1_a,add3_a;
reg [inst_sig_width+inst_exp_width:0] add0_b,add1_b,add3_b;
wire [inst_sig_width+inst_exp_width:0] add0_z,add1_z,add2_z,add3_z;
reg [inst_sig_width+inst_exp_width:0] minus_learning;
reg [inst_sig_width+inst_exp_width:0] minus_learning_diff20;
reg [inst_sig_width+inst_exp_width:0] minus_learning_diff20_s21;
reg [inst_sig_width+inst_exp_width:0] minus_learning_diff20_s22;

integer i;
//---------------------------------------------------------------------
//   DesignWare
//---------------------------------------------------------------------
// flag
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		flag <= 0;
	else if (in_valid_w1)
		flag <= 0;
	else if (in_valid_d)
		flag <= 1;
	else
		flag <= flag;
end
//count_in
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		count_in <= 0;
	else if (in_valid_d)
		count_in <= count_in + 1;
	// else if (!in_valid_d)
		// count_in <= 0;
	else
		count_in <= 0;
end
// w1
always@(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (i = 0; i < 12; i = i + 1) begin
			w1[i] <= 0;
		end
	end
	else if (in_valid_w1) begin
		w1[11] <= weight1;
		for (i = 0; i < 11; i = i + 1) begin
			w1[i] <= w1[i+1];
		end
	end
	else if (count_out == 11) begin
		w1[0] <= add0_z;
		w1[4] <= add1_z;
		w1[8] <= add3_z;
	end
	else if (count_out == 12) begin
		w1[1] <= add0_z;
		w1[5] <= add1_z;
		w1[9] <= add3_z;
	end
	else if (count_out == 13) begin
		w1[2] <= add0_z;
		w1[6] <= add1_z;
		w1[10] <= add3_z;
	end
	else if (count_out == 14) begin
		w1[3] <= add0_z;
		w1[7] <= add1_z;
		w1[11] <= add3_z;
	end
	else begin
		for (i = 0; i < 12; i = i + 1) begin
			w1[i] <= w1[i];
		end
	end
end
// w2
always@(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		w2[0] <= 0;
		w2[1] <= 0;
		w2[2] <= 0;
	end
	else if (in_valid_w2) begin
		w2[2] <= weight2;
		w2[1] <= w2[2];
		w2[0] <= w2[1];
	end
	else if (count_out == 10) begin
		w2[0] <= add0_z;
	end
	else if (count_out == 15) begin
		w2[1] <= add0_z;
		w2[2] <= add1_z;
	end
	else begin
		w2[0] <= w2[0];
		w2[1] <= w2[1];
		w2[2] <= w2[2];
	end
end
// s
always@(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		s[3] <= 0;
		s[2] <= 0;
		s[1] <= 0;
		s[0] <= 0;
	end
	else if (in_valid_d) begin
		s[3] <= data_point;
		s[2] <= s[3];
		s[1] <= s[2];
		s[0] <= s[1];
	end
	else begin
		s[3] <= s[3];
		s[2] <= s[2];
		s[1] <= s[1];
		s[0] <= s[0];
	end
end
// t0
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		t0 <= 0;
	else if (in_valid_t)
		t0 <= target;
	else
		t0 <= t0;
end

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) mult0(.a(mult0_a), .b(mult0_b), .rnd(3'b000), .z(mult0_z));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) mult1(.a(mult1_a), .b(mult1_b), .rnd(3'b000), .z(mult1_z));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) mult2(.a(mult2_a), .b(mult2_b), .rnd(3'b000), .z(mult2_z));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) mult3(.a(mult3_a), .b(mult3_b), .rnd(3'b000), .z(mult3_z));
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) add0(.a(add0_a), .b(add0_b), .rnd(3'b000), .z(add0_z));
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) add1(.a(add1_a), .b(add1_b), .rnd(3'b000), .z(add1_z));
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) add2(.a(add0_z), .b(add1_z), .rnd(3'b000), .z(add2_z));
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) add3(.a(add3_a), .b(add3_b), .rnd(3'b000), .z(add3_z));
assign ReLU = (add2_z[31]==1) ? 0 : add2_z;
assign dReLU = (add2_z[31]==1) ? 0 : 1;

// mult0, mult1, mult2, mult3
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		mult0_a <= 0;
		mult1_a <= 0;
		mult2_a <= 0;
		mult3_a <= 0;
		mult0_b <= 0;
		mult1_b <= 0;
		mult2_b <= 0;
		mult3_b <= 0;
	end
	else if(count_out == 0) begin
		mult0_a <= w1[0];
		mult1_a <= w1[1];
		mult2_a <= w1[2];
		mult3_a <= w1[3];
		mult0_b <= s[0];
		mult1_b <= s[1];
		mult2_b <= s[2];
		mult3_b <= s[3];
	end
	else if(count_out == 1) begin
		mult0_a <= w1[4];
		mult1_a <= w1[5];
		mult2_a <= w1[6];
		mult3_a <= w1[7];
		mult0_b <= s[0];
		mult1_b <= s[1];
		mult2_b <= s[2];
		mult3_b <= s[3];
	end
	else if(count_out == 2) begin
		mult0_a <= w1[8];
		mult1_a <= w1[9];
		mult2_a <= w1[10];
		mult3_a <= w1[11];
		mult0_b <= s[0];
		mult1_b <= s[1];
		mult2_b <= s[2];
		mult3_b <= s[3];
	end
	else if(count_out == 4) begin
		mult0_a <= w2[0];
		mult1_a <= w2[1];
		mult2_a <= w2[2];
		mult3_a <= 32'hbf800000;// -1
		mult0_b <= y[0];
		mult1_b <= y[1];
		mult2_b <= ReLU;
		mult3_b <= 32'h3A83126F;//0.001
	end
	else if(count_out == 7) begin
		mult0_a <= add0_z;
		mult1_a <= add0_z;
		mult2_a <= add0_z;
		mult3_a <= add0_z;
		mult0_b <= w2[0];
		mult1_b <= w2[1];
		mult2_b <= w2[2];
		mult3_b <= minus_learning;
	end
	else if(count_out == 8) begin
		mult0_a <= (g[0]==0) ? 0 : mult0_z;
		mult1_a <= (g[1]==0) ? 0 : mult1_z;
		mult2_a <= (g[2]==0) ? 0 : mult2_z;
		mult3_a <= mult3_z; // -leanring*diff20
		mult0_b <= minus_learning;
		mult1_b <= minus_learning;
		mult2_b <= minus_learning;
		mult3_b <= y[0];
	end
	else if(count_out == 9) begin
		mult0_a <= mult0_z; // -leanring*diff10
		mult1_a <= mult1_z; // -leanring*diff11
		mult2_a <= mult2_z; // -leanring*diff12
		mult3_a <= minus_learning_diff20; // -leanring*diff20
		mult0_b <= s[0];
		mult1_b <= s[0];
		mult2_b <= s[0];
		mult3_b <= y[1];
	end
	else if(count_out == 10) begin
		// mult0_a <= mult0_z; // -leanring*diff10
		// mult1_a <= mult1_z; // -leanring*diff11
		// mult2_a <= mult2_z; // -leanring*diff12
		mult3_a <= minus_learning_diff20; // -leanring*diff20
		mult0_b <= s[1];
		mult1_b <= s[1];
		mult2_b <= s[1];
		mult3_b <= y[2];
	end
	else if(count_out == 11) begin
		// mult0_a <= mult0_z; // -leanring*diff10
		// mult1_a <= mult1_z; // -leanring*diff11
		// mult2_a <= mult2_z; // -leanring*diff12
		// mult3_a <= minus_learning_diff20; // -leanring*diff20
		mult0_b <= s[2];
		mult1_b <= s[2];
		mult2_b <= s[2];
		// mult3_b <= y[2];
	end
	else if(count_out == 12) begin
		// mult0_a <= mult0_z; // -leanring*diff10
		// mult1_a <= mult1_z; // -leanring*diff11
		// mult2_a <= mult2_z; // -leanring*diff12
		// mult3_a <= minus_learning_diff20; // -leanring*diff20
		mult0_b <= s[3];
		mult1_b <= s[3];
		mult2_b <= s[3];
		// mult3_b <= y[2];
	end
	else begin
		mult0_a <= mult0_a;
		mult1_a <= mult1_a;
		mult2_a <= mult2_a;
		mult3_a <= mult3_a;
		mult0_b <= mult0_b;
		mult1_b <= mult1_b;
		mult2_b <= mult2_b;
		mult3_b <= mult3_b;
	end
end
// add0, add1, add2, add3
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		add0_a <= 0;
		add1_a <= 0;
		add3_a <= 0;
		add0_b <= 0;
		add1_b <= 0;
		add3_b <= 0;
	end
	else if(count_out == 0) begin
		add0_a <= 0;
		add1_a <= 0;
		add3_a <= 0;
		add0_b <= 0;
		add1_b <= 0;
		add3_b <= 0;
	end
	else if(count_out == 1) begin
		add0_a <= mult0_z;
		add1_a <= mult2_z;
		add0_b <= mult1_z;
		add1_b <= mult3_z;
	end
	else if(count_out == 2) begin
		add0_a <= mult0_z;
		add1_a <= mult2_z;
		add0_b <= mult1_z;
		add1_b <= mult3_z;
	end
	else if(count_out == 3) begin
		add0_a <= mult0_z;
		add1_a <= mult2_z;
		add0_b <= mult1_z;
		add1_b <= mult3_z;
	end
	else if(count_out == 5) begin
		add0_a <= mult0_z;
		add1_a <= mult2_z;
		add0_b <= mult1_z;
		add1_b <= 0;
	end
	else if(count_out == 6) begin
		add0_a <= add2_z;
		add0_b <= {~t0[31],t0[30:0]};
	end
	else if(count_out == 9) begin
		add0_a <= mult3_z;
		add0_b <= w2[0];
	end
	else if(count_out == 10) begin
		add0_a <= mult0_z;
		add1_a <= mult1_z;
		add3_a <= mult2_z;
		add0_b <= w1[0];
		add1_b <= w1[4];
		add3_b <= w1[8];
	end
	else if(count_out == 11) begin
		add0_a <= mult0_z;
		add1_a <= mult1_z;
		add3_a <= mult2_z;
		add0_b <= w1[1];
		add1_b <= w1[5];
		add3_b <= w1[9];
	end
	else if(count_out == 12) begin
		add0_a <= mult0_z;
		add1_a <= mult1_z;
		add3_a <= mult2_z;
		add0_b <= w1[2];
		add1_b <= w1[6];
		add3_b <= w1[10];
	end
	else if(count_out == 13) begin
		add0_a <= mult0_z;
		add1_a <= mult1_z;
		add3_a <= mult2_z;
		add0_b <= w1[3];
		add1_b <= w1[7];
		add3_b <= w1[11];
	end
	else if(count_out == 14) begin
		add0_a <= minus_learning_diff20_s21;
		add1_a <= minus_learning_diff20_s22;
		add0_b <= w2[1];
		add1_b <= w2[2];
	end
	else begin
		add0_a <= add0_a;
		add1_a <= add1_a;
		add3_a <= add3_a;
		add0_b <= add0_b;
		add1_b <= add1_b;
		add3_b <= add3_b;
	end
end
// y10, y11, y12, y20
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		y[0] <= 0;
		y[1] <= 0;
		y[2] <= 0;
		y[3] <= 0;
	end
	else if(count_out == 2) begin
		y[0] <= ReLU;
	end
	else if(count_out == 3) begin
		y[1] <= ReLU;
	end
	else if(count_out == 4) begin
		y[2] <= ReLU;
	end
	else if(count_out == 6) begin
		y[3] <= add2_z;
	end
	else begin
		y[0] <= y[0];
		y[1] <= y[1];
		y[2] <= y[2];
		y[3] <= y[3];
	end
end
// g10, g11, g12
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		g[0] <= 0;
		g[1] <= 0;
		g[2] <= 0;
	end
	else if(count_out == 2) begin
		g[0] <= dReLU;
	end
	else if(count_out == 3) begin
		g[1] <= dReLU;
	end
	else if(count_out == 4) begin
		g[2] <= dReLU;
	end
	else begin
		g[0] <= g[0];
		g[1] <= g[1];
		g[2] <= g[2];
	end
end
// minus_learning
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		minus_learning <= 0;	
	end
	else if(count_out == 5) begin
		minus_learning <= mult3_z;
	end
	else begin
		minus_learning <= minus_learning;
	end
end
// minus_learning_diff20
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		minus_learning_diff20 <= 0;	
	end
	else if(count_out == 8) begin
		minus_learning_diff20 <= mult3_z;
	end
	else begin
		minus_learning_diff20 <= minus_learning_diff20;
	end
end
// minus_learning_diff20_s21
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		minus_learning_diff20_s21 <= 0;	
	end
	else if(count_out == 10) begin
		minus_learning_diff20_s21 <= mult3_z;
	end
	else begin
		minus_learning_diff20_s21 <= minus_learning_diff20_s21;
	end
end
// minus_learning_diff20_s22
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		minus_learning_diff20_s22 <= 0;	
	end
	else if(count_out == 11) begin
		minus_learning_diff20_s22 <= mult3_z;
	end
	else begin
		minus_learning_diff20_s22 <= minus_learning_diff20_s22;
	end
end

//count_out
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		count_out <= 0;
	// else if ((in_valid_w1 == 0) && (in_valid_d == 0))
		// count_out <= count_out + 1;
	// else
		// count_out <= 0;
	else if(flag == 0)
		count_out <= 0;
	else if (count_in == 3)
		count_out <= 0;
	else
		count_out <= count_out + 1;
end
//out_valid
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		out_valid <= 0;
	else if (count_out == 9)
		out_valid <= 1;
	else
		out_valid <= 0;
end
//out
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		out <= 0;
	else if (count_out == 9)
		out <= y[3];
	else
		out <= 0;
end

endmodule



