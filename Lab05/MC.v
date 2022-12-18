//  set CYCLE 9.0, area = 601006
//  set CYCLE 8.2, area = 619664
//  set CYCLE 8.1, area = violated
//  set CYCLE 8.0, area = violated


module MC(
	//io
	clk,
	rst_n,
	in_valid,
	in_data,
	size,
	action,
	out_valid,
	out_data
);
//io
input	clk;
input	rst_n;
input	in_valid;
input	[30:0]in_data;
input	[1:0]size;
input	[2:0]action;
output	reg out_valid;
output	reg[30:0]out_data;

//PARAMETER setting
parameter S_IDLE         = 3'b000; // 0
parameter S_INPUT        = 3'b001; // 1
parameter S_CALCULATE    = 3'b010; // 2
parameter S_WRITE        = 3'b011; // 3
parameter S_OUTPUT_WRITE = 3'b100; // 4
parameter S_OUTPUT_0     = 3'b101; // 5
parameter S_STORE        = 3'b110; // 6
parameter SETUP     = 3'b000; // 0
parameter ADDITION  = 3'b001; // 1
parameter MULT      = 3'b010; // 2
parameter TRANSPOSE = 3'b011; // 3
parameter MIRROR    = 3'b100; // 4
parameter ROTATE    = 3'b101; // 5
parameter ZONE1     = 3'b110; // 6
parameter ZONE2     = 3'b111; // 7
// wire table
wire [1:0] p_4[2:0][3:0];
wire [3:0] p_16[2:0][15:0];
wire [5:0] p_64[2:0][63:0];
wire [7:0] p_256[2:0][255:0];
// logic declaration
reg[8:0] count;
reg [2:0] action_store;
reg [1:0] size_store;
reg [4:0] length;
reg [8:0] size_all;
reg [30:0] in_data_store;
reg in_valid1, in_valid2;
reg [7:0] A1, A2;
reg [30:0] D1, D2;
wire[30:0] Q1, Q2;
reg [5:0] count_mult;
wire [2:0] size_1; // reg more area
wire [31:0] tmp_add;
reg [31:0] tmp_mult [0:15];
reg [65:0] sum_mult;
wire [32:0] sum_mult2; 
// FSM
reg[2:0] curr_state;
reg[2:0] next_state;
integer i;
// SRAM (WEN = 0 -> WRITE, WEN = 1 -> READ)
RA1SH U_SRAM1(.Q(Q1),.CLK(clk),.CEN(1'b0),.WEN(in_valid1),.A(A1),.D(D1),.OEN(1'b0));
RA1SH U_SRAM2(.Q(Q2),.CLK(clk),.CEN(1'b0),.WEN(in_valid2),.A(A2),.D(D2),.OEN(1'b0));

assign size_1 = size_store + 1;
assign tmp_add = Q1 + in_data_store;
assign sum_mult2 = sum_mult[30:0] + sum_mult[61:31] + sum_mult[65:62];


// action_store
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		action_store <= 0;
	else if(in_valid && count == 0)
		action_store <= action;
	else
		action_store <= action_store;
end
// size_store
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		size_store <= 0;
	else if(in_valid && (action == SETUP) && (count == 0))
		size_store <= size;
	else
		size_store <= size_store;
