module CLK_1_MODULE(// Input signals
			clk_1,
			clk_2,
			rst_n,
			in_valid,
			in,
			mode,
			operator,
			// Output signals,
			clk1_in_0,   clk1_in_1,  clk1_in_2,  clk1_in_3,  clk1_in_4,  clk1_in_5,  clk1_in_6,  clk1_in_7,  clk1_in_8,  clk1_in_9,
			clk1_in_10, clk1_in_11, clk1_in_12, clk1_in_13, clk1_in_14, clk1_in_15, clk1_in_16, clk1_in_17, clk1_in_18, clk1_in_19,
			clk1_op_0,   clk1_op_1,  clk1_op_2,  clk1_op_3,  clk1_op_4,  clk1_op_5,  clk1_op_6,  clk1_op_7,  clk1_op_8,  clk1_op_9,
			clk1_op_10, clk1_op_11, clk1_op_12, clk1_op_13, clk1_op_14, clk1_op_15, clk1_op_16, clk1_op_17, clk1_op_18, clk1_op_19,
			clk1_expression_0, clk1_expression_1, clk1_expression_2,
			clk1_operators_0,   clk1_operators_1,  clk1_operators_2,
			clk1_mode,
			clk1_control_signal,
			clk1_flag_0,   clk1_flag_1,  clk1_flag_2,  clk1_flag_3,  clk1_flag_4,  clk1_flag_5,  clk1_flag_6,
			clk1_flag_7,   clk1_flag_8,  clk1_flag_9, clk1_flag_10, clk1_flag_11, clk1_flag_12, clk1_flag_13,
			clk1_flag_14, clk1_flag_15, clk1_flag_16, clk1_flag_17, clk1_flag_18, clk1_flag_19
			);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk_1, clk_2, rst_n, in_valid, operator, mode;
input [2:0] in;

output reg [2:0]  clk1_in_0,  clk1_in_1,  clk1_in_2,  clk1_in_3,  clk1_in_4,  clk1_in_5,  clk1_in_6,  clk1_in_7,  clk1_in_8,  clk1_in_9,
				 clk1_in_10, clk1_in_11, clk1_in_12, clk1_in_13, clk1_in_14, clk1_in_15, clk1_in_16, clk1_in_17, clk1_in_18, clk1_in_19;
output reg  clk1_op_0,  clk1_op_1,  clk1_op_2,  clk1_op_3,  clk1_op_4,  clk1_op_5,  clk1_op_6,  clk1_op_7,  clk1_op_8,  clk1_op_9,
		   clk1_op_10, clk1_op_11, clk1_op_12, clk1_op_13, clk1_op_14, clk1_op_15, clk1_op_16, clk1_op_17, clk1_op_18, clk1_op_19;
output reg [59:0] clk1_expression_0, clk1_expression_1, clk1_expression_2;
output reg [19:0] clk1_operators_0,   clk1_operators_1,  clk1_operators_2;
output reg clk1_mode;
output reg [19 :0] clk1_control_signal;
output  clk1_flag_0,  clk1_flag_1,  clk1_flag_2,  clk1_flag_3,  clk1_flag_4,  clk1_flag_5,  clk1_flag_6,
        clk1_flag_7,  clk1_flag_8,  clk1_flag_9, clk1_flag_10, clk1_flag_11, clk1_flag_12, clk1_flag_13,
       clk1_flag_14, clk1_flag_15, clk1_flag_16, clk1_flag_17, clk1_flag_18, clk1_flag_19;
//---------------------------------------------------------------------
//   DESIGN
//---------------------------------------------------------------------
//---------------------------------------------------------------------
//   TA hint:
//	  Please write a synchroniser using syn_XOR or doubole flop synchronizer design in CLK_1_MODULE to generate a flag signal to inform CLK_2_MODULE that it can read input signal from CLK_1_MODULE.
//	  You don't need to include syn_XOR.v file or synchronizer.v file by yourself, we have already done that in top module CDC.v
//	  example:
//   syn_XOR syn_1(.IN(inflag_clk1),.OUT(clk1_flag_0),.TX_CLK(clk_1),.RX_CLK(clk_2),.RST_N(rst_n));             
//---------------------------------------------------------------------	
assign clk1_flag_1 = in_valid;

syn_XOR syn_1(.IN(in_valid), .OUT(clk1_flag_0), .TX_CLK(clk_1), .RX_CLK(clk_2), .RST_N(rst_n));

// clk1_in_0
always@(posedge clk_1) begin
	if(in_valid)
		clk1_in_0 <= in;
	else
		clk1_in_0 <= clk1_in_0;
