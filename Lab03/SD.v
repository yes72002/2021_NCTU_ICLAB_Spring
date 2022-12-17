
module SD(
    //Input Port
    clk,
    rst_n,
	in_valid,
	in,
    //Output Port
    out_valid,
    out
);
// PORT DECLARATION
input            clk, rst_n, in_valid;
input [3:0]      in;
output reg       out_valid;
output reg [3:0] out;
// PARAMETER DECLARATION
parameter IDLE         = 4'b0000; // 0
parameter SODOKU       = 4'b0001; // 1
parameter CALCUATE0    = 4'b0010; // 2
parameter GUESS1       = 4'b0011; // 3
parameter CALCUATE1    = 4'b0100; // 4
parameter GUESS_WRONG1 = 4'b0101; // 5
parameter GUESS2       = 4'b0110; // 6
parameter CALCUATE2    = 4'b0111; // 7
parameter GUESS_WRONG2 = 4'b1000; // 8
parameter OUTPUT_NO    = 4'b1001; // 9
parameter OUTPUT_YES   = 4'b1010; // 10
// LOGIC DECLARATION
reg [6:0] count_in;
reg [4:0] count_calcuate;
reg [3:0] count_out;
reg [3:0] s[80:0];
reg [3:0] s2[80:0];
wire [80:0] diff;
wire [80:0] blank;
reg [6:0] blank_pos[14:0];
reg [6:0] i;
reg [3:0] j;
reg [80:0] blank_g1;
reg [3:0] k1;
// FSM
reg [3:0] curr_state;    // 0~10
reg [3:0] next_state;    // 0~10
// calcuate
wire [8:0]        fail_row,          fail_col,         fail_sub;
wire [9:0] possibility_row1, possibility_col1, possibility_sub1;
wire [9:0] possibility_row2, possibility_col2, possibility_sub2;
wire [9:0] possibility_row3, possibility_col3, possibility_sub3;
wire [9:0] possibility_row4, possibility_col4, possibility_sub4;
wire [9:0] possibility_row5, possibility_col5, possibility_sub5;
wire [9:0] possibility_row6, possibility_col6, possibility_sub6;
wire [9:0] possibility_row7, possibility_col7, possibility_sub7;
wire [9:0] possibility_row8, possibility_col8, possibility_sub8;
wire [9:0] possibility_row9, possibility_col9, possibility_sub9;
wire [9:0] possibility00, possibility01, possibility02, possibility03, possibility04, possibility05, possibility06, possibility07, possibility08;
wire [9:0] possibility09, possibility10, possibility11, possibility12, possibility13, possibility14, possibility15, possibility16, possibility17;
wire [9:0] possibility18, possibility19, possibility20, possibility21, possibility22, possibility23, possibility24, possibility25, possibility26;
wire [9:0] possibility27, possibility28, possibility29, possibility30, possibility31, possibility32, possibility33, possibility34, possibility35;
wire [9:0] possibility36, possibility37, possibility38, possibility39, possibility40, possibility41, possibility42, possibility43, possibility44;
wire [9:0] possibility45, possibility46, possibility47, possibility48, possibility49, possibility50, possibility51, possibility52, possibility53;
wire [9:0] possibility54, possibility55, possibility56, possibility57, possibility58, possibility59, possibility60, possibility61, possibility62;
wire [9:0] possibility63, possibility64, possibility65, possibility66, possibility67, possibility68, possibility69, possibility70, possibility71;
wire [9:0] possibility72, possibility73, possibility74, possibility75, possibility76, possibility77, possibility78, possibility79, possibility80;
wire [3:0] sum_possibility[80:0];
wire [3:0] fill[80:0];
wire [6:0] blank_LSB;
wire [8:0] finish;// 45*9 = 405
// count_in
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		count_in <= 0;
	else if (in_valid == 1)
		count_in <= count_in + 1;
	else if (curr_state == IDLE)
		count_in <= 0;
	else
		count_in <= count_in;
end	