end
// length
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		length <= 0;
	else if(in_valid && (action == SETUP) && (count == 0))
		length <= (6'd2 << size);
	else
		length <= length;
end
// size_all
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		size_all <= 0;
	else if((curr_state == S_INPUT) && (action_store == SETUP))
		size_all <= count;
	else
		size_all <= size_all;
end
// in_data_store
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		in_data_store <= 0;
	else if(in_valid)
		in_data_store <= in_data;
	else
		in_data_store <= in_data_store;
end
// tmp_mult
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		for(i = 0; i < 16; i = i + 1)
			tmp_mult[i] <= 0;
	else begin
		if(curr_state == S_STORE && count_mult > 1)
			tmp_mult[count_mult - 2] <= Q2;
		else
			tmp_mult[count_mult - 1] <= tmp_mult[count_mult - 1];
	end
end
// sum_mult
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		sum_mult <= 0;
	else begin
		if(curr_state == S_CALCULATE && count_mult != 0)
			sum_mult <= sum_mult + Q1 * tmp_mult[count_mult - 1];
		else
			sum_mult <= 0;
	end
end
// count
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		count <= 0;
	else begin
		case(curr_state)
		S_IDLE: begin
			if(in_valid)
				count <= count + 1;
			else
				count <= 0;
		end
		S_INPUT: begin
			if(next_state == S_CALCULATE || next_state == S_OUTPUT_WRITE || next_state == S_STORE)
				count <= 0;
		    else
				count <= count + 1;
		end
		S_CALCULATE: begin
			if(count == size_all)
				count <= 0;
			else if(action_store == MULT && (count_mult <= length  && (next_state != S_STORE)))
				count <= count;
			else
				count <= count + 1;
		end
		S_WRITE: count <= count + 1;
		S_OUTPUT_WRITE: count <= count + 1;
		default:  count <= count;
		endcase
	end
end
// count_mult
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		count_mult <= 0;
	else begin
		if(curr_state == S_CALCULATE || curr_state == S_STORE) begin
			if(count_mult == length + 1)
				count_mult <= 0;
			else
				count_mult <= count_mult + 1;
		end
		else
			count_mult <= 0;
	end
end
// A1
always@(*) begin
	case(curr_state)
		S_CALCULATE: begin
			if(action_store == MULT) 
				A1 = (count_mult << size_1) + (count % length);
			else
				A1 = count;
		end
		S_WRITE:
			A1 = count - 1;
		S_OUTPUT_WRITE: begin
			if((action_store == ADDITION) || (action_store == MULT))
				A1 = count - 1;
			else
				A1 = count;
		end
		default:A1 = count;
	endcase
end
// A2
always@(*) begin
	case(curr_state)
	S_INPUT:     if(action_store == ADDITION) A2 = count - 1;
				 else                         A2 = count;
	S_CALCULATE: case(action_store)
				 MULT     : A2 = count ;
				 TRANSPOSE:	begin	case(size_store)
									0: A2 = p_4[0]  [count-1];
									1: A2 = p_16[0] [count-1];
									2: A2 = p_64[0] [count-1];
									3: A2 = p_256[0][count-1];
									default: A2 = 0;	
									endcase
							end
				 MIRROR   :	begin	case(size_store)
									0: A2 = p_4[1]  [count-1];
									1: A2 = p_16[1] [count-1];
									2: A2 = p_64[1] [count-1];
									3: A2 = p_256[1][count-1];
									default: A2 = 0;
									endcase
							end
				 ROTATE   : begin	case(size_store)
									0: A2 = p_4[2]  [count-1];
									1: A2 = p_16[2] [count-1];
									2: A2 = p_64[2] [count-1];
									3: A2 = p_256[2][count-1];
									default: A2 = 0;
									endcase
							end
				 default:   A2 = count;
				 endcase
	S_STORE:     A2 = count_mult + ((count >> size_1) * length) - 1;
	default:     A2 = count;
	endcase
end
// D1
always@(*) begin 
	case(curr_state)
	S_WRITE:        D1 = Q2;
	S_OUTPUT_WRITE: D1 = Q2;
	default:        D1 = in_data;
	endcase
end
// D2
always@(*) begin
	case(curr_state)
	S_IDLE: begin
		if(in_valid) begin
			if(action == MULT)
				D2 = in_data;
			else
				D2 = Q1;
		end
		else
			D2 = Q1;
	end
	S_INPUT: begin
		if(action_store == ADDITION)
			D2 = ((tmp_add[30:0] + tmp_add[31]) == 31'h7FFFFFFF)? 0 : tmp_add[30:0] + tmp_add[31];
		else
			D2 = in_data;
	end
	S_CALCULATE: begin
		if(action_store == MULT)
			// D2 = ((sum_mult[30:0] + sum_mult[45:31]) == 31'h7FFFFFFF)? 0 : sum_mult[30:0] + sum_mult[45:31];
			// D2 = ((sum_mult[30:0] + sum_mult[61:31] + sum_mult[65:62]) == 31'h7FFFFFFF)? 0 : sum_mult[30:0] + sum_mult[61:31] + sum_mult[65:62];
			D2 = ((sum_mult2[30:0] + sum_mult2[32:31]) == 31'h7FFFFFFF)? 0 : sum_mult2[30:0] + sum_mult2[32:31];

		 else
			D2 = Q1;
	end
	default: D2 = Q1;
	endcase
end
// in_valid1
always@(*) begin
	case(curr_state)
	S_IDLE: begin
		if(in_valid) begin
			if(action == SETUP)
				in_valid1 = 1'b0;
			else
				in_valid1 = 1'b1;
		end
		else    in_valid1 = 1'b1;
	end
	S_INPUT: begin
		if(in_valid && action_store == SETUP)
			in_valid1 = 1'b0;
		else
			in_valid1 = 1'b1;
	end
	S_WRITE: 
		in_valid1 = 1'b0;
	S_OUTPUT_WRITE: begin
		if((action_store == ADDITION) || (action_store == MULT))
			in_valid1 = 1'b0;
		else
			in_valid1 = 1'b1;
	end
	default: in_valid1 = 1'b1;
	endcase
end
// in_valid2
always@(*) begin
	case(curr_state)
	S_IDLE: begin
		if(in_valid) begin
			if((action == ADDITION) || (action == MULT))
				in_valid2 = 1'b0;
			else in_valid2 = 1'b1;
		end
		else
			in_valid2 = 1'b1;
	end
	S_INPUT: begin
		if((action_store == ADDITION) || (action_store == MULT && count != 11'd256))
			in_valid2 = 1'b0;
		else
			in_valid2 = 1'b1;
	end
	S_CALCULATE: begin
		case(action_store)
		MULT: if(count_mult == length + 1 && count != 11'd256) in_valid2 = 1'b0;
			  else in_valid2 = 1'b1;
		default: in_valid2 = 1'b0;
		endcase
	end
	S_STORE: in_valid2 = 1'b1;
	default: in_valid2 = 1'b1;
	endcase
end

//out_valid
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		out_valid <= 0;
	else if (curr_state == S_OUTPUT_WRITE) begin
		if ((count) && (count <= size_all))
			out_valid <= 1;
		else
			out_valid <= 0;
	end
	else if (curr_state == S_OUTPUT_0)
		out_valid <= 1;
	else
		out_valid <= 0;
end
//out_data
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		out_data <= 0;
	else if((count) && (count <= size_all) && (curr_state == S_OUTPUT_WRITE)) begin
		case(action_store)
		SETUP: out_data <= Q1;
		default: out_data <= Q2;
		endcase
	end
	else
		out_data <= 0;
end
//FSM
always@(posedge	clk or negedge rst_n) begin
	if(!rst_n)
		curr_state <= S_IDLE;
	else
		curr_state <= next_state;
end
// next_state	
always@(*) begin
	case(curr_state)
		S_IDLE:	begin
			if(in_valid) next_state = S_INPUT;
			else         next_state = S_IDLE;
		end
		S_INPUT: begin
			if(!in_valid) begin
				if(action_store == SETUP  || action_store == ADDITION)
					next_state = S_OUTPUT_WRITE;
				else if(action_store == MULT)
					next_state = S_STORE;
				else
					next_state = S_CALCULATE;
			end
			else
				next_state = S_INPUT;
		end
		S_CALCULATE: begin
			case(action_store)
			MULT:      if(count == size_all) next_state = S_OUTPUT_WRITE;
					   else if(((count + 1) % length) == 0 && count != 0 && count_mult == length + 1)
					                         next_state = S_STORE;
					   else                  next_state = S_CALCULATE;
			TRANSPOSE: if(count == size_all) next_state = S_WRITE;
					   else					 next_state = S_CALCULATE;
			MIRROR:    if(count == size_all) next_state = S_WRITE;
					   else					 next_state = S_CALCULATE;
			ROTATE:    if(count == size_all) next_state = S_WRITE;
					   else					 next_state = S_CALCULATE;
			default:                         next_state = curr_state;
			endcase
		end
		S_WRITE: begin
			if(count == size_all)
				next_state = S_OUTPUT_0;
			else
				next_state = S_WRITE;
		end
		S_OUTPUT_WRITE: begin
			if(count == size_all)
				next_state = S_IDLE;
			else
				next_state = S_OUTPUT_WRITE;
		end
		S_OUTPUT_0:
				next_state = S_IDLE;
		S_STORE: begin
			if(count_mult == length + 1)
				next_state = S_CALCULATE;
		    else
				next_state = S_STORE;
		end
		default: next_state = curr_state;
	endcase
end


assign p_4[0][00] = 0;
assign p_4[0][01] = 2;
assign p_4[0][02] = 1;
assign p_4[0][03] = 3;
assign p_4[1][00] = 1;
assign p_4[1][01] = 0;
assign p_4[1][02] = 3;
assign p_4[1][03] = 2;
assign p_16[0][00] = 00;
assign p_16[0][01] = 04;
assign p_16[0][02] = 08;
assign p_16[0][03] = 12;
assign p_16[0][04] = 01;
assign p_16[0][05] = 05;
assign p_16[0][06] = 09;
assign p_16[0][07] = 13;
assign p_16[0][08] = 02;
assign p_16[0][09] = 06;
assign p_16[0][10] = 10;
assign p_16[0][11] = 14;
assign p_16[0][12] = 03;
assign p_16[0][13] = 07;
assign p_16[0][14] = 11;
assign p_16[0][15] = 15;
assign p_16[1][00] = 03;
assign p_16[1][01] = 02;
assign p_16[1][02] = 01;
assign p_16[1][03] = 00;
assign p_16[1][04] = 07;
assign p_16[1][05] = 06;
assign p_16[1][06] = 05;
assign p_16[1][07] = 04;
assign p_16[1][08] = 11;
assign p_16[1][09] = 10;
assign p_16[1][10] = 09;
assign p_16[1][11] = 08;
assign p_16[1][12] = 15;
assign p_16[1][13] = 14;
assign p_16[1][14] = 13;
assign p_16[1][15] = 12;
assign p_64[0][00] = 0;
assign p_64[0][01] = 8;
assign p_64[0][02] = 16;
assign p_64[0][03] = 24;
assign p_64[0][04] = 32;
assign p_64[0][05] = 40;
assign p_64[0][06] = 48;
assign p_64[0][07] = 56;
assign p_64[0][08] = 1;
assign p_64[0][09] = 9;
assign p_64[0][10] = 17;
assign p_64[0][11] = 25;
assign p_64[0][12] = 33;
assign p_64[0][13] = 41;
assign p_64[0][14] = 49;
assign p_64[0][15] = 57;
assign p_64[0][16] = 2;
assign p_64[0][17] = 10;
assign p_64[0][18] = 18;
assign p_64[0][19] = 26;
assign p_64[0][20] = 34;
assign p_64[0][21] = 42;
assign p_64[0][22] = 50;
assign p_64[0][23] = 58;
assign p_64[0][24] = 3;
assign p_64[0][25] = 11;
assign p_64[0][26] = 19;
assign p_64[0][27] = 27;
assign p_64[0][28] = 35;
assign p_64[0][29] = 43;
assign p_64[0][30] = 51;
assign p_64[0][31] = 59;
assign p_64[0][32] = 4;
assign p_64[0][33] = 12;
assign p_64[0][34] = 20;
assign p_64[0][35] = 28;
assign p_64[0][36] = 36;
assign p_64[0][37] = 44;
assign p_64[0][38] = 52;
assign p_64[0][39] = 60;
assign p_64[0][40] = 5;
assign p_64[0][41] = 13;
assign p_64[0][42] = 21;
assign p_64[0][43] = 29;
assign p_64[0][44] = 37;
assign p_64[0][45] = 45;
assign p_64[0][46] = 53;
assign p_64[0][47] = 61;
assign p_64[0][48] = 6;
assign p_64[0][49] = 14;
assign p_64[0][50] = 22;
assign p_64[0][51] = 30;
assign p_64[0][52] = 38;
assign p_64[0][53] = 46;
assign p_64[0][54] = 54;
assign p_64[0][55] = 62;
assign p_64[0][56] = 7;
assign p_64[0][57] = 15;
assign p_64[0][58] = 23;
assign p_64[0][59] = 31;
assign p_64[0][60] = 39;
assign p_64[0][61] = 47;
assign p_64[0][62] = 55;
assign p_64[0][63] = 63;
assign p_64[1][00] = 7;
assign p_64[1][01] = 6;
assign p_64[1][02] = 5;
assign p_64[1][03] = 4;
assign p_64[1][04] = 3;
assign p_64[1][05] = 2;
assign p_64[1][06] = 1;
assign p_64[1][07] = 0;
assign p_64[1][08] = 15;
assign p_64[1][09] = 14;
assign p_64[1][10] = 13;
assign p_64[1][11] = 12;
assign p_64[1][12] = 11;
assign p_64[1][13] = 10;
assign p_64[1][14] = 9;
assign p_64[1][15] = 8;
assign p_64[1][16] = 23;
assign p_64[1][17] = 22;
assign p_64[1][18] = 21;
assign p_64[1][19] = 20;
assign p_64[1][20] = 19;
assign p_64[1][21] = 18;
assign p_64[1][22] = 17;
assign p_64[1][23] = 16;
assign p_64[1][24] = 31;
assign p_64[1][25] = 30;
assign p_64[1][26] = 29;
assign p_64[1][27] = 28;
assign p_64[1][28] = 27;
assign p_64[1][29] = 26;
assign p_64[1][30] = 25;
assign p_64[1][31] = 24;
assign p_64[1][32] = 39;
assign p_64[1][33] = 38;
assign p_64[1][34] = 37;
assign p_64[1][35] = 36;
assign p_64[1][36] = 35;
assign p_64[1][37] = 34;
assign p_64[1][38] = 33;
assign p_64[1][39] = 32;
assign p_64[1][40] = 47;
assign p_64[1][41] = 46;
assign p_64[1][42] = 45;
assign p_64[1][43] = 44;
assign p_64[1][44] = 43;
assign p_64[1][45] = 42;
assign p_64[1][46] = 41;
assign p_64[1][47] = 40;
assign p_64[1][48] = 55;
assign p_64[1][49] = 54;
assign p_64[1][50] = 53;
assign p_64[1][51] = 52;
assign p_64[1][52] = 51;
assign p_64[1][53] = 50;
assign p_64[1][54] = 49;
assign p_64[1][55] = 48;
assign p_64[1][56] = 63;
assign p_64[1][57] = 62;
assign p_64[1][58] = 61;
assign p_64[1][59] = 60;
assign p_64[1][60] = 59;
assign p_64[1][61] = 58;
assign p_64[1][62] = 57;
assign p_64[1][63] = 56;
assign p_256[0][  0] = 0;
assign p_256[0][  1] = 16;
assign p_256[0][  2] = 32;
assign p_256[0][  3] = 48;
assign p_256[0][  4] = 64;
assign p_256[0][  5] = 80;
assign p_256[0][  6] = 96;
assign p_256[0][  7] = 112;
assign p_256[0][  8] = 128;
assign p_256[0][  9] = 144;
assign p_256[0][ 10] = 160;
assign p_256[0][ 11] = 176;
assign p_256[0][ 12] = 192;
assign p_256[0][ 13] = 208;
assign p_256[0][ 14] = 224;
assign p_256[0][ 15] = 240;
assign p_256[0][ 16] = 1;
assign p_256[0][ 17] = 17;
assign p_256[0][ 18] = 33;
assign p_256[0][ 19] = 49;
assign p_256[0][ 20] = 65;
assign p_256[0][ 21] = 81;
assign p_256[0][ 22] = 97;
assign p_256[0][ 23] = 113;
assign p_256[0][ 24] = 129;
assign p_256[0][ 25] = 145;
assign p_256[0][ 26] = 161;
assign p_256[0][ 27] = 177;
assign p_256[0][ 28] = 193;
assign p_256[0][ 29] = 209;
assign p_256[0][ 30] = 225;
assign p_256[0][ 31] = 241;
assign p_256[0][ 32] = 2;
assign p_256[0][ 33] = 18;
assign p_256[0][ 34] = 34;
assign p_256[0][ 35] = 50;
assign p_256[0][ 36] = 66;
assign p_256[0][ 37] = 82;
assign p_256[0][ 38] = 98;
assign p_256[0][ 39] = 114;
assign p_256[0][ 40] = 130;
assign p_256[0][ 41] = 146;
assign p_256[0][ 42] = 162;
assign p_256[0][ 43] = 178;
assign p_256[0][ 44] = 194;
assign p_256[0][ 45] = 210;
assign p_256[0][ 46] = 226;
assign p_256[0][ 47] = 242;
assign p_256[0][ 48] = 3;
assign p_256[0][ 49] = 19;
assign p_256[0][ 50] = 35;
assign p_256[0][ 51] = 51;
assign p_256[0][ 52] = 67;
assign p_256[0][ 53] = 83;
assign p_256[0][ 54] = 99;
assign p_256[0][ 55] = 115;
assign p_256[0][ 56] = 131;
assign p_256[0][ 57] = 147;
assign p_256[0][ 58] = 163;
assign p_256[0][ 59] = 179;
assign p_256[0][ 60] = 195;
assign p_256[0][ 61] = 211;
assign p_256[0][ 62] = 227;
assign p_256[0][ 63] = 243;
assign p_256[0][ 64] = 4;
assign p_256[0][ 65] = 20;
assign p_256[0][ 66] = 36;
assign p_256[0][ 67] = 52;
assign p_256[0][ 68] = 68;
assign p_256[0][ 69] = 84;
assign p_256[0][ 70] = 100;
assign p_256[0][ 71] = 116;
assign p_256[0][ 72] = 132;
assign p_256[0][ 73] = 148;
assign p_256[0][ 74] = 164;
assign p_256[0][ 75] = 180;
assign p_256[0][ 76] = 196;
assign p_256[0][ 77] = 212;
assign p_256[0][ 78] = 228;
assign p_256[0][ 79] = 244;
assign p_256[0][ 80] = 5;
assign p_256[0][ 81] = 21;
assign p_256[0][ 82] = 37;
assign p_256[0][ 83] = 53;
assign p_256[0][ 84] = 69;
assign p_256[0][ 85] = 85;
assign p_256[0][ 86] = 101;
assign p_256[0][ 87] = 117;
assign p_256[0][ 88] = 133;
assign p_256[0][ 89] = 149;
assign p_256[0][ 90] = 165;
assign p_256[0][ 91] = 181;
assign p_256[0][ 92] = 197;
assign p_256[0][ 93] = 213;
assign p_256[0][ 94] = 229;
assign p_256[0][ 95] = 245;
assign p_256[0][ 96] = 6;
assign p_256[0][ 97] = 22;
assign p_256[0][ 98] = 38;
assign p_256[0][ 99] = 54;
assign p_256[0][100] = 70;
assign p_256[0][101] = 86;
assign p_256[0][102] = 102;
assign p_256[0][103] = 118;
assign p_256[0][104] = 134;
assign p_256[0][105] = 150;
assign p_256[0][106] = 166;
assign p_256[0][107] = 182;
assign p_256[0][108] = 198;
assign p_256[0][109] = 214;
assign p_256[0][110] = 230;
assign p_256[0][111] = 246;
assign p_256[0][112] = 7;
assign p_256[0][113] = 23;
assign p_256[0][114] = 39;
assign p_256[0][115] = 55;
assign p_256[0][116] = 71;
assign p_256[0][117] = 87;
assign p_256[0][118] = 103;
assign p_256[0][119] = 119;
assign p_256[0][120] = 135;
assign p_256[0][121] = 151;
assign p_256[0][122] = 167;
assign p_256[0][123] = 183;
assign p_256[0][124] = 199;
assign p_256[0][125] = 215;
assign p_256[0][126] = 231;
assign p_256[0][127] = 247;
assign p_256[0][128] = 8;
assign p_256[0][129] = 24;
assign p_256[0][130] = 40;
assign p_256[0][131] = 56;
assign p_256[0][132] = 72;
assign p_256[0][133] = 88;
assign p_256[0][134] = 104;
assign p_256[0][135] = 120;
assign p_256[0][136] = 136;
assign p_256[0][137] = 152;
assign p_256[0][138] = 168;
assign p_256[0][139] = 184;
assign p_256[0][140] = 200;
assign p_256[0][141] = 216;
assign p_256[0][142] = 232;
assign p_256[0][143] = 248;
assign p_256[0][144] = 9;
assign p_256[0][145] = 25;
assign p_256[0][146] = 41;
assign p_256[0][147] = 57;
assign p_256[0][148] = 73;
assign p_256[0][149] = 89;
assign p_256[0][150] = 105;
assign p_256[0][151] = 121;
assign p_256[0][152] = 137;
assign p_256[0][153] = 153;
assign p_256[0][154] = 169;
assign p_256[0][155] = 185;
assign p_256[0][156] = 201;
assign p_256[0][157] = 217;
assign p_256[0][158] = 233;
assign p_256[0][159] = 249;
assign p_256[0][160] = 10;
assign p_256[0][161] = 26;
assign p_256[0][162] = 42;
assign p_256[0][163] = 58;
assign p_256[0][164] = 74;
assign p_256[0][165] = 90;
assign p_256[0][166] = 106;
assign p_256[0][167] = 122;
assign p_256[0][168] = 138;
assign p_256[0][169] = 154;
assign p_256[0][170] = 170;
assign p_256[0][171] = 186;
assign p_256[0][172] = 202;
assign p_256[0][173] = 218;
assign p_256[0][174] = 234;
assign p_256[0][175] = 250;
assign p_256[0][176] = 11;
assign p_256[0][177] = 27;
assign p_256[0][178] = 43;
assign p_256[0][179] = 59;
assign p_256[0][180] = 75;
assign p_256[0][181] = 91;
assign p_256[0][182] = 107;
assign p_256[0][183] = 123;
assign p_256[0][184] = 139;
assign p_256[0][185] = 155;
assign p_256[0][186] = 171;
assign p_256[0][187] = 187;
assign p_256[0][188] = 203;
assign p_256[0][189] = 219;
assign p_256[0][190] = 235;
assign p_256[0][191] = 251;
assign p_256[0][192] = 12;
assign p_256[0][193] = 28;
assign p_256[0][194] = 44;
assign p_256[0][195] = 60;
assign p_256[0][196] = 76;
assign p_256[0][197] = 92;
assign p_256[0][198] = 108;
assign p_256[0][199] = 124;
assign p_256[0][200] = 140;
assign p_256[0][201] = 156;
assign p_256[0][202] = 172;
assign p_256[0][203] = 188;
assign p_256[0][204] = 204;
assign p_256[0][205] = 220;
assign p_256[0][206] = 236;
assign p_256[0][207] = 252;
assign p_256[0][208] = 13;
assign p_256[0][209] = 29;
assign p_256[0][210] = 45;
assign p_256[0][211] = 61;
assign p_256[0][212] = 77;
assign p_256[0][213] = 93;
assign p_256[0][214] = 109;
assign p_256[0][215] = 125;
assign p_256[0][216] = 141;
assign p_256[0][217] = 157;
assign p_256[0][218] = 173;
assign p_256[0][219] = 189;
assign p_256[0][220] = 205;
assign p_256[0][221] = 221;
assign p_256[0][222] = 237;
assign p_256[0][223] = 253;
assign p_256[0][224] = 14;
assign p_256[0][225] = 30;
assign p_256[0][226] = 46;
assign p_256[0][227] = 62;
assign p_256[0][228] = 78;
assign p_256[0][229] = 94;
assign p_256[0][230] = 110;
assign p_256[0][231] = 126;
assign p_256[0][232] = 142;
assign p_256[0][233] = 158;
assign p_256[0][234] = 174;
assign p_256[0][235] = 190;
assign p_256[0][236] = 206;
assign p_256[0][237] = 222;
assign p_256[0][238] = 238;
assign p_256[0][239] = 254;
assign p_256[0][240] = 15;
assign p_256[0][241] = 31;
assign p_256[0][242] = 47;
assign p_256[0][243] = 63;
assign p_256[0][244] = 79;
assign p_256[0][245] = 95;
assign p_256[0][246] = 111;
assign p_256[0][247] = 127;
assign p_256[0][248] = 143;
assign p_256[0][249] = 159;
assign p_256[0][250] = 175;
assign p_256[0][251] = 191;
assign p_256[0][252] = 207;
assign p_256[0][253] = 223;
assign p_256[0][254] = 239;
assign p_256[0][255] = 255;
assign p_256[1][  0] = 15;
assign p_256[1][  1] = 14;
assign p_256[1][  2] = 13;
assign p_256[1][  3] = 12;
assign p_256[1][  4] = 11;
assign p_256[1][  5] = 10;
assign p_256[1][  6] = 9;
assign p_256[1][  7] = 8;
assign p_256[1][  8] = 7;
assign p_256[1][  9] = 6;
assign p_256[1][ 10] = 5;
assign p_256[1][ 11] = 4;
assign p_256[1][ 12] = 3;
assign p_256[1][ 13] = 2;
assign p_256[1][ 14] = 1;
assign p_256[1][ 15] = 0;
assign p_256[1][ 16] = 31;
assign p_256[1][ 17] = 30;
assign p_256[1][ 18] = 29;
assign p_256[1][ 19] = 28;
assign p_256[1][ 20] = 27;
assign p_256[1][ 21] = 26;
assign p_256[1][ 22] = 25;
assign p_256[1][ 23] = 24;
assign p_256[1][ 24] = 23;
assign p_256[1][ 25] = 22;
assign p_256[1][ 26] = 21;
assign p_256[1][ 27] = 20;
assign p_256[1][ 28] = 19;
assign p_256[1][ 29] = 18;
assign p_256[1][ 30] = 17;
assign p_256[1][ 31] = 16;
assign p_256[1][ 32] = 47;
assign p_256[1][ 33] = 46;
assign p_256[1][ 34] = 45;
assign p_256[1][ 35] = 44;
assign p_256[1][ 36] = 43;
assign p_256[1][ 37] = 42;
assign p_256[1][ 38] = 41;
assign p_256[1][ 39] = 40;
assign p_256[1][ 40] = 39;
assign p_256[1][ 41] = 38;
assign p_256[1][ 42] = 37;
assign p_256[1][ 43] = 36;
assign p_256[1][ 44] = 35;
assign p_256[1][ 45] = 34;
assign p_256[1][ 46] = 33;
assign p_256[1][ 47] = 32;
assign p_256[1][ 48] = 63;
assign p_256[1][ 49] = 62;
assign p_256[1][ 50] = 61;
assign p_256[1][ 51] = 60;
assign p_256[1][ 52] = 59;
assign p_256[1][ 53] = 58;
assign p_256[1][ 54] = 57;
assign p_256[1][ 55] = 56;
assign p_256[1][ 56] = 55;
assign p_256[1][ 57] = 54;
assign p_256[1][ 58] = 53;
assign p_256[1][ 59] = 52;
assign p_256[1][ 60] = 51;
assign p_256[1][ 61] = 50;
assign p_256[1][ 62] = 49;
assign p_256[1][ 63] = 48;
assign p_256[1][ 64] = 79;
assign p_256[1][ 65] = 78;
assign p_256[1][ 66] = 77;
assign p_256[1][ 67] = 76;
assign p_256[1][ 68] = 75;
assign p_256[1][ 69] = 74;
assign p_256[1][ 70] = 73;
assign p_256[1][ 71] = 72;
assign p_256[1][ 72] = 71;
assign p_256[1][ 73] = 70;
assign p_256[1][ 74] = 69;
assign p_256[1][ 75] = 68;
assign p_256[1][ 76] = 67;
assign p_256[1][ 77] = 66;
assign p_256[1][ 78] = 65;
assign p_256[1][ 79] = 64;
assign p_256[1][ 80] = 95;
assign p_256[1][ 81] = 94;
assign p_256[1][ 82] = 93;
assign p_256[1][ 83] = 92;
assign p_256[1][ 84] = 91;
assign p_256[1][ 85] = 90;
assign p_256[1][ 86] = 89;
assign p_256[1][ 87] = 88;
assign p_256[1][ 88] = 87;
assign p_256[1][ 89] = 86;
assign p_256[1][ 90] = 85;
assign p_256[1][ 91] = 84;
assign p_256[1][ 92] = 83;
assign p_256[1][ 93] = 82;
assign p_256[1][ 94] = 81;
assign p_256[1][ 95] = 80;
assign p_256[1][ 96] = 111;
assign p_256[1][ 97] = 110;
assign p_256[1][ 98] = 109;
assign p_256[1][ 99] = 108;
assign p_256[1][100] = 107;
assign p_256[1][101] = 106;
assign p_256[1][102] = 105;
assign p_256[1][103] = 104;
assign p_256[1][104] = 103;
assign p_256[1][105] = 102;
assign p_256[1][106] = 101;
assign p_256[1][107] = 100;
assign p_256[1][108] = 99;
assign p_256[1][109] = 98;
assign p_256[1][110] = 97;
assign p_256[1][111] = 96;
assign p_256[1][112] = 127;
assign p_256[1][113] = 126;
assign p_256[1][114] = 125;
assign p_256[1][115] = 124;
assign p_256[1][116] = 123;
assign p_256[1][117] = 122;
assign p_256[1][118] = 121;
assign p_256[1][119] = 120;
assign p_256[1][120] = 119;
assign p_256[1][121] = 118;
assign p_256[1][122] = 117;
assign p_256[1][123] = 116;
assign p_256[1][124] = 115;
assign p_256[1][125] = 114;
assign p_256[1][126] = 113;
assign p_256[1][127] = 112;
assign p_256[1][128] = 143;
assign p_256[1][129] = 142;
assign p_256[1][130] = 141;
assign p_256[1][131] = 140;
assign p_256[1][132] = 139;
assign p_256[1][133] = 138;
assign p_256[1][134] = 137;
assign p_256[1][135] = 136;
assign p_256[1][136] = 135;
assign p_256[1][137] = 134;
assign p_256[1][138] = 133;
assign p_256[1][139] = 132;
assign p_256[1][140] = 131;
assign p_256[1][141] = 130;
assign p_256[1][142] = 129;
assign p_256[1][143] = 128;
assign p_256[1][144] = 159;
assign p_256[1][145] = 158;
assign p_256[1][146] = 157;
assign p_256[1][147] = 156;
assign p_256[1][148] = 155;
assign p_256[1][149] = 154;
assign p_256[1][150] = 153;
assign p_256[1][151] = 152;
assign p_256[1][152] = 151;
assign p_256[1][153] = 150;
assign p_256[1][154] = 149;
assign p_256[1][155] = 148;
assign p_256[1][156] = 147;
assign p_256[1][157] = 146;
assign p_256[1][158] = 145;
assign p_256[1][159] = 144;
assign p_256[1][160] = 175;
assign p_256[1][161] = 174;
assign p_256[1][162] = 173;
assign p_256[1][163] = 172;
assign p_256[1][164] = 171;
assign p_256[1][165] = 170;
assign p_256[1][166] = 169;
assign p_256[1][167] = 168;
assign p_256[1][168] = 167;
assign p_256[1][169] = 166;
assign p_256[1][170] = 165;
assign p_256[1][171] = 164;
assign p_256[1][172] = 163;
assign p_256[1][173] = 162;
assign p_256[1][174] = 161;
assign p_256[1][175] = 160;
assign p_256[1][176] = 191;
assign p_256[1][177] = 190;
assign p_256[1][178] = 189;
assign p_256[1][179] = 188;
assign p_256[1][180] = 187;
assign p_256[1][181] = 186;
assign p_256[1][182] = 185;
assign p_256[1][183] = 184;
assign p_256[1][184] = 183;
assign p_256[1][185] = 182;
assign p_256[1][186] = 181;
assign p_256[1][187] = 180;
assign p_256[1][188] = 179;
assign p_256[1][189] = 178;
assign p_256[1][190] = 177;
assign p_256[1][191] = 176;
assign p_256[1][192] = 207;
assign p_256[1][193] = 206;
assign p_256[1][194] = 205;
assign p_256[1][195] = 204;
assign p_256[1][196] = 203;
assign p_256[1][197] = 202;
assign p_256[1][198] = 201;
assign p_256[1][199] = 200;
assign p_256[1][200] = 199;
assign p_256[1][201] = 198;
assign p_256[1][202] = 197;
assign p_256[1][203] = 196;
assign p_256[1][204] = 195;
assign p_256[1][205] = 194;
assign p_256[1][206] = 193;
assign p_256[1][207] = 192;
assign p_256[1][208] = 223;
assign p_256[1][209] = 222;
assign p_256[1][210] = 221;
assign p_256[1][211] = 220;
assign p_256[1][212] = 219;
assign p_256[1][213] = 218;
assign p_256[1][214] = 217;
assign p_256[1][215] = 216;
assign p_256[1][216] = 215;
assign p_256[1][217] = 214;
assign p_256[1][218] = 213;
assign p_256[1][219] = 212;
assign p_256[1][220] = 211;
assign p_256[1][221] = 210;
assign p_256[1][222] = 209;
assign p_256[1][223] = 208;
assign p_256[1][224] = 239;
assign p_256[1][225] = 238;
assign p_256[1][226] = 237;
assign p_256[1][227] = 236;
assign p_256[1][228] = 235;
assign p_256[1][229] = 234;
assign p_256[1][230] = 233;
assign p_256[1][231] = 232;
assign p_256[1][232] = 231;
assign p_256[1][233] = 230;
assign p_256[1][234] = 229;
assign p_256[1][235] = 228;
assign p_256[1][236] = 227;
assign p_256[1][237] = 226;
assign p_256[1][238] = 225;
assign p_256[1][239] = 224;
assign p_256[1][240] = 255;
assign p_256[1][241] = 254;
assign p_256[1][242] = 253;
assign p_256[1][243] = 252;
assign p_256[1][244] = 251;
assign p_256[1][245] = 250;
assign p_256[1][246] = 249;
assign p_256[1][247] = 248;
assign p_256[1][248] = 247;
assign p_256[1][249] = 246;
assign p_256[1][250] = 245;
assign p_256[1][251] = 244;
assign p_256[1][252] = 243;
assign p_256[1][253] = 242;
assign p_256[1][254] = 241;
assign p_256[1][255] = 240;
// rotate inverse
assign p_4[2][00] = 2;
assign p_4[2][01] = 0;
assign p_4[2][02] = 3;
assign p_4[2][03] = 1;
assign p_16[2][00] = 12;
assign p_16[2][01] = 8;
assign p_16[2][02] = 4;
assign p_16[2][03] = 0;
assign p_16[2][04] = 13;
assign p_16[2][05] = 9;
assign p_16[2][06] = 5;
assign p_16[2][07] = 1;
assign p_16[2][08] = 14;
assign p_16[2][09] = 10;
assign p_16[2][10] = 6;
assign p_16[2][11] = 2;
assign p_16[2][12] = 15;
assign p_16[2][13] = 11;
assign p_16[2][14] = 7;
assign p_16[2][15] = 3;
assign p_64[2][00] = 56;
assign p_64[2][01] = 48;
assign p_64[2][02] = 40;
assign p_64[2][03] = 32;
assign p_64[2][04] = 24;
assign p_64[2][05] = 16;
assign p_64[2][06] = 8;
assign p_64[2][07] = 0;
assign p_64[2][08] = 57;
assign p_64[2][09] = 49;
assign p_64[2][10] = 41;
assign p_64[2][11] = 33;
assign p_64[2][12] = 25;
assign p_64[2][13] = 17;
assign p_64[2][14] = 9;
assign p_64[2][15] = 1;
assign p_64[2][16] = 58;
assign p_64[2][17] = 50;
assign p_64[2][18] = 42;
assign p_64[2][19] = 34;
assign p_64[2][20] = 26;
assign p_64[2][21] = 18;
assign p_64[2][22] = 10;
assign p_64[2][23] = 2;
assign p_64[2][24] = 59;
assign p_64[2][25] = 51;
assign p_64[2][26] = 43;
assign p_64[2][27] = 35;
assign p_64[2][28] = 27;
assign p_64[2][29] = 19;
assign p_64[2][30] = 11;
assign p_64[2][31] = 3;
assign p_64[2][32] = 60;
assign p_64[2][33] = 52;
assign p_64[2][34] = 44;
assign p_64[2][35] = 36;
assign p_64[2][36] = 28;
assign p_64[2][37] = 20;
assign p_64[2][38] = 12;
assign p_64[2][39] = 4;
assign p_64[2][40] = 61;
assign p_64[2][41] = 53;
assign p_64[2][42] = 45;
assign p_64[2][43] = 37;
assign p_64[2][44] = 29;
assign p_64[2][45] = 21;
assign p_64[2][46] = 13;
assign p_64[2][47] = 5;
assign p_64[2][48] = 62;
assign p_64[2][49] = 54;
assign p_64[2][50] = 46;
assign p_64[2][51] = 38;
assign p_64[2][52] = 30;
assign p_64[2][53] = 22;
assign p_64[2][54] = 14;
assign p_64[2][55] = 6;
assign p_64[2][56] = 63;
assign p_64[2][57] = 55;
assign p_64[2][58] = 47;
assign p_64[2][59] = 39;
assign p_64[2][60] = 31;
assign p_64[2][61] = 23;
assign p_64[2][62] = 15;
assign p_64[2][63] = 7;

assign p_256[2][  0] = 240;
assign p_256[2][  1] = 224;
assign p_256[2][  2] = 208;
assign p_256[2][  3] = 192;
assign p_256[2][  4] = 176;
assign p_256[2][  5] = 160;
assign p_256[2][  6] = 144;
assign p_256[2][  7] = 128;
assign p_256[2][  8] = 112;
assign p_256[2][  9] = 96;
assign p_256[2][ 10] = 80;
assign p_256[2][ 11] = 64;
assign p_256[2][ 12] = 48;
assign p_256[2][ 13] = 32;
assign p_256[2][ 14] = 16;
assign p_256[2][ 15] = 0;
assign p_256[2][ 16] = 241;
assign p_256[2][ 17] = 225;
assign p_256[2][ 18] = 209;
assign p_256[2][ 19] = 193;
assign p_256[2][ 20] = 177;
assign p_256[2][ 21] = 161;
assign p_256[2][ 22] = 145;
assign p_256[2][ 23] = 129;
assign p_256[2][ 24] = 113;
assign p_256[2][ 25] = 97;
assign p_256[2][ 26] = 81;
assign p_256[2][ 27] = 65;
assign p_256[2][ 28] = 49;
assign p_256[2][ 29] = 33;
assign p_256[2][ 30] = 17;
assign p_256[2][ 31] = 1;
assign p_256[2][ 32] = 242;
assign p_256[2][ 33] = 226;
assign p_256[2][ 34] = 210;
assign p_256[2][ 35] = 194;
assign p_256[2][ 36] = 178;
assign p_256[2][ 37] = 162;
assign p_256[2][ 38] = 146;
assign p_256[2][ 39] = 130;
assign p_256[2][ 40] = 114;
assign p_256[2][ 41] = 98;
assign p_256[2][ 42] = 82;
assign p_256[2][ 43] = 66;
assign p_256[2][ 44] = 50;
assign p_256[2][ 45] = 34;
assign p_256[2][ 46] = 18;
assign p_256[2][ 47] = 2;
assign p_256[2][ 48] = 243;
assign p_256[2][ 49] = 227;
assign p_256[2][ 50] = 211;
assign p_256[2][ 51] = 195;
assign p_256[2][ 52] = 179;
assign p_256[2][ 53] = 163;
assign p_256[2][ 54] = 147;
assign p_256[2][ 55] = 131;
assign p_256[2][ 56] = 115;
assign p_256[2][ 57] = 99;
assign p_256[2][ 58] = 83;
assign p_256[2][ 59] = 67;
assign p_256[2][ 60] = 51;
assign p_256[2][ 61] = 35;
assign p_256[2][ 62] = 19;
assign p_256[2][ 63] = 3;
assign p_256[2][ 64] = 244;
assign p_256[2][ 65] = 228;
assign p_256[2][ 66] = 212;
assign p_256[2][ 67] = 196;
assign p_256[2][ 68] = 180;
assign p_256[2][ 69] = 164;
assign p_256[2][ 70] = 148;
assign p_256[2][ 71] = 132;
assign p_256[2][ 72] = 116;
assign p_256[2][ 73] = 100;
assign p_256[2][ 74] = 84;
assign p_256[2][ 75] = 68;
assign p_256[2][ 76] = 52;
assign p_256[2][ 77] = 36;
assign p_256[2][ 78] = 20;
assign p_256[2][ 79] = 4;
assign p_256[2][ 80] = 245;
assign p_256[2][ 81] = 229;
assign p_256[2][ 82] = 213;
assign p_256[2][ 83] = 197;
assign p_256[2][ 84] = 181;
assign p_256[2][ 85] = 165;
assign p_256[2][ 86] = 149;
assign p_256[2][ 87] = 133;
assign p_256[2][ 88] = 117;
assign p_256[2][ 89] = 101;
assign p_256[2][ 90] = 85;
assign p_256[2][ 91] = 69;
assign p_256[2][ 92] = 53;
assign p_256[2][ 93] = 37;
assign p_256[2][ 94] = 21;
assign p_256[2][ 95] = 5;
assign p_256[2][ 96] = 246;
assign p_256[2][ 97] = 230;
assign p_256[2][ 98] = 214;
assign p_256[2][ 99] = 198;
assign p_256[2][100] = 182;
assign p_256[2][101] = 166;
assign p_256[2][102] = 150;
assign p_256[2][103] = 134;
assign p_256[2][104] = 118;
assign p_256[2][105] = 102;
assign p_256[2][106] = 86;
assign p_256[2][107] = 70;
assign p_256[2][108] = 54;
assign p_256[2][109] = 38;
assign p_256[2][110] = 22;
assign p_256[2][111] = 6;
assign p_256[2][112] = 247;
assign p_256[2][113] = 231;
assign p_256[2][114] = 215;
assign p_256[2][115] = 199;
assign p_256[2][116] = 183;
assign p_256[2][117] = 167;
assign p_256[2][118] = 151;
assign p_256[2][119] = 135;
assign p_256[2][120] = 119;
assign p_256[2][121] = 103;
assign p_256[2][122] = 87;
assign p_256[2][123] = 71;
assign p_256[2][124] = 55;
assign p_256[2][125] = 39;
assign p_256[2][126] = 23;
assign p_256[2][127] = 7;
assign p_256[2][128] = 248;
assign p_256[2][129] = 232;
assign p_256[2][130] = 216;
assign p_256[2][131] = 200;
assign p_256[2][132] = 184;
assign p_256[2][133] = 168;
assign p_256[2][134] = 152;
assign p_256[2][135] = 136;
assign p_256[2][136] = 120;
assign p_256[2][137] = 104;
assign p_256[2][138] = 88;
assign p_256[2][139] = 72;
assign p_256[2][140] = 56;
assign p_256[2][141] = 40;
assign p_256[2][142] = 24;
assign p_256[2][143] = 8;
assign p_256[2][144] = 249;
assign p_256[2][145] = 233;
assign p_256[2][146] = 217;
assign p_256[2][147] = 201;
assign p_256[2][148] = 185;
assign p_256[2][149] = 169;
assign p_256[2][150] = 153;
assign p_256[2][151] = 137;
assign p_256[2][152] = 121;
assign p_256[2][153] = 105;
assign p_256[2][154] = 89;
assign p_256[2][155] = 73;
assign p_256[2][156] = 57;
assign p_256[2][157] = 41;
assign p_256[2][158] = 25;
assign p_256[2][159] = 9;
assign p_256[2][160] = 250;
assign p_256[2][161] = 234;
assign p_256[2][162] = 218;
assign p_256[2][163] = 202;
assign p_256[2][164] = 186;
assign p_256[2][165] = 170;
assign p_256[2][166] = 154;
assign p_256[2][167] = 138;
assign p_256[2][168] = 122;
assign p_256[2][169] = 106;
assign p_256[2][170] = 90;
assign p_256[2][171] = 74;
assign p_256[2][172] = 58;
assign p_256[2][173] = 42;
assign p_256[2][174] = 26;
assign p_256[2][175] = 10;
assign p_256[2][176] = 251;
assign p_256[2][177] = 235;
assign p_256[2][178] = 219;
assign p_256[2][179] = 203;
assign p_256[2][180] = 187;
assign p_256[2][181] = 171;
assign p_256[2][182] = 155;
assign p_256[2][183] = 139;
assign p_256[2][184] = 123;
assign p_256[2][185] = 107;
assign p_256[2][186] = 91;
assign p_256[2][187] = 75;
assign p_256[2][188] = 59;
assign p_256[2][189] = 43;
assign p_256[2][190] = 27;
assign p_256[2][191] = 11;
assign p_256[2][192] = 252;
assign p_256[2][193] = 236;
assign p_256[2][194] = 220;
assign p_256[2][195] = 204;
assign p_256[2][196] = 188;
assign p_256[2][197] = 172;
assign p_256[2][198] = 156;
assign p_256[2][199] = 140;
assign p_256[2][200] = 124;
assign p_256[2][201] = 108;
assign p_256[2][202] = 92;
assign p_256[2][203] = 76;
assign p_256[2][204] = 60;
assign p_256[2][205] = 44;
assign p_256[2][206] = 28;
assign p_256[2][207] = 12;
assign p_256[2][208] = 253;
assign p_256[2][209] = 237;
assign p_256[2][210] = 221;
assign p_256[2][211] = 205;
assign p_256[2][212] = 189;
assign p_256[2][213] = 173;
assign p_256[2][214] = 157;
assign p_256[2][215] = 141;
assign p_256[2][216] = 125;
assign p_256[2][217] = 109;
assign p_256[2][218] = 93;
assign p_256[2][219] = 77;
assign p_256[2][220] = 61;
assign p_256[2][221] = 45;
assign p_256[2][222] = 29;
assign p_256[2][223] = 13;
assign p_256[2][224] = 254;
assign p_256[2][225] = 238;
assign p_256[2][226] = 222;
assign p_256[2][227] = 206;
assign p_256[2][228] = 190;
assign p_256[2][229] = 174;
assign p_256[2][230] = 158;
assign p_256[2][231] = 142;
assign p_256[2][232] = 126;
assign p_256[2][233] = 110;
assign p_256[2][234] = 94;
assign p_256[2][235] = 78;
assign p_256[2][236] = 62;
assign p_256[2][237] = 46;
assign p_256[2][238] = 30;
assign p_256[2][239] = 14;
assign p_256[2][240] = 255;
assign p_256[2][241] = 239;
assign p_256[2][242] = 223;
assign p_256[2][243] = 207;
assign p_256[2][244] = 191;
assign p_256[2][245] = 175;
assign p_256[2][246] = 159;
assign p_256[2][247] = 143;
assign p_256[2][248] = 127;
assign p_256[2][249] = 111;
assign p_256[2][250] = 95;
assign p_256[2][251] = 79;
assign p_256[2][252] = 63;
assign p_256[2][253] = 47;
assign p_256[2][254] = 31;
assign p_256[2][255] = 15;

endmodule