end
// clk1_op_0
always@(posedge clk_1) begin
	if(in_valid)
		clk1_op_0 <= operator;
	else
		clk1_op_0 <= clk1_op_0;
end
// clk1_mode
always@(posedge clk_1) begin
	if(in_valid)
		clk1_mode <= mode;
	else
		clk1_mode <= clk1_mode;
end


endmodule


module CLK_2_MODULE(// Input signals
			clk_2,
			clk_3,
			rst_n,
			clk1_in_0,   clk1_in_1,  clk1_in_2,  clk1_in_3,  clk1_in_4,  clk1_in_5,  clk1_in_6,  clk1_in_7,  clk1_in_8,  clk1_in_9, 
			clk1_in_10, clk1_in_11, clk1_in_12, clk1_in_13, clk1_in_14, clk1_in_15, clk1_in_16, clk1_in_17, clk1_in_18, clk1_in_19,
			clk1_op_0, clk1_op_1, clk1_op_2, clk1_op_3, clk1_op_4, clk1_op_5, clk1_op_6, clk1_op_7, clk1_op_8, clk1_op_9, 
			clk1_op_10, clk1_op_11, clk1_op_12, clk1_op_13, clk1_op_14, clk1_op_15, clk1_op_16, clk1_op_17, clk1_op_18, clk1_op_19,
			clk1_expression_0, clk1_expression_1, clk1_expression_2,
			clk1_operators_0, clk1_operators_1, clk1_operators_2,
			clk1_mode,
			clk1_control_signal,
			clk1_flag_0, clk1_flag_1, clk1_flag_2, clk1_flag_3, clk1_flag_4, clk1_flag_5, clk1_flag_6, clk1_flag_7, 
			clk1_flag_8, clk1_flag_9, clk1_flag_10, clk1_flag_11, clk1_flag_12, clk1_flag_13, clk1_flag_14, 
			clk1_flag_15, clk1_flag_16, clk1_flag_17, clk1_flag_18, clk1_flag_19,
			// output signals
			clk2_out_0, clk2_out_1, clk2_out_2, clk2_out_3,
			clk2_mode,
			clk2_control_signal,
			clk2_flag_0, clk2_flag_1, clk2_flag_2, clk2_flag_3, clk2_flag_4, clk2_flag_5, clk2_flag_6, clk2_flag_7
			);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------			
input clk_2, clk_3, rst_n;
input [2:0] clk1_in_0, clk1_in_1, clk1_in_2, clk1_in_3, clk1_in_4, clk1_in_5, clk1_in_6, clk1_in_7, clk1_in_8, clk1_in_9, 
	 	    clk1_in_10, clk1_in_11, clk1_in_12, clk1_in_13, clk1_in_14, clk1_in_15, clk1_in_16, clk1_in_17, clk1_in_18, clk1_in_19;
input clk1_op_0, clk1_op_1, clk1_op_2, clk1_op_3, clk1_op_4, clk1_op_5, clk1_op_6, clk1_op_7, clk1_op_8, clk1_op_9, 
  	  clk1_op_10, clk1_op_11, clk1_op_12, clk1_op_13, clk1_op_14, clk1_op_15, clk1_op_16, clk1_op_17, clk1_op_18, clk1_op_19;
input [59:0] clk1_expression_0, clk1_expression_1, clk1_expression_2;
input [19:0] clk1_operators_0, clk1_operators_1, clk1_operators_2;
input clk1_mode;
input [19 :0] clk1_control_signal;
input clk1_flag_0, clk1_flag_1, clk1_flag_2, clk1_flag_3, clk1_flag_4, clk1_flag_5, clk1_flag_6, clk1_flag_7, 
	  clk1_flag_8, clk1_flag_9, clk1_flag_10, clk1_flag_11, clk1_flag_12, clk1_flag_13, clk1_flag_14, 
	  clk1_flag_15, clk1_flag_16, clk1_flag_17, clk1_flag_18, clk1_flag_19;

output reg [63:0] clk2_out_0, clk2_out_1, clk2_out_2, clk2_out_3;
output reg clk2_mode;
output reg [8:0] clk2_control_signal;
output clk2_flag_0, clk2_flag_1, clk2_flag_2, clk2_flag_3, clk2_flag_4, clk2_flag_5, clk2_flag_6, clk2_flag_7;

parameter S_IDLE   = 'd0;
parameter S_INPUT  = 'd1;
parameter S_CALCU  = 'd2;
parameter S_OUTPUT = 'd3;
parameter EQUAL = 'd0;
parameter CALCU = 'd1;
parameter SHIFT = 'd2;
parameter ADD = 'd0;
parameter SUB = 'd1;
parameter MUL = 'd2;
parameter ABS = 'd3;
parameter AT  = 'd4;