// s00 ~ s80
always@(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (i = 0; i < 81; i = i + 1) begin
			s[i] <= 0;
		end
	end
	else if (in_valid == 1) begin
		for (i = 0; i < 80; i = i + 1) begin
			s[i] <= s[i+1];
		end
		s[80] <= in;
	end
	else if (curr_state == CALCUATE0) begin
		for (i = 0; i < 81; i = i + 1) begin
			if (s[i] == 0) begin
				if (sum_possibility[i] == 1)
					s[i] <= fill[i];
				else
					s[i] <= s[i];
			end
			else
				s[i] <= s[i];
		end
	end
	else if (curr_state == GUESS1) begin
		for (i = 0; i < 81; i = i + 1) begin
			if (blank_LSB == i)
				s[i] <= fill[i] + k1;
			else
				s[i] <= s[i];
		end
	end
	else if (curr_state == CALCUATE1) begin
		for (i = 0; i < 81; i = i + 1) begin
			if (s[i] == 0) begin
				if (sum_possibility[i] == 1)
					s[i] <= fill[i];
				else
					s[i] <= s[i];
			end
			else
				s[i] <= s[i];
		end
	end
	else if (curr_state == GUESS_WRONG1) begin
		for (i = 0; i < 81; i = i + 1) begin
			if (blank_g1[i] == 1)
				s[i] <= 0;
			else
				s[i] <= s[i];
		end
	end
	else if (curr_state == GUESS2) begin
		for (i = 0; i < 81; i = i + 1) begin
			if (blank_LSB == i)
				s[i] <= fill[i];
			else
				s[i] <= s[i];
		end
	end
	else if (curr_state == CALCUATE2) begin
		for (i = 0; i < 81; i = i + 1) begin
			if (s[i] == 0) begin
				if (sum_possibility[i] == 1)
					s[i] <= fill[i];
				else
					s[i] <= s[i];
			end
			else
				s[i] <= s[i];
		end
	end
	else if (curr_state == IDLE) begin
		for (i = 0; i < 81; i = i + 1) begin
			s[i] <= 0;
		end
	end
	else begin
		for (i = 0; i < 81; i = i + 1) begin
			s[i] <= s[i];
		end
	end
end

// blank
genvar gi;
generate
for (gi = 0; gi < 81; gi = gi + 1) begin: blank_loop
	assign blank[gi] = (s[gi] == 0);
end
endgenerate

// blank_pos
always@(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (i = 0; i < 15; i = i + 1) begin
			blank_pos[i] <= 0;
		end
		j <= 0;
	end
	else if (in_valid == 1) begin
		if (in == 0) begin
			blank_pos[j] <= count_in;
			j <= j + 1;
		end
	end
	else if (curr_state == IDLE) begin
		for (i = 0; i < 15; i = i + 1) begin
			blank_pos[i] <= 0;
		end
		j <= 0;
	end
	else begin
		for (i = 0; i < 15; i = i + 1) begin
			blank_pos[i] <= blank_pos[i];
		end
		j <= j;
	end
end
// blank_g1
always@(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (i = 0; i < 81; i = i + 1) begin
			blank_g1[i] <= 0;
		end
	end
	else if (curr_state == GUESS1) begin
		for (i = 0; i < 81; i = i + 1) begin
			blank_g1[i] <= blank[i];
		end
	end
	else if (curr_state == IDLE) begin
		for (i = 0; i < 81; i = i + 1) begin
			blank_g1[i] <= 0;
		end
	end
	else begin
		for (i = 0; i < 81; i = i + 1) begin
			blank_g1[i] <= blank_g1[i];
		end
	end
end
// k1
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		k1 <= 0;
	else if (curr_state == GUESS_WRONG1) begin
		k1 <= k1 + 1;
	end
	else if (curr_state == IDLE)
		k1 <= 0;
	else begin
		k1 <= k1;
	end
end

// row
grid_check row1(.g1(s[00]), .g2(s[01]), .g3(s[02]), .g4(s[03]), .g5(s[04]), .g6(s[05]), .g7(s[06]), .g8(s[07]), .g9(s[08]), .fail(fail_row[0]), .possibility(possibility_row1));
grid_check row2(.g1(s[09]), .g2(s[10]), .g3(s[11]), .g4(s[12]), .g5(s[13]), .g6(s[14]), .g7(s[15]), .g8(s[16]), .g9(s[17]), .fail(fail_row[1]), .possibility(possibility_row2));
grid_check row3(.g1(s[18]), .g2(s[19]), .g3(s[20]), .g4(s[21]), .g5(s[22]), .g6(s[23]), .g7(s[24]), .g8(s[25]), .g9(s[26]), .fail(fail_row[2]), .possibility(possibility_row3));
grid_check row4(.g1(s[27]), .g2(s[28]), .g3(s[29]), .g4(s[30]), .g5(s[31]), .g6(s[32]), .g7(s[33]), .g8(s[34]), .g9(s[35]), .fail(fail_row[3]), .possibility(possibility_row4));
grid_check row5(.g1(s[36]), .g2(s[37]), .g3(s[38]), .g4(s[39]), .g5(s[40]), .g6(s[41]), .g7(s[42]), .g8(s[43]), .g9(s[44]), .fail(fail_row[4]), .possibility(possibility_row5));
grid_check row6(.g1(s[45]), .g2(s[46]), .g3(s[47]), .g4(s[48]), .g5(s[49]), .g6(s[50]), .g7(s[51]), .g8(s[52]), .g9(s[53]), .fail(fail_row[5]), .possibility(possibility_row6));
grid_check row7(.g1(s[54]), .g2(s[55]), .g3(s[56]), .g4(s[57]), .g5(s[58]), .g6(s[59]), .g7(s[60]), .g8(s[61]), .g9(s[62]), .fail(fail_row[6]), .possibility(possibility_row7));
grid_check row8(.g1(s[63]), .g2(s[64]), .g3(s[65]), .g4(s[66]), .g5(s[67]), .g6(s[68]), .g7(s[69]), .g8(s[70]), .g9(s[71]), .fail(fail_row[7]), .possibility(possibility_row8));
grid_check row9(.g1(s[72]), .g2(s[73]), .g3(s[74]), .g4(s[75]), .g5(s[76]), .g6(s[77]), .g7(s[78]), .g8(s[79]), .g9(s[80]), .fail(fail_row[8]), .possibility(possibility_row9));
// column
grid_check col1(.g1(s[00]), .g2(s[09]), .g3(s[18]), .g4(s[27]), .g5(s[36]), .g6(s[45]), .g7(s[54]), .g8(s[63]), .g9(s[72]), .fail(fail_col[0]), .possibility(possibility_col1));
grid_check col2(.g1(s[01]), .g2(s[10]), .g3(s[19]), .g4(s[28]), .g5(s[37]), .g6(s[46]), .g7(s[55]), .g8(s[64]), .g9(s[73]), .fail(fail_col[1]), .possibility(possibility_col2));
grid_check col3(.g1(s[02]), .g2(s[11]), .g3(s[20]), .g4(s[29]), .g5(s[38]), .g6(s[47]), .g7(s[56]), .g8(s[65]), .g9(s[74]), .fail(fail_col[2]), .possibility(possibility_col3));
grid_check col4(.g1(s[03]), .g2(s[12]), .g3(s[21]), .g4(s[30]), .g5(s[39]), .g6(s[48]), .g7(s[57]), .g8(s[66]), .g9(s[75]), .fail(fail_col[3]), .possibility(possibility_col4));
grid_check col5(.g1(s[04]), .g2(s[13]), .g3(s[22]), .g4(s[31]), .g5(s[40]), .g6(s[49]), .g7(s[58]), .g8(s[67]), .g9(s[76]), .fail(fail_col[4]), .possibility(possibility_col5));
grid_check col6(.g1(s[05]), .g2(s[14]), .g3(s[23]), .g4(s[32]), .g5(s[41]), .g6(s[50]), .g7(s[59]), .g8(s[68]), .g9(s[77]), .fail(fail_col[5]), .possibility(possibility_col6));
grid_check col7(.g1(s[06]), .g2(s[15]), .g3(s[24]), .g4(s[33]), .g5(s[42]), .g6(s[51]), .g7(s[60]), .g8(s[69]), .g9(s[78]), .fail(fail_col[6]), .possibility(possibility_col7));
grid_check col8(.g1(s[07]), .g2(s[16]), .g3(s[25]), .g4(s[34]), .g5(s[43]), .g6(s[52]), .g7(s[61]), .g8(s[70]), .g9(s[79]), .fail(fail_col[7]), .possibility(possibility_col8));
grid_check col9(.g1(s[08]), .g2(s[17]), .g3(s[26]), .g4(s[35]), .g5(s[44]), .g6(s[53]), .g7(s[62]), .g8(s[71]), .g9(s[80]), .fail(fail_col[8]), .possibility(possibility_col9));
// subgrid
grid_check sub1(.g1(s[00]), .g2(s[01]), .g3(s[02]), .g4(s[09]), .g5(s[10]), .g6(s[11]), .g7(s[18]), .g8(s[19]), .g9(s[20]), .fail(fail_sub[0]), .possibility(possibility_sub1));
grid_check sub2(.g1(s[03]), .g2(s[04]), .g3(s[05]), .g4(s[12]), .g5(s[13]), .g6(s[14]), .g7(s[21]), .g8(s[22]), .g9(s[23]), .fail(fail_sub[1]), .possibility(possibility_sub2));
grid_check sub3(.g1(s[06]), .g2(s[07]), .g3(s[08]), .g4(s[15]), .g5(s[16]), .g6(s[17]), .g7(s[24]), .g8(s[25]), .g9(s[26]), .fail(fail_sub[2]), .possibility(possibility_sub3));
grid_check sub4(.g1(s[27]), .g2(s[28]), .g3(s[29]), .g4(s[36]), .g5(s[37]), .g6(s[38]), .g7(s[45]), .g8(s[46]), .g9(s[47]), .fail(fail_sub[3]), .possibility(possibility_sub4));
grid_check sub5(.g1(s[30]), .g2(s[31]), .g3(s[32]), .g4(s[39]), .g5(s[40]), .g6(s[41]), .g7(s[48]), .g8(s[49]), .g9(s[50]), .fail(fail_sub[4]), .possibility(possibility_sub5));
grid_check sub6(.g1(s[33]), .g2(s[34]), .g3(s[35]), .g4(s[42]), .g5(s[43]), .g6(s[44]), .g7(s[51]), .g8(s[52]), .g9(s[53]), .fail(fail_sub[5]), .possibility(possibility_sub6));
grid_check sub7(.g1(s[54]), .g2(s[55]), .g3(s[56]), .g4(s[63]), .g5(s[64]), .g6(s[65]), .g7(s[72]), .g8(s[73]), .g9(s[74]), .fail(fail_sub[6]), .possibility(possibility_sub7));
grid_check sub8(.g1(s[57]), .g2(s[58]), .g3(s[59]), .g4(s[66]), .g5(s[67]), .g6(s[68]), .g7(s[75]), .g8(s[76]), .g9(s[77]), .fail(fail_sub[7]), .possibility(possibility_sub8));
grid_check sub9(.g1(s[60]), .g2(s[61]), .g3(s[62]), .g4(s[69]), .g5(s[70]), .g6(s[71]), .g7(s[78]), .g8(s[79]), .g9(s[80]), .fail(fail_sub[8]), .possibility(possibility_sub9));
// possibility
assign possibility00 = possibility_row1 & possibility_col1 & possibility_sub1;
assign possibility01 = possibility_row1 & possibility_col2 & possibility_sub1;
assign possibility02 = possibility_row1 & possibility_col3 & possibility_sub1;
assign possibility03 = possibility_row1 & possibility_col4 & possibility_sub2;
assign possibility04 = possibility_row1 & possibility_col5 & possibility_sub2;
assign possibility05 = possibility_row1 & possibility_col6 & possibility_sub2;
assign possibility06 = possibility_row1 & possibility_col7 & possibility_sub3;
assign possibility07 = possibility_row1 & possibility_col8 & possibility_sub3;
assign possibility08 = possibility_row1 & possibility_col9 & possibility_sub3;
assign possibility09 = possibility_row2 & possibility_col1 & possibility_sub1;
assign possibility10 = possibility_row2 & possibility_col2 & possibility_sub1;
assign possibility11 = possibility_row2 & possibility_col3 & possibility_sub1;
assign possibility12 = possibility_row2 & possibility_col4 & possibility_sub2;
assign possibility13 = possibility_row2 & possibility_col5 & possibility_sub2;
assign possibility14 = possibility_row2 & possibility_col6 & possibility_sub2;
assign possibility15 = possibility_row2 & possibility_col7 & possibility_sub3;
assign possibility16 = possibility_row2 & possibility_col8 & possibility_sub3;
assign possibility17 = possibility_row2 & possibility_col9 & possibility_sub3;
assign possibility18 = possibility_row3 & possibility_col1 & possibility_sub1;
assign possibility19 = possibility_row3 & possibility_col2 & possibility_sub1;
assign possibility20 = possibility_row3 & possibility_col3 & possibility_sub1;
assign possibility21 = possibility_row3 & possibility_col4 & possibility_sub2;
assign possibility22 = possibility_row3 & possibility_col5 & possibility_sub2;
assign possibility23 = possibility_row3 & possibility_col6 & possibility_sub2;
assign possibility24 = possibility_row3 & possibility_col7 & possibility_sub3;
assign possibility25 = possibility_row3 & possibility_col8 & possibility_sub3;
assign possibility26 = possibility_row3 & possibility_col9 & possibility_sub3;
assign possibility27 = possibility_row4 & possibility_col1 & possibility_sub4;
assign possibility28 = possibility_row4 & possibility_col2 & possibility_sub4;
assign possibility29 = possibility_row4 & possibility_col3 & possibility_sub4;
assign possibility30 = possibility_row4 & possibility_col4 & possibility_sub5;
assign possibility31 = possibility_row4 & possibility_col5 & possibility_sub5;
assign possibility32 = possibility_row4 & possibility_col6 & possibility_sub5;
assign possibility33 = possibility_row4 & possibility_col7 & possibility_sub6;
assign possibility34 = possibility_row4 & possibility_col8 & possibility_sub6;
assign possibility35 = possibility_row4 & possibility_col9 & possibility_sub6;
assign possibility36 = possibility_row5 & possibility_col1 & possibility_sub4;
assign possibility37 = possibility_row5 & possibility_col2 & possibility_sub4;
assign possibility38 = possibility_row5 & possibility_col3 & possibility_sub4;
assign possibility39 = possibility_row5 & possibility_col4 & possibility_sub5;
assign possibility40 = possibility_row5 & possibility_col5 & possibility_sub5;
assign possibility41 = possibility_row5 & possibility_col6 & possibility_sub5;
assign possibility42 = possibility_row5 & possibility_col7 & possibility_sub6;
assign possibility43 = possibility_row5 & possibility_col8 & possibility_sub6;
assign possibility44 = possibility_row5 & possibility_col9 & possibility_sub6;
assign possibility45 = possibility_row6 & possibility_col1 & possibility_sub4;
assign possibility46 = possibility_row6 & possibility_col2 & possibility_sub4;
assign possibility47 = possibility_row6 & possibility_col3 & possibility_sub4;
assign possibility48 = possibility_row6 & possibility_col4 & possibility_sub5;
assign possibility49 = possibility_row6 & possibility_col5 & possibility_sub5;
assign possibility50 = possibility_row6 & possibility_col6 & possibility_sub5;
assign possibility51 = possibility_row6 & possibility_col7 & possibility_sub6;
assign possibility52 = possibility_row6 & possibility_col8 & possibility_sub6;
assign possibility53 = possibility_row6 & possibility_col9 & possibility_sub6;
assign possibility54 = possibility_row7 & possibility_col1 & possibility_sub7;
assign possibility55 = possibility_row7 & possibility_col2 & possibility_sub7;
assign possibility56 = possibility_row7 & possibility_col3 & possibility_sub7;
assign possibility57 = possibility_row7 & possibility_col4 & possibility_sub8;
assign possibility58 = possibility_row7 & possibility_col5 & possibility_sub8;
assign possibility59 = possibility_row7 & possibility_col6 & possibility_sub8;
assign possibility60 = possibility_row7 & possibility_col7 & possibility_sub9;
assign possibility61 = possibility_row7 & possibility_col8 & possibility_sub9;
assign possibility62 = possibility_row7 & possibility_col9 & possibility_sub9;
assign possibility63 = possibility_row8 & possibility_col1 & possibility_sub7;
assign possibility64 = possibility_row8 & possibility_col2 & possibility_sub7;
assign possibility65 = possibility_row8 & possibility_col3 & possibility_sub7;
assign possibility66 = possibility_row8 & possibility_col4 & possibility_sub8;
assign possibility67 = possibility_row8 & possibility_col5 & possibility_sub8;
assign possibility68 = possibility_row8 & possibility_col6 & possibility_sub8;
assign possibility69 = possibility_row8 & possibility_col7 & possibility_sub9;
assign possibility70 = possibility_row8 & possibility_col8 & possibility_sub9;
assign possibility71 = possibility_row8 & possibility_col9 & possibility_sub9;
assign possibility72 = possibility_row9 & possibility_col1 & possibility_sub7;
assign possibility73 = possibility_row9 & possibility_col2 & possibility_sub7;
assign possibility74 = possibility_row9 & possibility_col3 & possibility_sub7;
assign possibility75 = possibility_row9 & possibility_col4 & possibility_sub8;
assign possibility76 = possibility_row9 & possibility_col5 & possibility_sub8;
assign possibility77 = possibility_row9 & possibility_col6 & possibility_sub8;
assign possibility78 = possibility_row9 & possibility_col7 & possibility_sub9;
assign possibility79 = possibility_row9 & possibility_col8 & possibility_sub9;
assign possibility80 = possibility_row9 & possibility_col9 & possibility_sub9;
// sum_possibility
assign sum_possibility[00] = possibility00[1] + possibility00[2] + possibility00[3] + possibility00[4] + possibility00[5] + possibility00[6] + possibility00[7] + possibility00[8] + possibility00[9];
assign sum_possibility[01] = possibility01[1] + possibility01[2] + possibility01[3] + possibility01[4] + possibility01[5] + possibility01[6] + possibility01[7] + possibility01[8] + possibility01[9];
assign sum_possibility[02] = possibility02[1] + possibility02[2] + possibility02[3] + possibility02[4] + possibility02[5] + possibility02[6] + possibility02[7] + possibility02[8] + possibility02[9];
assign sum_possibility[03] = possibility03[1] + possibility03[2] + possibility03[3] + possibility03[4] + possibility03[5] + possibility03[6] + possibility03[7] + possibility03[8] + possibility03[9];
assign sum_possibility[04] = possibility04[1] + possibility04[2] + possibility04[3] + possibility04[4] + possibility04[5] + possibility04[6] + possibility04[7] + possibility04[8] + possibility04[9];
assign sum_possibility[05] = possibility05[1] + possibility05[2] + possibility05[3] + possibility05[4] + possibility05[5] + possibility05[6] + possibility05[7] + possibility05[8] + possibility05[9];
assign sum_possibility[06] = possibility06[1] + possibility06[2] + possibility06[3] + possibility06[4] + possibility06[5] + possibility06[6] + possibility06[7] + possibility06[8] + possibility06[9];
assign sum_possibility[07] = possibility07[1] + possibility07[2] + possibility07[3] + possibility07[4] + possibility07[5] + possibility07[6] + possibility07[7] + possibility07[8] + possibility07[9];
assign sum_possibility[08] = possibility08[1] + possibility08[2] + possibility08[3] + possibility08[4] + possibility08[5] + possibility08[6] + possibility08[7] + possibility08[8] + possibility08[9];
assign sum_possibility[09] = possibility09[1] + possibility09[2] + possibility09[3] + possibility09[4] + possibility09[5] + possibility09[6] + possibility09[7] + possibility09[8] + possibility09[9];
assign sum_possibility[10] = possibility10[1] + possibility10[2] + possibility10[3] + possibility10[4] + possibility10[5] + possibility10[6] + possibility10[7] + possibility10[8] + possibility10[9];
assign sum_possibility[11] = possibility11[1] + possibility11[2] + possibility11[3] + possibility11[4] + possibility11[5] + possibility11[6] + possibility11[7] + possibility11[8] + possibility11[9];
assign sum_possibility[12] = possibility12[1] + possibility12[2] + possibility12[3] + possibility12[4] + possibility12[5] + possibility12[6] + possibility12[7] + possibility12[8] + possibility12[9];
assign sum_possibility[13] = possibility13[1] + possibility13[2] + possibility13[3] + possibility13[4] + possibility13[5] + possibility13[6] + possibility13[7] + possibility13[8] + possibility13[9];
assign sum_possibility[14] = possibility14[1] + possibility14[2] + possibility14[3] + possibility14[4] + possibility14[5] + possibility14[6] + possibility14[7] + possibility14[8] + possibility14[9];
assign sum_possibility[15] = possibility15[1] + possibility15[2] + possibility15[3] + possibility15[4] + possibility15[5] + possibility15[6] + possibility15[7] + possibility15[8] + possibility15[9];
assign sum_possibility[16] = possibility16[1] + possibility16[2] + possibility16[3] + possibility16[4] + possibility16[5] + possibility16[6] + possibility16[7] + possibility16[8] + possibility16[9];
assign sum_possibility[17] = possibility17[1] + possibility17[2] + possibility17[3] + possibility17[4] + possibility17[5] + possibility17[6] + possibility17[7] + possibility17[8] + possibility17[9];
assign sum_possibility[18] = possibility18[1] + possibility18[2] + possibility18[3] + possibility18[4] + possibility18[5] + possibility18[6] + possibility18[7] + possibility18[8] + possibility18[9];
assign sum_possibility[19] = possibility19[1] + possibility19[2] + possibility19[3] + possibility19[4] + possibility19[5] + possibility19[6] + possibility19[7] + possibility19[8] + possibility19[9];
assign sum_possibility[20] = possibility20[1] + possibility20[2] + possibility20[3] + possibility20[4] + possibility20[5] + possibility20[6] + possibility20[7] + possibility20[8] + possibility20[9];
assign sum_possibility[21] = possibility21[1] + possibility21[2] + possibility21[3] + possibility21[4] + possibility21[5] + possibility21[6] + possibility21[7] + possibility21[8] + possibility21[9];
assign sum_possibility[22] = possibility22[1] + possibility22[2] + possibility22[3] + possibility22[4] + possibility22[5] + possibility22[6] + possibility22[7] + possibility22[8] + possibility22[9];
assign sum_possibility[23] = possibility23[1] + possibility23[2] + possibility23[3] + possibility23[4] + possibility23[5] + possibility23[6] + possibility23[7] + possibility23[8] + possibility23[9];
assign sum_possibility[24] = possibility24[1] + possibility24[2] + possibility24[3] + possibility24[4] + possibility24[5] + possibility24[6] + possibility24[7] + possibility24[8] + possibility24[9];
assign sum_possibility[25] = possibility25[1] + possibility25[2] + possibility25[3] + possibility25[4] + possibility25[5] + possibility25[6] + possibility25[7] + possibility25[8] + possibility25[9];
assign sum_possibility[26] = possibility26[1] + possibility26[2] + possibility26[3] + possibility26[4] + possibility26[5] + possibility26[6] + possibility26[7] + possibility26[8] + possibility26[9];
assign sum_possibility[27] = possibility27[1] + possibility27[2] + possibility27[3] + possibility27[4] + possibility27[5] + possibility27[6] + possibility27[7] + possibility27[8] + possibility27[9];
assign sum_possibility[28] = possibility28[1] + possibility28[2] + possibility28[3] + possibility28[4] + possibility28[5] + possibility28[6] + possibility28[7] + possibility28[8] + possibility28[9];
assign sum_possibility[29] = possibility29[1] + possibility29[2] + possibility29[3] + possibility29[4] + possibility29[5] + possibility29[6] + possibility29[7] + possibility29[8] + possibility29[9];
assign sum_possibility[30] = possibility30[1] + possibility30[2] + possibility30[3] + possibility30[4] + possibility30[5] + possibility30[6] + possibility30[7] + possibility30[8] + possibility30[9];
assign sum_possibility[31] = possibility31[1] + possibility31[2] + possibility31[3] + possibility31[4] + possibility31[5] + possibility31[6] + possibility31[7] + possibility31[8] + possibility31[9];
assign sum_possibility[32] = possibility32[1] + possibility32[2] + possibility32[3] + possibility32[4] + possibility32[5] + possibility32[6] + possibility32[7] + possibility32[8] + possibility32[9];
assign sum_possibility[33] = possibility33[1] + possibility33[2] + possibility33[3] + possibility33[4] + possibility33[5] + possibility33[6] + possibility33[7] + possibility33[8] + possibility33[9];
assign sum_possibility[34] = possibility34[1] + possibility34[2] + possibility34[3] + possibility34[4] + possibility34[5] + possibility34[6] + possibility34[7] + possibility34[8] + possibility34[9];
assign sum_possibility[35] = possibility35[1] + possibility35[2] + possibility35[3] + possibility35[4] + possibility35[5] + possibility35[6] + possibility35[7] + possibility35[8] + possibility35[9];
assign sum_possibility[36] = possibility36[1] + possibility36[2] + possibility36[3] + possibility36[4] + possibility36[5] + possibility36[6] + possibility36[7] + possibility36[8] + possibility36[9];
assign sum_possibility[37] = possibility37[1] + possibility37[2] + possibility37[3] + possibility37[4] + possibility37[5] + possibility37[6] + possibility37[7] + possibility37[8] + possibility37[9];
assign sum_possibility[38] = possibility38[1] + possibility38[2] + possibility38[3] + possibility38[4] + possibility38[5] + possibility38[6] + possibility38[7] + possibility38[8] + possibility38[9];
assign sum_possibility[39] = possibility39[1] + possibility39[2] + possibility39[3] + possibility39[4] + possibility39[5] + possibility39[6] + possibility39[7] + possibility39[8] + possibility39[9];
assign sum_possibility[40] = possibility40[1] + possibility40[2] + possibility40[3] + possibility40[4] + possibility40[5] + possibility40[6] + possibility40[7] + possibility40[8] + possibility40[9];
assign sum_possibility[41] = possibility41[1] + possibility41[2] + possibility41[3] + possibility41[4] + possibility41[5] + possibility41[6] + possibility41[7] + possibility41[8] + possibility41[9];
assign sum_possibility[42] = possibility42[1] + possibility42[2] + possibility42[3] + possibility42[4] + possibility42[5] + possibility42[6] + possibility42[7] + possibility42[8] + possibility42[9];
assign sum_possibility[43] = possibility43[1] + possibility43[2] + possibility43[3] + possibility43[4] + possibility43[5] + possibility43[6] + possibility43[7] + possibility43[8] + possibility43[9];
assign sum_possibility[44] = possibility44[1] + possibility44[2] + possibility44[3] + possibility44[4] + possibility44[5] + possibility44[6] + possibility44[7] + possibility44[8] + possibility44[9];
assign sum_possibility[45] = possibility45[1] + possibility45[2] + possibility45[3] + possibility45[4] + possibility45[5] + possibility45[6] + possibility45[7] + possibility45[8] + possibility45[9];
assign sum_possibility[46] = possibility46[1] + possibility46[2] + possibility46[3] + possibility46[4] + possibility46[5] + possibility46[6] + possibility46[7] + possibility46[8] + possibility46[9];
assign sum_possibility[47] = possibility47[1] + possibility47[2] + possibility47[3] + possibility47[4] + possibility47[5] + possibility47[6] + possibility47[7] + possibility47[8] + possibility47[9];
assign sum_possibility[48] = possibility48[1] + possibility48[2] + possibility48[3] + possibility48[4] + possibility48[5] + possibility48[6] + possibility48[7] + possibility48[8] + possibility48[9];
assign sum_possibility[49] = possibility49[1] + possibility49[2] + possibility49[3] + possibility49[4] + possibility49[5] + possibility49[6] + possibility49[7] + possibility49[8] + possibility49[9];
assign sum_possibility[50] = possibility50[1] + possibility50[2] + possibility50[3] + possibility50[4] + possibility50[5] + possibility50[6] + possibility50[7] + possibility50[8] + possibility50[9];
assign sum_possibility[51] = possibility51[1] + possibility51[2] + possibility51[3] + possibility51[4] + possibility51[5] + possibility51[6] + possibility51[7] + possibility51[8] + possibility51[9];
assign sum_possibility[52] = possibility52[1] + possibility52[2] + possibility52[3] + possibility52[4] + possibility52[5] + possibility52[6] + possibility52[7] + possibility52[8] + possibility52[9];
assign sum_possibility[53] = possibility53[1] + possibility53[2] + possibility53[3] + possibility53[4] + possibility53[5] + possibility53[6] + possibility53[7] + possibility53[8] + possibility53[9];
assign sum_possibility[54] = possibility54[1] + possibility54[2] + possibility54[3] + possibility54[4] + possibility54[5] + possibility54[6] + possibility54[7] + possibility54[8] + possibility54[9];
assign sum_possibility[55] = possibility55[1] + possibility55[2] + possibility55[3] + possibility55[4] + possibility55[5] + possibility55[6] + possibility55[7] + possibility55[8] + possibility55[9];
assign sum_possibility[56] = possibility56[1] + possibility56[2] + possibility56[3] + possibility56[4] + possibility56[5] + possibility56[6] + possibility56[7] + possibility56[8] + possibility56[9];
assign sum_possibility[57] = possibility57[1] + possibility57[2] + possibility57[3] + possibility57[4] + possibility57[5] + possibility57[6] + possibility57[7] + possibility57[8] + possibility57[9];
assign sum_possibility[58] = possibility58[1] + possibility58[2] + possibility58[3] + possibility58[4] + possibility58[5] + possibility58[6] + possibility58[7] + possibility58[8] + possibility58[9];
assign sum_possibility[59] = possibility59[1] + possibility59[2] + possibility59[3] + possibility59[4] + possibility59[5] + possibility59[6] + possibility59[7] + possibility59[8] + possibility59[9];
assign sum_possibility[60] = possibility60[1] + possibility60[2] + possibility60[3] + possibility60[4] + possibility60[5] + possibility60[6] + possibility60[7] + possibility60[8] + possibility60[9];
assign sum_possibility[61] = possibility61[1] + possibility61[2] + possibility61[3] + possibility61[4] + possibility61[5] + possibility61[6] + possibility61[7] + possibility61[8] + possibility61[9];
assign sum_possibility[62] = possibility62[1] + possibility62[2] + possibility62[3] + possibility62[4] + possibility62[5] + possibility62[6] + possibility62[7] + possibility62[8] + possibility62[9];
assign sum_possibility[63] = possibility63[1] + possibility63[2] + possibility63[3] + possibility63[4] + possibility63[5] + possibility63[6] + possibility63[7] + possibility63[8] + possibility63[9];
assign sum_possibility[64] = possibility64[1] + possibility64[2] + possibility64[3] + possibility64[4] + possibility64[5] + possibility64[6] + possibility64[7] + possibility64[8] + possibility64[9];
assign sum_possibility[65] = possibility65[1] + possibility65[2] + possibility65[3] + possibility65[4] + possibility65[5] + possibility65[6] + possibility65[7] + possibility65[8] + possibility65[9];
assign sum_possibility[66] = possibility66[1] + possibility66[2] + possibility66[3] + possibility66[4] + possibility66[5] + possibility66[6] + possibility66[7] + possibility66[8] + possibility66[9];
assign sum_possibility[67] = possibility67[1] + possibility67[2] + possibility67[3] + possibility67[4] + possibility67[5] + possibility67[6] + possibility67[7] + possibility67[8] + possibility67[9];
assign sum_possibility[68] = possibility68[1] + possibility68[2] + possibility68[3] + possibility68[4] + possibility68[5] + possibility68[6] + possibility68[7] + possibility68[8] + possibility68[9];
assign sum_possibility[69] = possibility69[1] + possibility69[2] + possibility69[3] + possibility69[4] + possibility69[5] + possibility69[6] + possibility69[7] + possibility69[8] + possibility69[9];
assign sum_possibility[70] = possibility70[1] + possibility70[2] + possibility70[3] + possibility70[4] + possibility70[5] + possibility70[6] + possibility70[7] + possibility70[8] + possibility70[9];
assign sum_possibility[71] = possibility71[1] + possibility71[2] + possibility71[3] + possibility71[4] + possibility71[5] + possibility71[6] + possibility71[7] + possibility71[8] + possibility71[9];
assign sum_possibility[72] = possibility72[1] + possibility72[2] + possibility72[3] + possibility72[4] + possibility72[5] + possibility72[6] + possibility72[7] + possibility72[8] + possibility72[9];
assign sum_possibility[73] = possibility73[1] + possibility73[2] + possibility73[3] + possibility73[4] + possibility73[5] + possibility73[6] + possibility73[7] + possibility73[8] + possibility73[9];
assign sum_possibility[74] = possibility74[1] + possibility74[2] + possibility74[3] + possibility74[4] + possibility74[5] + possibility74[6] + possibility74[7] + possibility74[8] + possibility74[9];
assign sum_possibility[75] = possibility75[1] + possibility75[2] + possibility75[3] + possibility75[4] + possibility75[5] + possibility75[6] + possibility75[7] + possibility75[8] + possibility75[9];
assign sum_possibility[76] = possibility76[1] + possibility76[2] + possibility76[3] + possibility76[4] + possibility76[5] + possibility76[6] + possibility76[7] + possibility76[8] + possibility76[9];
assign sum_possibility[77] = possibility77[1] + possibility77[2] + possibility77[3] + possibility77[4] + possibility77[5] + possibility77[6] + possibility77[7] + possibility77[8] + possibility77[9];
assign sum_possibility[78] = possibility78[1] + possibility78[2] + possibility78[3] + possibility78[4] + possibility78[5] + possibility78[6] + possibility78[7] + possibility78[8] + possibility78[9];
assign sum_possibility[79] = possibility79[1] + possibility79[2] + possibility79[3] + possibility79[4] + possibility79[5] + possibility79[6] + possibility79[7] + possibility79[8] + possibility79[9];
assign sum_possibility[80] = possibility80[1] + possibility80[2] + possibility80[3] + possibility80[4] + possibility80[5] + possibility80[6] + possibility80[7] + possibility80[8] + possibility80[9];
// fill
find_ones_LSB_16 find_ones00(.x(possibility00), .y(fill[00]));
find_ones_LSB_16 find_ones01(.x(possibility01), .y(fill[01]));
find_ones_LSB_16 find_ones02(.x(possibility02), .y(fill[02]));
find_ones_LSB_16 find_ones03(.x(possibility03), .y(fill[03]));
find_ones_LSB_16 find_ones04(.x(possibility04), .y(fill[04]));
find_ones_LSB_16 find_ones05(.x(possibility05), .y(fill[05]));
find_ones_LSB_16 find_ones06(.x(possibility06), .y(fill[06]));
find_ones_LSB_16 find_ones07(.x(possibility07), .y(fill[07]));
find_ones_LSB_16 find_ones08(.x(possibility08), .y(fill[08]));
find_ones_LSB_16 find_ones09(.x(possibility09), .y(fill[09]));
find_ones_LSB_16 find_ones10(.x(possibility10), .y(fill[10]));
find_ones_LSB_16 find_ones11(.x(possibility11), .y(fill[11]));
find_ones_LSB_16 find_ones12(.x(possibility12), .y(fill[12]));
find_ones_LSB_16 find_ones13(.x(possibility13), .y(fill[13]));
find_ones_LSB_16 find_ones14(.x(possibility14), .y(fill[14]));
find_ones_LSB_16 find_ones15(.x(possibility15), .y(fill[15]));
find_ones_LSB_16 find_ones16(.x(possibility16), .y(fill[16]));
find_ones_LSB_16 find_ones17(.x(possibility17), .y(fill[17]));
find_ones_LSB_16 find_ones18(.x(possibility18), .y(fill[18]));
find_ones_LSB_16 find_ones19(.x(possibility19), .y(fill[19]));
find_ones_LSB_16 find_ones20(.x(possibility20), .y(fill[20]));
find_ones_LSB_16 find_ones21(.x(possibility21), .y(fill[21]));
find_ones_LSB_16 find_ones22(.x(possibility22), .y(fill[22]));
find_ones_LSB_16 find_ones23(.x(possibility23), .y(fill[23]));
find_ones_LSB_16 find_ones24(.x(possibility24), .y(fill[24]));
find_ones_LSB_16 find_ones25(.x(possibility25), .y(fill[25]));
find_ones_LSB_16 find_ones26(.x(possibility26), .y(fill[26]));
find_ones_LSB_16 find_ones27(.x(possibility27), .y(fill[27]));
find_ones_LSB_16 find_ones28(.x(possibility28), .y(fill[28]));
find_ones_LSB_16 find_ones29(.x(possibility29), .y(fill[29]));
find_ones_LSB_16 find_ones30(.x(possibility30), .y(fill[30]));
find_ones_LSB_16 find_ones31(.x(possibility31), .y(fill[31]));
find_ones_LSB_16 find_ones32(.x(possibility32), .y(fill[32]));
find_ones_LSB_16 find_ones33(.x(possibility33), .y(fill[33]));
find_ones_LSB_16 find_ones34(.x(possibility34), .y(fill[34]));
find_ones_LSB_16 find_ones35(.x(possibility35), .y(fill[35]));
find_ones_LSB_16 find_ones36(.x(possibility36), .y(fill[36]));
find_ones_LSB_16 find_ones37(.x(possibility37), .y(fill[37]));
find_ones_LSB_16 find_ones38(.x(possibility38), .y(fill[38]));
find_ones_LSB_16 find_ones39(.x(possibility39), .y(fill[39]));
find_ones_LSB_16 find_ones40(.x(possibility40), .y(fill[40]));
find_ones_LSB_16 find_ones41(.x(possibility41), .y(fill[41]));
find_ones_LSB_16 find_ones42(.x(possibility42), .y(fill[42]));
find_ones_LSB_16 find_ones43(.x(possibility43), .y(fill[43]));
find_ones_LSB_16 find_ones44(.x(possibility44), .y(fill[44]));
find_ones_LSB_16 find_ones45(.x(possibility45), .y(fill[45]));
find_ones_LSB_16 find_ones46(.x(possibility46), .y(fill[46]));
find_ones_LSB_16 find_ones47(.x(possibility47), .y(fill[47]));
find_ones_LSB_16 find_ones48(.x(possibility48), .y(fill[48]));
find_ones_LSB_16 find_ones49(.x(possibility49), .y(fill[49]));
find_ones_LSB_16 find_ones50(.x(possibility50), .y(fill[50]));
find_ones_LSB_16 find_ones51(.x(possibility51), .y(fill[51]));
find_ones_LSB_16 find_ones52(.x(possibility52), .y(fill[52]));
find_ones_LSB_16 find_ones53(.x(possibility53), .y(fill[53]));
find_ones_LSB_16 find_ones54(.x(possibility54), .y(fill[54]));
find_ones_LSB_16 find_ones55(.x(possibility55), .y(fill[55]));
find_ones_LSB_16 find_ones56(.x(possibility56), .y(fill[56]));
find_ones_LSB_16 find_ones57(.x(possibility57), .y(fill[57]));
find_ones_LSB_16 find_ones58(.x(possibility58), .y(fill[58]));
find_ones_LSB_16 find_ones59(.x(possibility59), .y(fill[59]));
find_ones_LSB_16 find_ones60(.x(possibility60), .y(fill[60]));
find_ones_LSB_16 find_ones61(.x(possibility61), .y(fill[61]));
find_ones_LSB_16 find_ones62(.x(possibility62), .y(fill[62]));
find_ones_LSB_16 find_ones63(.x(possibility63), .y(fill[63]));
find_ones_LSB_16 find_ones64(.x(possibility64), .y(fill[64]));
find_ones_LSB_16 find_ones65(.x(possibility65), .y(fill[65]));
find_ones_LSB_16 find_ones66(.x(possibility66), .y(fill[66]));
find_ones_LSB_16 find_ones67(.x(possibility67), .y(fill[67]));
find_ones_LSB_16 find_ones68(.x(possibility68), .y(fill[68]));
find_ones_LSB_16 find_ones69(.x(possibility69), .y(fill[69]));
find_ones_LSB_16 find_ones70(.x(possibility70), .y(fill[70]));
find_ones_LSB_16 find_ones71(.x(possibility71), .y(fill[71]));
find_ones_LSB_16 find_ones72(.x(possibility72), .y(fill[72]));
find_ones_LSB_16 find_ones73(.x(possibility73), .y(fill[73]));
find_ones_LSB_16 find_ones74(.x(possibility74), .y(fill[74]));
find_ones_LSB_16 find_ones75(.x(possibility75), .y(fill[75]));
find_ones_LSB_16 find_ones76(.x(possibility76), .y(fill[76]));
find_ones_LSB_16 find_ones77(.x(possibility77), .y(fill[77]));
find_ones_LSB_16 find_ones78(.x(possibility78), .y(fill[78]));
find_ones_LSB_16 find_ones79(.x(possibility79), .y(fill[79]));
find_ones_LSB_16 find_ones80(.x(possibility80), .y(fill[80]));
// blank_LSB
find_ones_LSB_128 find_ones_blank(.x(blank), .y(blank_LSB));
// s2
always@(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (i = 0; i < 81; i = i + 1) begin
			s2[i] <= 0;
		end
	end
	else begin
		for (i = 0; i < 81; i = i + 1) begin
			s2[i] <= s[i];
		end
	end
end
// diff
genvar gj;
generate
for (gj = 0; gj < 81; gj = gj + 1) begin: diff_loop
	assign diff[gj] = (s2[gj] != s[gj]);
end
endgenerate
// finish
assign finish = s[00] + s[01] + s[02] + s[03] + s[04] + s[05] + s[06] + s[07] + s[08]
			  + s[09] + s[10] + s[11] + s[12] + s[13] + s[14] + s[15] + s[16] + s[17]
			  + s[18] + s[19] + s[20] + s[21] + s[22] + s[23] + s[24] + s[25] + s[26]
			  + s[27] + s[28] + s[29] + s[30] + s[31] + s[32] + s[33] + s[34] + s[35]
			  + s[36] + s[37] + s[38] + s[39] + s[40] + s[41] + s[42] + s[43] + s[44]
			  + s[45] + s[46] + s[47] + s[48] + s[49] + s[50] + s[51] + s[52] + s[53]
			  + s[54] + s[55] + s[56] + s[57] + s[58] + s[59] + s[60] + s[61] + s[62]
			  + s[63] + s[64] + s[65] + s[66] + s[67] + s[68] + s[69] + s[70] + s[71]
			  + s[72] + s[73] + s[74] + s[75] + s[76] + s[77] + s[78] + s[79] + s[80];

// out_valid
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		out_valid <= 0;
	else if (curr_state == OUTPUT_NO)
		out_valid <= 1;
	else if (curr_state == OUTPUT_YES)
		out_valid <= 1;
	else
		out_valid <= 0;
end
// out
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		out <= 0;
	else if (curr_state == OUTPUT_NO)
		out <= 10;
	else if (curr_state == OUTPUT_YES)
		out <= s[blank_pos[count_out]];
	else
		out <= 0;
end
// count_calcuate
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		count_calcuate <= 0;
	else if (curr_state == CALCUATE0)
		count_calcuate <= count_calcuate + 1;
	else if (curr_state == IDLE)
		count_calcuate <= 0;
	else
		count_calcuate <= count_calcuate;
end
// count_out
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		count_out <= 0;
	else if (curr_state == OUTPUT_YES)
		count_out <= count_out + 1;
	else if (curr_state == IDLE)
		count_out <= 0;
	else
		count_out <= count_out;
end
// curr_state
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		curr_state <= IDLE;
	else begin
		curr_state <= next_state;
		// if ((curr_state != 0) && (curr_state != 1) && (curr_state != 9) && (curr_state != 10)) begin
			// $display("curr_state = %d",curr_state);
			// $display("%1d %1d %1d %1d %1d %1d %1d %1d %1d - %1d %1d %1d %1d %1d %1d %1d %1d %1d", s[00], s[01], s[02], s[03], s[04], s[05], s[06], s[07], s[08], blank[00], blank[01], blank[02], blank[03], blank[04], blank[05], blank[06], blank[07], blank[08]);
			// $display("%1d %1d %1d %1d %1d %1d %1d %1d %1d - %1d %1d %1d %1d %1d %1d %1d %1d %1d", s[09], s[10], s[11], s[12], s[13], s[14], s[15], s[16], s[17], blank[09], blank[10], blank[11], blank[12], blank[13], blank[14], blank[15], blank[16], blank[17]);
			// $display("%1d %1d %1d %1d %1d %1d %1d %1d %1d - %1d %1d %1d %1d %1d %1d %1d %1d %1d", s[18], s[19], s[20], s[21], s[22], s[23], s[24], s[25], s[26], blank[18], blank[19], blank[20], blank[21], blank[22], blank[23], blank[24], blank[25], blank[26]);
			// $display("%1d %1d %1d %1d %1d %1d %1d %1d %1d - %1d %1d %1d %1d %1d %1d %1d %1d %1d", s[27], s[28], s[29], s[30], s[31], s[32], s[33], s[34], s[35], blank[27], blank[28], blank[29], blank[30], blank[31], blank[32], blank[33], blank[34], blank[35]);
			// $display("%1d %1d %1d %1d %1d %1d %1d %1d %1d - %1d %1d %1d %1d %1d %1d %1d %1d %1d", s[36], s[37], s[38], s[39], s[40], s[41], s[42], s[43], s[44], blank[36], blank[37], blank[38], blank[39], blank[40], blank[41], blank[42], blank[43], blank[44]);
			// $display("%1d %1d %1d %1d %1d %1d %1d %1d %1d - %1d %1d %1d %1d %1d %1d %1d %1d %1d", s[45], s[46], s[47], s[48], s[49], s[50], s[51], s[52], s[53], blank[45], blank[46], blank[47], blank[48], blank[49], blank[50], blank[51], blank[52], blank[53]);
			// $display("%1d %1d %1d %1d %1d %1d %1d %1d %1d - %1d %1d %1d %1d %1d %1d %1d %1d %1d", s[54], s[55], s[56], s[57], s[58], s[59], s[60], s[61], s[62], blank[54], blank[55], blank[56], blank[57], blank[58], blank[59], blank[60], blank[61], blank[62]);
			// $display("%1d %1d %1d %1d %1d %1d %1d %1d %1d - %1d %1d %1d %1d %1d %1d %1d %1d %1d", s[63], s[64], s[65], s[66], s[67], s[68], s[69], s[70], s[71], blank[63], blank[64], blank[65], blank[66], blank[67], blank[68], blank[69], blank[70], blank[71]);
			// $display("%1d %1d %1d %1d %1d %1d %1d %1d %1d - %1d %1d %1d %1d %1d %1d %1d %1d %1d", s[72], s[73], s[74], s[75], s[76], s[77], s[78], s[79], s[80], blank[72], blank[73], blank[74], blank[75], blank[76], blank[77], blank[78], blank[79], blank[80]);
		// end
	end
end
// next_state
always @(*) begin
	if (!rst_n) next_state = IDLE;
	else begin
		case (curr_state)
		IDLE: begin				// 0
			if (in_valid)
				next_state = SODOKU;
			else
				next_state = IDLE;
		end
		SODOKU: begin			// 1
			if (in_valid == 0) begin
				if ((fail_row > 0) || (fail_col > 0) || (fail_sub > 0))
					next_state = OUTPUT_NO;
				else
					next_state = CALCUATE0;
			end
			else
				next_state = SODOKU;
		end
		CALCUATE0: begin		// 2
			if (count_calcuate > 1) begin
				if (finish == 405)
					next_state = OUTPUT_YES;
				else if ((fail_row > 0) || (fail_col > 0) || (fail_sub > 0))
					next_state = OUTPUT_NO;
				else begin
					if (diff == 0)
						next_state = GUESS1;
					else
						next_state = CALCUATE0;
				end
			end
			else
				next_state = CALCUATE0;
		end
		GUESS1: begin			// 3
			if (fill[blank_LSB] + k1 >= 10)
				next_state = OUTPUT_NO;
			else
			next_state = CALCUATE1;
		end
		CALCUATE1: begin		// 4
			if (finish == 405)
				next_state = OUTPUT_YES;
			else if ((fail_row > 0) || (fail_col > 0) || (fail_sub > 0))
				next_state = GUESS_WRONG1;
			else begin
				if (diff == 0)
					next_state = GUESS2;
				else
					next_state = CALCUATE1;
			end
		end
		GUESS_WRONG1: begin		// 5
			// if (k1 == 9)
				// next_state = OUTPUT_NO;
			// else
				next_state = GUESS1;
		end
		GUESS2: begin			// 6
			next_state = CALCUATE2;
		end
		CALCUATE2: begin		// 7
			if (finish == 405)
				next_state = OUTPUT_YES;
			else if ((fail_row > 0) || (fail_col > 0) || (fail_sub > 0))
				next_state = OUTPUT_NO;
			else begin
				if (diff == 0)
					next_state = OUTPUT_NO;
				else
					next_state = CALCUATE2;
			end
		end
		GUESS_WRONG2: begin		// 8
			next_state = GUESS2;
		end
		OUTPUT_NO: begin		// 9
			next_state = IDLE;
		end
		OUTPUT_YES: begin		// 10
			if (count_out >= 14)
				next_state = IDLE;
			else
				next_state = OUTPUT_YES;
		end
		default: next_state = IDLE;
		endcase
	end
end

endmodule


module grid_check(
input [3:0] g1, g2, g3, g4, g5, g6, g7, g8, g9,
output fail,
output [9:0] possibility
);
wire [9:0] g1_check;
wire [9:0] g2_check;
wire [9:0] g3_check;
wire [9:0] g4_check;
wire [9:0] g5_check;
wire [9:0] g6_check;
wire [9:0] g7_check;
wire [9:0] g8_check;
wire [9:0] g9_check;
wire [3:0] fail_check1;
wire [3:0] fail_check2;
wire [3:0] fail_check3;
wire [3:0] fail_check4;
wire [3:0] fail_check5;
wire [3:0] fail_check6;
wire [3:0] fail_check7;
wire [3:0] fail_check8;
wire [3:0] fail_check9;
// g1_check
assign g1_check[0] = (g1 == 0);
assign g1_check[1] = (g1 == 1);
assign g1_check[2] = (g1 == 2);
assign g1_check[3] = (g1 == 3);
assign g1_check[4] = (g1 == 4);
assign g1_check[5] = (g1 == 5);
assign g1_check[6] = (g1 == 6);
assign g1_check[7] = (g1 == 7);
assign g1_check[8] = (g1 == 8);
assign g1_check[9] = (g1 == 9);
// g2_check
assign g2_check[0] = (g2 == 0);
assign g2_check[1] = (g2 == 1);
assign g2_check[2] = (g2 == 2);
assign g2_check[3] = (g2 == 3);
assign g2_check[4] = (g2 == 4);
assign g2_check[5] = (g2 == 5);
assign g2_check[6] = (g2 == 6);
assign g2_check[7] = (g2 == 7);
assign g2_check[8] = (g2 == 8);
assign g2_check[9] = (g2 == 9);
// g3_check
assign g3_check[0] = (g3 == 0);
assign g3_check[1] = (g3 == 1);
assign g3_check[2] = (g3 == 2);
assign g3_check[3] = (g3 == 3);
assign g3_check[4] = (g3 == 4);
assign g3_check[5] = (g3 == 5);
assign g3_check[6] = (g3 == 6);
assign g3_check[7] = (g3 == 7);
assign g3_check[8] = (g3 == 8);
assign g3_check[9] = (g3 == 9);
// g4_check
assign g4_check[0] = (g4 == 0);
assign g4_check[1] = (g4 == 1);
assign g4_check[2] = (g4 == 2);
assign g4_check[3] = (g4 == 3);
assign g4_check[4] = (g4 == 4);
assign g4_check[5] = (g4 == 5);
assign g4_check[6] = (g4 == 6);
assign g4_check[7] = (g4 == 7);
assign g4_check[8] = (g4 == 8);
assign g4_check[9] = (g4 == 9);
// g5_check
assign g5_check[0] = (g5 == 0);
assign g5_check[1] = (g5 == 1);
assign g5_check[2] = (g5 == 2);
assign g5_check[3] = (g5 == 3);
assign g5_check[4] = (g5 == 4);
assign g5_check[5] = (g5 == 5);
assign g5_check[6] = (g5 == 6);
assign g5_check[7] = (g5 == 7);
assign g5_check[8] = (g5 == 8);
assign g5_check[9] = (g5 == 9);
// g6_check
assign g6_check[0] = (g6 == 0);
assign g6_check[1] = (g6 == 1);
assign g6_check[2] = (g6 == 2);
assign g6_check[3] = (g6 == 3);
assign g6_check[4] = (g6 == 4);
assign g6_check[5] = (g6 == 5);
assign g6_check[6] = (g6 == 6);
assign g6_check[7] = (g6 == 7);
assign g6_check[8] = (g6 == 8);
assign g6_check[9] = (g6 == 9);
// g7_check
assign g7_check[0] = (g7 == 0);
assign g7_check[1] = (g7 == 1);
assign g7_check[2] = (g7 == 2);
assign g7_check[3] = (g7 == 3);
assign g7_check[4] = (g7 == 4);
assign g7_check[5] = (g7 == 5);
assign g7_check[6] = (g7 == 6);
assign g7_check[7] = (g7 == 7);
assign g7_check[8] = (g7 == 8);
assign g7_check[9] = (g7 == 9);
// g8_check
assign g8_check[0] = (g8 == 0);
assign g8_check[1] = (g8 == 1);
assign g8_check[2] = (g8 == 2);
assign g8_check[3] = (g8 == 3);
assign g8_check[4] = (g8 == 4);
assign g8_check[5] = (g8 == 5);
assign g8_check[6] = (g8 == 6);
assign g8_check[7] = (g8 == 7);
assign g8_check[8] = (g8 == 8);
assign g8_check[9] = (g8 == 9);
// g9_check
assign g9_check[0] = (g9 == 0);
assign g9_check[1] = (g9 == 1);
assign g9_check[2] = (g9 == 2);
assign g9_check[3] = (g9 == 3);
assign g9_check[4] = (g9 == 4);
assign g9_check[5] = (g9 == 5);
assign g9_check[6] = (g9 == 6);
assign g9_check[7] = (g9 == 7);
assign g9_check[8] = (g9 == 8);
assign g9_check[9] = (g9 == 9);
// fail_check
assign fail_check1 = g1_check[1] + g2_check[1] + g3_check[1] + g4_check[1] + g5_check[1] + g6_check[1] + g7_check[1] + g8_check[1] + g9_check[1];
assign fail_check2 = g1_check[2] + g2_check[2] + g3_check[2] + g4_check[2] + g5_check[2] + g6_check[2] + g7_check[2] + g8_check[2] + g9_check[2];
assign fail_check3 = g1_check[3] + g2_check[3] + g3_check[3] + g4_check[3] + g5_check[3] + g6_check[3] + g7_check[3] + g8_check[3] + g9_check[3];
assign fail_check4 = g1_check[4] + g2_check[4] + g3_check[4] + g4_check[4] + g5_check[4] + g6_check[4] + g7_check[4] + g8_check[4] + g9_check[4];
assign fail_check5 = g1_check[5] + g2_check[5] + g3_check[5] + g4_check[5] + g5_check[5] + g6_check[5] + g7_check[5] + g8_check[5] + g9_check[5];
assign fail_check6 = g1_check[6] + g2_check[6] + g3_check[6] + g4_check[6] + g5_check[6] + g6_check[6] + g7_check[6] + g8_check[6] + g9_check[6];
assign fail_check7 = g1_check[7] + g2_check[7] + g3_check[7] + g4_check[7] + g5_check[7] + g6_check[7] + g7_check[7] + g8_check[7] + g9_check[7];
assign fail_check8 = g1_check[8] + g2_check[8] + g3_check[8] + g4_check[8] + g5_check[8] + g6_check[8] + g7_check[8] + g8_check[8] + g9_check[8];
assign fail_check9 = g1_check[9] + g2_check[9] + g3_check[9] + g4_check[9] + g5_check[9] + g6_check[9] + g7_check[9] + g8_check[9] + g9_check[9];
// fail
assign fail = (fail_check1 > 1) || (fail_check2 > 1) || (fail_check3 > 1) || (fail_check4 > 1) || (fail_check5 > 1) || (fail_check6 > 1) || (fail_check7 > 1) || (fail_check8 > 1) || (fail_check9 > 1);
// possibility
assign possibility[0] = 0;
assign possibility[1] = !(g1_check[1] || g2_check[1] || g3_check[1] || g4_check[1] || g5_check[1] || g6_check[1] || g7_check[1] || g8_check[1] || g9_check[1]);
assign possibility[2] = !(g1_check[2] || g2_check[2] || g3_check[2] || g4_check[2] || g5_check[2] || g6_check[2] || g7_check[2] || g8_check[2] || g9_check[2]);
assign possibility[3] = !(g1_check[3] || g2_check[3] || g3_check[3] || g4_check[3] || g5_check[3] || g6_check[3] || g7_check[3] || g8_check[3] || g9_check[3]);
assign possibility[4] = !(g1_check[4] || g2_check[4] || g3_check[4] || g4_check[4] || g5_check[4] || g6_check[4] || g7_check[4] || g8_check[4] || g9_check[4]);
assign possibility[5] = !(g1_check[5] || g2_check[5] || g3_check[5] || g4_check[5] || g5_check[5] || g6_check[5] || g7_check[5] || g8_check[5] || g9_check[5]);
assign possibility[6] = !(g1_check[6] || g2_check[6] || g3_check[6] || g4_check[6] || g5_check[6] || g6_check[6] || g7_check[6] || g8_check[6] || g9_check[6]);
assign possibility[7] = !(g1_check[7] || g2_check[7] || g3_check[7] || g4_check[7] || g5_check[7] || g6_check[7] || g7_check[7] || g8_check[7] || g9_check[7]);
assign possibility[8] = !(g1_check[8] || g2_check[8] || g3_check[8] || g4_check[8] || g5_check[8] || g6_check[8] || g7_check[8] || g8_check[8] || g9_check[8]);
assign possibility[9] = !(g1_check[9] || g2_check[9] || g3_check[9] || g4_check[9] || g5_check[9] || g6_check[9] || g7_check[9] || g8_check[9] || g9_check[9]);

endmodule


module find_ones_LSB_16(
input [9:0] x,
output [3:0] y);

wire [15:0] data_16;
wire [7:0] data_8;
wire [3:0] data_4;
wire [1:0] data_2;

assign data_16= {6'b0,x[9:0]};
assign y[3] = ~| data_16[7:0];
assign data_8 = y[3] ? data_16[15:8] : data_16[7:0];
assign y[2] = ~| data_8[3:0];
assign data_4 = y[2] ? data_8[7:4] : data_8[3:0];
assign y[1] = ~| data_4[1:0];
assign data_2 = y[1] ? data_4[3:2] : data_4[1:0];
assign y[0] = ~data_2[0];

endmodule


module find_ones_LSB_128(
input [80:0] x,
output [6:0] y);

wire [127:0] data_128;
wire [63:0] data_64;
wire [31:0] data_32;
wire [15:0] data_16;
wire [7:0] data_8;
wire [3:0] data_4;
wire [1:0] data_2;

assign data_128 = {47'b0,x[80:0]};
assign y[6] = ~| data_128[63:0];
assign data_64= y[6] ? data_128[127:64] : data_128[63:0];
assign y[5] = ~| data_64[31:0];
assign data_32= y[5] ? data_64[63:32] : data_64[31:0];
assign y[4] = ~| data_32[15:0];
assign data_16= y[4] ? data_32[31:16] : data_32[15:0];
assign y[3] = ~| data_16[7:0];
assign data_8 = y[3] ? data_16[15:8] : data_16[7:0];
assign y[2] = ~| data_8[3:0];
assign data_4 = y[2] ? data_8[7:4] : data_8[3:0];
assign y[1] = ~| data_4[1:0];
assign data_2 = y[1] ? data_4[3:2] : data_4[1:0];
assign y[0] = ~data_2[0];

endmodule