reg [ 2:0] s0[19:0];
reg signed [30:0] s1[19:2];
reg op[19:0];
reg [1:0] cal[19:0];
reg mode_store;
reg [4:0]counter_input;
reg [4:0]counter_calcu;
reg [1:0]curr_state;
reg [1:0]next_state;

integer i;
//---------------------------------------------------------------------
// DESIGN
//---------------------------------------------------------------------
//---------------------------------------------------------------------
//   TA hint:
//	  Please write a synchroniser using syn_XOR or doubole flop synchronizer design in CLK_2_MODULE to generate a flag signal to inform CLK_3_MODULE that it can read input signal from CLK_2_MODULE.
//	  You don't need to include syn_XOR.v file or synchronizer.v file by yourself, we have already done that in top module CDC.v
//	  example:
//   syn_XOR syn_2(.IN(inflag_clk2),.OUT(clk2_flag_0),.TX_CLK(clk_2),.RX_CLK(clk_3),.RST_N(rst_n));             
//---------------------------------------------------------------------	
syn_XOR syn_2(.IN(curr_state == S_OUTPUT),.OUT(clk2_flag_0),.TX_CLK(clk_2),.RX_CLK(clk_3),.RST_N(rst_n));

// clk2_out_0
always@(posedge clk_2 or negedge rst_n) begin
	if (!rst_n)
		clk2_out_0 <= 0;
	else if (curr_state == S_OUTPUT) begin
		clk2_out_0 <= s1[19];
	end
	else
		clk2_out_0 <= clk2_out_0;
end
// s0[19:0]
always@(posedge clk_2 or negedge rst_n) begin
	if (!rst_n) begin
		for (i = 0; i < 20; i = i + 1) begin
			s0[i] <= 0;
		end
	end
	else if(clk1_flag_0) begin
		s0[19] <= clk1_in_0;
		for (i = 0; i < 19; i = i + 1) begin
			s0[i] <= s0[i+1];
		end
	end
	else begin
		for (i = 0; i < 20; i = i + 1) begin
			s0[i] <= s0[i];
		end
	end
end
// s1[2] ~ s1[19]
genvar gs1;
generate
for (gs1 = 2; gs1 < 20; gs1 = gs1 + 1) begin: s1_loop
	always@(posedge clk_2 or negedge rst_n) begin
		if (!rst_n)
			s1[gs1] <= 0;
		else if((curr_state == S_CALCU) && (counter_calcu == 0)) begin
			if (cal[gs1] == CALCU) begin
				if (mode_store == 0) begin// prefix(1,0,0)
					case (s0[gs1-2])
						ADD: s1[gs1] <= s0[gs1-1] + s0[gs1];
						SUB: s1[gs1] <= s0[gs1-1] - s0[gs1];
						MUL: s1[gs1] <= s0[gs1-1] * s0[gs1];
						ABS: s1[gs1] <= ((s0[gs1-1] + s0[gs1]) < 0) ? -(s0[gs1-1] + s0[gs1]) : (s0[gs1-1] + s0[gs1]);
						AT : s1[gs1] <= (s0[gs1-1] - s0[gs1]) << 1;
						default: s1[gs1] <= 0;
					endcase
				end
				else begin // postfix(0,0,1)
					case (s0[gs1])
						ADD: s1[gs1] <= s0[gs1-2] + s0[gs1-1];
						SUB: s1[gs1] <= s0[gs1-2] - s0[gs1-1];
						MUL: s1[gs1] <= s0[gs1-2] * s0[gs1-1];
						ABS: s1[gs1] <= ((s0[gs1-2] + s0[gs1-1]) < 0) ? -(s0[gs1-2] + s0[gs1-1]) : (s0[gs1-2] + s0[gs1-1]);
						AT : s1[gs1] <= (s0[gs1-2] - s0[gs1-1]) << 1;
						default: s1[gs1] <= 0;
					endcase
				end
			end
			else if (cal[gs1] == SHIFT)
				s1[gs1] <= s0[gs1-2];
			else // (cal[gs1] == EQUAL)
				s1[gs1] <= s0[gs1];
		end
		else if (curr_state == S_CALCU) begin
			if (cal[gs1] == CALCU) begin
				if (mode_store == 0) begin// prefix(1,0,0)
					case (s1[gs1-2])
						ADD: s1[gs1] <= s1[gs1-1] + s1[gs1];
						SUB: s1[gs1] <= s1[gs1-1] - s1[gs1];
						MUL: s1[gs1] <= s1[gs1-1] * s1[gs1];
						ABS: s1[gs1] <= ((s1[gs1-1] + s1[gs1]) < 0) ? -(s1[gs1-1] + s1[gs1]) : (s1[gs1-1] + s1[gs1]);
						AT : s1[gs1] <= (s1[gs1-1] - s1[gs1]) << 1;
						default: s1[gs1] <= 0;
					endcase
				end
				else begin // postfix(0,0,1)
					case (s1[gs1])
						ADD: s1[gs1] <= s1[gs1-2] + s1[gs1-1];
						SUB: s1[gs1] <= s1[gs1-2] - s1[gs1-1];
						MUL: s1[gs1] <= s1[gs1-2] * s1[gs1-1];
						ABS: s1[gs1] <= ((s1[gs1-2] + s1[gs1-1]) < 0) ? -(s1[gs1-2] + s1[gs1-1]) : (s1[gs1-2] + s1[gs1-1]);
						AT : s1[gs1] <= (s1[gs1-2] - s1[gs1-1]) << 1;
						default: s1[gs1] <= 0;
					endcase
				end
			end
			else if (cal[gs1] == SHIFT)
				s1[gs1] <= s1[gs1-2];
			else // (cal[gs1] == EQUAL)
				s1[gs1] <= s1[gs1];
		end
		else
			s1[gs1] <= s1[gs1];
	end
end
endgenerate
// op[0]
always@(posedge clk_2 or negedge rst_n) begin
	if (!rst_n)
		op[0] <= 0;
	else if (clk1_flag_0)
		op[0] <= op[1];
	else if (curr_state == S_CALCU) begin
		if (cal[0] == CALCU) // impossible
			op[0] <= 0;
		else if (cal[0] == SHIFT)
			op[0] <= 0;
		else // (cal[0] == EQUAL)
			op[0] <= op[0];
	end
	else
		op[0] <= op[0];
end
// op[1]
always@(posedge clk_2 or negedge rst_n) begin
	if (!rst_n)
		op[1] <= 0;
	else if (clk1_flag_0)
		op[1] <= op[2];
	else if (curr_state == S_CALCU) begin
		if (cal[1] == CALCU) // impossible
			op[1] <= 0;
		else if (cal[1] == SHIFT)
			op[1] <= 0;
		else // (cal[1] == EQUAL)
			op[1] <= op[1];
	end
	else
		op[1] <= op[1];
end
// op[2] ~ op[18]
genvar gj;
generate
for (gj = 2; gj < 19; gj = gj + 1) begin: op_loop
	always@(posedge clk_2 or negedge rst_n) begin
		if (!rst_n)
			op[gj] <= 0;
		else if (clk1_flag_0)
			op[gj] <= op[gj+1];
		else if (curr_state == S_CALCU) begin
			if (cal[gj] == CALCU)
				op[gj] <= 0;
			else if (cal[gj] == SHIFT)
				op[gj] <= op[gj-2];
			else // (cal[gj] == EQUAL)
				op[gj] <= op[gj];
		end
		else
			op[gj] <= op[gj];
	end
end
endgenerate
// op[19]
always@(posedge clk_2 or negedge rst_n) begin
	if (!rst_n)
		op[19] <= 0;
	else if (clk1_flag_0)
		op[19] <= clk1_op_0;
	else if (curr_state == S_CALCU) begin
		if (cal[19] == CALCU)
			op[19] <= 0;
		else if (cal[19] == SHIFT) // impossible
			op[19] <= op[17];
		else // (cal[19] == EQUAL)
			op[19] <= op[19];
	end
	else
		op[19] <= op[19];
end
// cal[0]
// always@(*) begin
always@(cal[1]) begin
	if ((cal[1] == CALCU) || (cal[1] == SHIFT))
		cal[0] = SHIFT;
	else
		cal[0] = EQUAL;
end
// cal[1]
// always@(*) begin
always@(cal[2]) begin
	if ((cal[2] == CALCU) || (cal[2] == SHIFT))
		cal[1] = SHIFT;
	else
		cal[1] = EQUAL;
end
// cal[2] ~ cal[18]
genvar gi;
generate
for (gi = 2; gi < 19; gi = gi + 1) begin: cal_loop
	always@(*) begin
		if ((cal[gi+1] == CALCU) || (cal[gi+1] == SHIFT))                cal[gi] = SHIFT;
		else begin
			if (mode_store == 0) begin // prefix(1,0,0)
				if ((op[gi-2] == 1) && (op[gi-1] == 0) && (op[gi] == 0)) cal[gi] = CALCU;
				else                                                     cal[gi] = EQUAL;
			end
			else begin // postfix(0,0,1)
				if ((op[gi-2] == 0) && (op[gi-1] == 0) && (op[gi] == 1)) cal[gi] = CALCU;
				else                                                     cal[gi] = EQUAL;
			end
		end
	end
end
endgenerate	
// cal[19]
always@(*) begin
	if (mode_store == 0) begin // prefix(1,0,0)
		if ((op[17] == 1) && (op[18] == 0) && (op[19] == 0)) cal[19] = CALCU;
		else                                                 cal[19] = EQUAL;
	end
	else begin // postfix(0,0,1)
		if ((op[17] == 0) && (op[18] == 0) && (op[19] == 1)) cal[19] = CALCU;
		else                                                 cal[19] = EQUAL;
	end
end
// mode_store
always@(posedge clk_2 or negedge rst_n) begin
	if (!rst_n)
		mode_store <= 0;
	else if ((clk1_flag_0) && (counter_input == 0)) begin
		mode_store <= clk1_mode;
	end
	else begin
		mode_store <= mode_store;
	end
end
// counter_input
always@(posedge clk_2 or negedge rst_n)begin
    if(!rst_n)
        counter_input <= 0;
    else if (curr_state == S_IDLE)
		counter_input <= 0;
	else if (curr_state == S_INPUT) begin
		if (clk1_flag_0)
			counter_input <= 0;
		else
			counter_input <= counter_input + 1;
	end
	else
		counter_input <= counter_input;
end
// counter_calcu
always@(posedge clk_2 or negedge rst_n)begin
    if(!rst_n)
        counter_calcu <= 0;
    else if (curr_state == S_IDLE)
		counter_calcu <= 0;
	else if (curr_state == S_CALCU)
		counter_calcu <= counter_calcu + 1;
	else
		counter_calcu <= counter_calcu;
end
// curr_state
always@(posedge clk_2 or negedge rst_n)begin
    if(!rst_n)
		curr_state <= S_IDLE;
    else
		curr_state <= next_state;
end
// next_state
always@(*)begin
    case(curr_state)
        S_IDLE : begin
			if (clk1_flag_0)
				next_state = S_INPUT;
			else
				next_state = S_IDLE;
		end
        S_INPUT: begin
			// if (counter_input == 4)
			// if (clk1_flag_1 == 0) // fail pattern WEI2, so greedy
			// if ((clk1_flag_1 == 0) && (counter_input > 2))
			if ((clk1_flag_1 == 0) && (counter_input == 3))
				next_state = S_CALCU;
			else
				next_state = S_INPUT;
		end
        S_CALCU  : begin
			if (~( cal[0] ||  cal[1] ||  cal[2] ||  cal[3] ||  cal[4] ||  cal[5] ||  cal[6] ||  cal[7] ||  cal[8] ||  cal[9] ||
			    cal[10] || cal[11] || cal[12] || cal[13] || cal[14] || cal[15] || cal[16] || cal[17] || cal[18] || cal[19]))
				next_state = S_OUTPUT;
			else
				next_state = S_CALCU;
		end
        S_OUTPUT: next_state = S_IDLE;
        default:  next_state = S_IDLE;
    endcase
end


endmodule


module CLK_3_MODULE(// Input signals
			clk_3,
			rst_n,
			clk2_out_0, clk2_out_1, clk2_out_2, clk2_out_3,
			clk2_mode,
			clk2_control_signal,
			clk2_flag_0, clk2_flag_1, clk2_flag_2, clk2_flag_3, clk2_flag_4, clk2_flag_5, clk2_flag_6, clk2_flag_7,
			// Output signals
			out_valid,
			out
			);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------			
input clk_3, rst_n;
input [63:0] clk2_out_0, clk2_out_1, clk2_out_2, clk2_out_3;
input clk2_mode;
input [8:0] clk2_control_signal;
input clk2_flag_0, clk2_flag_1, clk2_flag_2, clk2_flag_3, clk2_flag_4, clk2_flag_5, clk2_flag_6, clk2_flag_7;

output reg out_valid;
output reg [63:0]out;
//---------------------------------------------------------------------
//  DESIGN
//---------------------------------------------------------------------
// out_valid
always@(*) begin
	if(clk2_flag_0)
		out_valid = 1'b1;
	else
		out_valid = 0;
end
// out
always@(*) begin
	if(clk2_flag_0)
		out = clk2_out_0;
	else
		out = 0;
end

endmodule

