
module SME(
    clk,
    rst_n,
    chardata,
    isstring,
    ispattern,
    out_valid,
    match,
    match_index
);

input clk;
input rst_n;
input [7:0] chardata;
input isstring;
input ispattern;
output reg out_valid;
output reg match;
output reg [4:0] match_index;

parameter IDLE          = 3'b000; // 0
parameter STRING        = 3'b001; // 1
parameter STRING_SHIFT  = 3'b010; // 2
parameter PATTERN       = 3'b011; // 3
parameter CALCUATE      = 3'b100; // 4
parameter CALCUATE2     = 3'b101; // 5
parameter OUTPUT        = 3'b110; // 6
parameter OUTPUT_STAR   = 3'b111; // 7

// store input
reg [5:0] count_string;  // 0~32
reg [3:0] count_pattern; // 0~8
reg [7:0] s_in[33:0];
reg [7:0] s[45:0];
reg [7:0] p[7:0];
reg [5:0] i;
// FSM
reg [2:0] curr_state;    // 0~7
reg [2:0] next_state;    // 0~7
// calcuate match_index
wire [38:0] m38;
wire [5:0] sum_m38;
wire [5:0] y_out;
wire [5:0] shift_string;
wire [3:0] shift_pattern;
reg [7:0] p_start;
reg [5:0] index_value;
// calcuate star match_index
reg  star_flag;
reg  star_flag2;
// reg [7:0] star_position;
// star after
wire [38:0] m38_after;
wire [5:0] sum_m38_after;
wire [5:0] y_after;
wire [5:0] shift_pattern_after;
reg [3:0] count_p_after;
reg [7:0] p_after[7:0];
// reg [7:0] p_after_start;
// reg [5:0] index_value_after;

assign shift_string = 32-count_string;
assign shift_pattern = 8-count_pattern;
assign shift_pattern_after = 8-count_p_after;

// count_string
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		count_string <= 0;
	else if (curr_state == IDLE) begin
		if (isstring)
			count_string <= 0;
		else
			count_string <= count_string;
	end
	else if (curr_state == STRING)
		count_string <= count_string + 1;
	else
		count_string <= count_string;
end
// count_pattern
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		count_pattern <= 0;
	else if (ispattern) begin
		if (chardata == 42)
			count_pattern <= count_pattern;
		else if (star_flag2)
			count_pattern <= count_pattern;
		else
			count_pattern <= count_pattern + 1;
	end
	else if (curr_state == OUTPUT)
		count_pattern <= 0;
	else
		count_pattern <= count_pattern;
end
// s_in33
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		s_in[33] <= 0;
	else if (isstring == 1)
		s_in[33] <= chardata;
	else if (curr_state == STRING_SHIFT)
		if (count_string==32)
			s_in[33] <= 32;
		else
			s_in[33] <= s_in[33];
	else
		s_in[33] <= s_in[33];
end
// s00 ~ s31
always@(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (i = 0; i < 33; i = i + 1) begin
			s_in[i] <= 94;
		end
	end
	else if (curr_state == STRING) begin
		s_in[32] <= s_in[33];
		s_in[31] <= s_in[32];
		s_in[30] <= s_in[31];
		s_in[29] <= s_in[30];
		s_in[28] <= s_in[29];
		s_in[27] <= s_in[28];
		s_in[26] <= s_in[27];
		s_in[25] <= s_in[26];
		s_in[24] <= s_in[25];
		s_in[23] <= s_in[24];
		s_in[22] <= s_in[23];
		s_in[21] <= s_in[22];
		s_in[20] <= s_in[21];
		s_in[19] <= s_in[20];
		s_in[18] <= s_in[19];
		s_in[17] <= s_in[18];
		s_in[16] <= s_in[17];
		s_in[15] <= s_in[16];
		s_in[14] <= s_in[15];
		s_in[13] <= s_in[14];
		s_in[12] <= s_in[13];
		s_in[11] <= s_in[12];
		s_in[10] <= s_in[11];
		s_in[09] <= s_in[10];
		s_in[08] <= s_in[09];
		s_in[07] <= s_in[08];
		s_in[06] <= s_in[07];
		s_in[05] <= s_in[06];
		s_in[04] <= s_in[05];
		s_in[03] <= s_in[04];
		s_in[02] <= s_in[03];
		s_in[01] <= s_in[02];
		s_in[00] <= s_in[01];
	end
	else if (curr_state == OUTPUT) begin
		for (i = 0; i < 33; i = i + 1) begin
			s_in[i] <= 94;
		end
	end
	else begin
		for (i = 0; i < 33; i = i + 1) begin
			s_in[i] <= s_in[i];
		end
	end
end
//s
always@(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		s[00] <= 94; s[07] <= 94; s[14] <= 94; s[21] <= 94; s[28] <= 94; s[35] <= 36; s[42] <= 36;
		s[01] <= 94; s[08] <= 94; s[15] <= 94; s[22] <= 94; s[29] <= 94; s[36] <= 36; s[43] <= 36;
		s[02] <= 94; s[09] <= 94; s[16] <= 94; s[23] <= 94; s[30] <= 94; s[37] <= 36; s[44] <= 36;
		s[03] <= 94; s[10] <= 94; s[17] <= 94; s[24] <= 94; s[31] <= 94; s[38] <= 36; s[45] <= 36;
		s[04] <= 94; s[11] <= 94; s[18] <= 94; s[25] <= 94; s[32] <= 94; s[39] <= 36;
		s[05] <= 94; s[12] <= 94; s[19] <= 94; s[26] <= 94; s[33] <= 94; s[40] <= 36;
		s[06] <= 94; s[13] <= 94; s[20] <= 94; s[27] <= 94; s[34] <= 36; s[41] <= 36;
	end
	else if (curr_state == STRING_SHIFT) begin
		s[07] <= s_in[01]; s[14] <= s_in[08]; s[21] <= s_in[15]; s[28] <= s_in[22]; s[35] <= s_in[29];
		s[08] <= s_in[02]; s[15] <= s_in[09]; s[22] <= s_in[16]; s[29] <= s_in[23]; s[36] <= s_in[30];
		s[09] <= s_in[03]; s[16] <= s_in[10]; s[23] <= s_in[17]; s[30] <= s_in[24]; s[37] <= s_in[31];
		s[10] <= s_in[04]; s[17] <= s_in[11]; s[24] <= s_in[18]; s[31] <= s_in[25]; s[38] <= s_in[32];
		s[11] <= s_in[05]; s[18] <= s_in[12]; s[25] <= s_in[19]; s[32] <= s_in[26];
		s[12] <= s_in[06]; s[19] <= s_in[13]; s[26] <= s_in[20]; s[33] <= s_in[27];
		s[13] <= s_in[07]; s[20] <= s_in[14]; s[27] <= s_in[21]; s[34] <= s_in[28];
	end
	else begin
		s[00] <= s[00]; s[07] <= s[07]; s[14] <= s[14]; s[21] <= s[21]; s[28] <= s[28]; s[35] <= s[35]; s[42] <= s[42];
		s[01] <= s[01]; s[08] <= s[08]; s[15] <= s[15]; s[22] <= s[22]; s[29] <= s[29]; s[36] <= s[36]; s[43] <= s[43];
		s[02] <= s[02]; s[09] <= s[09]; s[16] <= s[16]; s[23] <= s[23]; s[30] <= s[30]; s[37] <= s[37]; s[44] <= s[44];
		s[03] <= s[03]; s[10] <= s[10]; s[17] <= s[17]; s[24] <= s[24]; s[31] <= s[31]; s[38] <= s[38]; s[45] <= s[45];
		s[04] <= s[04]; s[11] <= s[11]; s[18] <= s[18]; s[25] <= s[25]; s[32] <= s[32];	s[39] <= s[39];
		s[05] <= s[05]; s[12] <= s[12]; s[19] <= s[19]; s[26] <= s[26]; s[33] <= s[33]; s[40] <= s[40];
		s[06] <= s[06]; s[13] <= s[13]; s[20] <= s[20]; s[27] <= s[27]; s[34] <= s[34]; s[41] <= s[41];
	end
end
// p[7]
always@(posedge clk or negedge rst_n) begin
	// ^ = 94; $ = 36; . = 46; * = 42;
	if (!rst_n)
		p[7] <= 0;
	else if (ispattern == 1) begin
		if (chardata == 42)
			p[7] <= p[7];
		else if (star_flag2 == 1)
			p[7] <= p[7];
		else
			p[7] <= chardata;
	end
	else if (curr_state == OUTPUT)
		p[7] <= 0;
	else
		p[7] <= p[7];
end
// p[0] ~ p[6]
always@(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		p[0] <= 0;
		p[1] <= 0;
		p[2] <= 0;
		p[3] <= 0;
		p[4] <= 0;
		p[5] <= 0;
		p[6] <= 0;
	end
	else if (ispattern == 1) begin
		if (chardata == 42) begin
			p[6] <= p[6];
			p[5] <= p[5];
			p[4] <= p[4];
			p[3] <= p[3];
			p[2] <= p[2];
			p[1] <= p[1];
			p[0] <= p[0];
		end
		else if (star_flag2 == 1)begin
			p[6] <= p[6];
			p[5] <= p[5];
			p[4] <= p[4];
			p[3] <= p[3];
			p[2] <= p[2];
			p[1] <= p[1];
			p[0] <= p[0];
		end
		else begin
			p[6] <= p[7];
			p[5] <= p[6];
			p[4] <= p[5];
			p[3] <= p[4];
			p[2] <= p[3];
			p[1] <= p[2];
			p[0] <= p[1];
		end
	end
	else if (curr_state == OUTPUT) begin
		p[0] <= 0;
		p[1] <= 0;
		p[2] <= 0;
		p[3] <= 0;
		p[4] <= 0;
		p[5] <= 0;
		p[6] <= 0;
	end
	else begin
		p[0] <= p[0];
		p[1] <= p[1];
		p[2] <= p[2];
		p[3] <= p[3];
		p[4] <= p[4];
		p[5] <= p[5];
		p[6] <= p[6];
	end
end

// star_flag
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		star_flag <= 0;
	else if (ispattern)begin
		if (chardata == 42)
			star_flag <= 1;
		else
			star_flag <= 0;
	end
	else
		star_flag <= 0;
end
// star_flag2
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		star_flag2 <= 0;
	else if (ispattern)begin
		if (chardata == 42)
			star_flag2 <= 1;
		else
			star_flag2 <= star_flag2;
	end
	else if (curr_state == OUTPUT)
		star_flag2 <= 0;
	else
		star_flag2 <= star_flag2;
end
// star_position
// always@(posedge clk or negedge rst_n) begin
	// if (!rst_n)
		// star_position <= 0;
	// else if (star_flag == 1)
		// star_position <= count_pattern;
	// else if (curr_state == OUTPUT)
		// star_position <= 0;
	// else
		// star_position <= star_position;
// end
// count_p_after
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		count_p_after <= 0;
	else if (ispattern) begin
		if (star_flag2)
			count_p_after <= count_p_after + 1;
		else
			count_p_after <= count_p_after;
	end
	else if (curr_state == OUTPUT)
		count_p_after <= 0;
	else
		count_p_after <= count_p_after;
end
// p_after[7]
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		p_after[7] <= 0;
	else if (ispattern) begin
		if (star_flag2 == 1)
			p_after[7] <= chardata;
		else
			p_after[7] <= p_after[7];
	end
	else if (curr_state == OUTPUT)
		p_after[7] <= 0;
	else
		p_after[7] <= p_after[7];
end
// p_after[0] ~ p_after[6]
always@(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		p_after[0] <= 0;
		p_after[1] <= 0;
		p_after[2] <= 0;
		p_after[3] <= 0;
		p_after[4] <= 0;
		p_after[5] <= 0;
		p_after[6] <= 0;
	end
	else if (ispattern == 1) begin
		p_after[6] <= p_after[7];
		p_after[5] <= p_after[6];
		p_after[4] <= p_after[5];
		p_after[3] <= p_after[4];
		p_after[2] <= p_after[3];
		p_after[1] <= p_after[2];
		p_after[0] <= p_after[1];
	end
	else if (curr_state == OUTPUT) begin
		p_after[0] <= 0;
		p_after[1] <= 0;
		p_after[2] <= 0;
		p_after[3] <= 0;
		p_after[4] <= 0;
		p_after[5] <= 0;
		p_after[6] <= 0;
	end
	else begin
		p_after[0] <= p_after[0];
		p_after[1] <= p_after[1];
		p_after[2] <= p_after[2];
		p_after[3] <= p_after[3];
		p_after[4] <= p_after[4];
		p_after[5] <= p_after[5];
		p_after[6] <= p_after[6];
	end 
end

m_8bit_calcuate m_8bit_normal00(.s0(s[00]), .s1(s[01]), .s2(s[02]), .s3(s[03]), .s4(s[04]), .s5(s[05]), .s6(s[06]), .s7(s[07]), .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]), .p4(p[4]), .p5(p[5]), .p6(p[6]), .p7(p[7]), .count_pattern(count_pattern), .m38_1bit(m38[00]));
m_8bit_calcuate m_8bit_normal01(.s0(s[01]), .s1(s[02]), .s2(s[03]), .s3(s[04]), .s4(s[05]), .s5(s[06]), .s6(s[07]), .s7(s[08]), .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]), .p4(p[4]), .p5(p[5]), .p6(p[6]), .p7(p[7]), .count_pattern(count_pattern), .m38_1bit(m38[01]));
m_8bit_calcuate m_8bit_normal02(.s0(s[02]), .s1(s[03]), .s2(s[04]), .s3(s[05]), .s4(s[06]), .s5(s[07]), .s6(s[08]), .s7(s[09]), .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]), .p4(p[4]), .p5(p[5]), .p6(p[6]), .p7(p[7]), .count_pattern(count_pattern), .m38_1bit(m38[02]));
m_8bit_calcuate m_8bit_normal03(.s0(s[03]), .s1(s[04]), .s2(s[05]), .s3(s[06]), .s4(s[07]), .s5(s[08]), .s6(s[09]), .s7(s[10]), .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]), .p4(p[4]), .p5(p[5]), .p6(p[6]), .p7(p[7]), .count_pattern(count_pattern), .m38_1bit(m38[03]));
m_8bit_calcuate m_8bit_normal04(.s0(s[04]), .s1(s[05]), .s2(s[06]), .s3(s[07]), .s4(s[08]), .s5(s[09]), .s6(s[10]), .s7(s[11]), .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]), .p4(p[4]), .p5(p[5]), .p6(p[6]), .p7(p[7]), .count_pattern(count_pattern), .m38_1bit(m38[04]));
m_8bit_calcuate m_8bit_normal05(.s0(s[05]), .s1(s[06]), .s2(s[07]), .s3(s[08]), .s4(s[09]), .s5(s[10]), .s6(s[11]), .s7(s[12]), .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]), .p4(p[4]), .p5(p[5]), .p6(p[6]), .p7(p[7]), .count_pattern(count_pattern), .m38_1bit(m38[05]));
m_8bit_calcuate m_8bit_normal06(.s0(s[06]), .s1(s[07]), .s2(s[08]), .s3(s[09]), .s4(s[10]), .s5(s[11]), .s6(s[12]), .s7(s[13]), .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]), .p4(p[4]), .p5(p[5]), .p6(p[6]), .p7(p[7]), .count_pattern(count_pattern), .m38_1bit(m38[06]));
m_8bit_calcuate m_8bit_normal07(.s0(s[07]), .s1(s[08]), .s2(s[09]), .s3(s[10]), .s4(s[11]), .s5(s[12]), .s6(s[13]), .s7(s[14]), .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]), .p4(p[4]), .p5(p[5]), .p6(p[6]), .p7(p[7]), .count_pattern(count_pattern), .m38_1bit(m38[07]));
m_8bit_calcuate m_8bit_normal08(.s0(s[08]), .s1(s[09]), .s2(s[10]), .s3(s[11]), .s4(s[12]), .s5(s[13]), .s6(s[14]), .s7(s[15]), .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]), .p4(p[4]), .p5(p[5]), .p6(p[6]), .p7(p[7]), .count_pattern(count_pattern), .m38_1bit(m38[08]));
m_8bit_calcuate m_8bit_normal09(.s0(s[09]), .s1(s[10]), .s2(s[11]), .s3(s[12]), .s4(s[13]), .s5(s[14]), .s6(s[15]), .s7(s[16]), .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]), .p4(p[4]), .p5(p[5]), .p6(p[6]), .p7(p[7]), .count_pattern(count_pattern), .m38_1bit(m38[09]));
m_8bit_calcuate m_8bit_normal10(.s0(s[10]), .s1(s[11]), .s2(s[12]), .s3(s[13]), .s4(s[14]), .s5(s[15]), .s6(s[16]), .s7(s[17]), .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]), .p4(p[4]), .p5(p[5]), .p6(p[6]), .p7(p[7]), .count_pattern(count_pattern), .m38_1bit(m38[10]));
m_8bit_calcuate m_8bit_normal11(.s0(s[11]), .s1(s[12]), .s2(s[13]), .s3(s[14]), .s4(s[15]), .s5(s[16]), .s6(s[17]), .s7(s[18]), .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]), .p4(p[4]), .p5(p[5]), .p6(p[6]), .p7(p[7]), .count_pattern(count_pattern), .m38_1bit(m38[11]));
m_8bit_calcuate m_8bit_normal12(.s0(s[12]), .s1(s[13]), .s2(s[14]), .s3(s[15]), .s4(s[16]), .s5(s[17]), .s6(s[18]), .s7(s[19]), .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]), .p4(p[4]), .p5(p[5]), .p6(p[6]), .p7(p[7]), .count_pattern(count_pattern), .m38_1bit(m38[12]));
m_8bit_calcuate m_8bit_normal13(.s0(s[13]), .s1(s[14]), .s2(s[15]), .s3(s[16]), .s4(s[17]), .s5(s[18]), .s6(s[19]), .s7(s[20]), .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]), .p4(p[4]), .p5(p[5]), .p6(p[6]), .p7(p[7]), .count_pattern(count_pattern), .m38_1bit(m38[13]));
m_8bit_calcuate m_8bit_normal14(.s0(s[14]), .s1(s[15]), .s2(s[16]), .s3(s[17]), .s4(s[18]), .s5(s[19]), .s6(s[20]), .s7(s[21]), .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]), .p4(p[4]), .p5(p[5]), .p6(p[6]), .p7(p[7]), .count_pattern(count_pattern), .m38_1bit(m38[14]));
m_8bit_calcuate m_8bit_normal15(.s0(s[15]), .s1(s[16]), .s2(s[17]), .s3(s[18]), .s4(s[19]), .s5(s[20]), .s6(s[21]), .s7(s[22]), .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]), .p4(p[4]), .p5(p[5]), .p6(p[6]), .p7(p[7]), .count_pattern(count_pattern), .m38_1bit(m38[15]));
m_8bit_calcuate m_8bit_normal16(.s0(s[16]), .s1(s[17]), .s2(s[18]), .s3(s[19]), .s4(s[20]), .s5(s[21]), .s6(s[22]), .s7(s[23]), .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]), .p4(p[4]), .p5(p[5]), .p6(p[6]), .p7(p[7]), .count_pattern(count_pattern), .m38_1bit(m38[16]));
m_8bit_calcuate m_8bit_normal17(.s0(s[17]), .s1(s[18]), .s2(s[19]), .s3(s[20]), .s4(s[21]), .s5(s[22]), .s6(s[23]), .s7(s[24]), .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]), .p4(p[4]), .p5(p[5]), .p6(p[6]), .p7(p[7]), .count_pattern(count_pattern), .m38_1bit(m38[17]));
m_8bit_calcuate m_8bit_normal18(.s0(s[18]), .s1(s[19]), .s2(s[20]), .s3(s[21]), .s4(s[22]), .s5(s[23]), .s6(s[24]), .s7(s[25]), .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]), .p4(p[4]), .p5(p[5]), .p6(p[6]), .p7(p[7]), .count_pattern(count_pattern), .m38_1bit(m38[18]));
m_8bit_calcuate m_8bit_normal19(.s0(s[19]), .s1(s[20]), .s2(s[21]), .s3(s[22]), .s4(s[23]), .s5(s[24]), .s6(s[25]), .s7(s[26]), .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]), .p4(p[4]), .p5(p[5]), .p6(p[6]), .p7(p[7]), .count_pattern(count_pattern), .m38_1bit(m38[19]));
m_8bit_calcuate m_8bit_normal20(.s0(s[20]), .s1(s[21]), .s2(s[22]), .s3(s[23]), .s4(s[24]), .s5(s[25]), .s6(s[26]), .s7(s[27]), .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]), .p4(p[4]), .p5(p[5]), .p6(p[6]), .p7(p[7]), .count_pattern(count_pattern), .m38_1bit(m38[20]));
m_8bit_calcuate m_8bit_normal21(.s0(s[21]), .s1(s[22]), .s2(s[23]), .s3(s[24]), .s4(s[25]), .s5(s[26]), .s6(s[27]), .s7(s[28]), .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]), .p4(p[4]), .p5(p[5]), .p6(p[6]), .p7(p[7]), .count_pattern(count_pattern), .m38_1bit(m38[21]));
m_8bit_calcuate m_8bit_normal22(.s0(s[22]), .s1(s[23]), .s2(s[24]), .s3(s[25]), .s4(s[26]), .s5(s[27]), .s6(s[28]), .s7(s[29]), .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]), .p4(p[4]), .p5(p[5]), .p6(p[6]), .p7(p[7]), .count_pattern(count_pattern), .m38_1bit(m38[22]));
m_8bit_calcuate m_8bit_normal23(.s0(s[23]), .s1(s[24]), .s2(s[25]), .s3(s[26]), .s4(s[27]), .s5(s[28]), .s6(s[29]), .s7(s[30]), .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]), .p4(p[4]), .p5(p[5]), .p6(p[6]), .p7(p[7]), .count_pattern(count_pattern), .m38_1bit(m38[23]));
m_8bit_calcuate m_8bit_normal24(.s0(s[24]), .s1(s[25]), .s2(s[26]), .s3(s[27]), .s4(s[28]), .s5(s[29]), .s6(s[30]), .s7(s[31]), .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]), .p4(p[4]), .p5(p[5]), .p6(p[6]), .p7(p[7]), .count_pattern(count_pattern), .m38_1bit(m38[24]));
m_8bit_calcuate m_8bit_normal25(.s0(s[25]), .s1(s[26]), .s2(s[27]), .s3(s[28]), .s4(s[29]), .s5(s[30]), .s6(s[31]), .s7(s[32]), .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]), .p4(p[4]), .p5(p[5]), .p6(p[6]), .p7(p[7]), .count_pattern(count_pattern), .m38_1bit(m38[25]));
m_8bit_calcuate m_8bit_normal26(.s0(s[26]), .s1(s[27]), .s2(s[28]), .s3(s[29]), .s4(s[30]), .s5(s[31]), .s6(s[32]), .s7(s[33]), .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]), .p4(p[4]), .p5(p[5]), .p6(p[6]), .p7(p[7]), .count_pattern(count_pattern), .m38_1bit(m38[26]));
m_8bit_calcuate m_8bit_normal27(.s0(s[27]), .s1(s[28]), .s2(s[29]), .s3(s[30]), .s4(s[31]), .s5(s[32]), .s6(s[33]), .s7(s[34]), .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]), .p4(p[4]), .p5(p[5]), .p6(p[6]), .p7(p[7]), .count_pattern(count_pattern), .m38_1bit(m38[27]));
m_8bit_calcuate m_8bit_normal28(.s0(s[28]), .s1(s[29]), .s2(s[30]), .s3(s[31]), .s4(s[32]), .s5(s[33]), .s6(s[34]), .s7(s[35]), .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]), .p4(p[4]), .p5(p[5]), .p6(p[6]), .p7(p[7]), .count_pattern(count_pattern), .m38_1bit(m38[28]));
m_8bit_calcuate m_8bit_normal29(.s0(s[29]), .s1(s[30]), .s2(s[31]), .s3(s[32]), .s4(s[33]), .s5(s[34]), .s6(s[35]), .s7(s[36]), .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]), .p4(p[4]), .p5(p[5]), .p6(p[6]), .p7(p[7]), .count_pattern(count_pattern), .m38_1bit(m38[29]));
m_8bit_calcuate m_8bit_normal30(.s0(s[30]), .s1(s[31]), .s2(s[32]), .s3(s[33]), .s4(s[34]), .s5(s[35]), .s6(s[36]), .s7(s[37]), .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]), .p4(p[4]), .p5(p[5]), .p6(p[6]), .p7(p[7]), .count_pattern(count_pattern), .m38_1bit(m38[30]));
m_8bit_calcuate m_8bit_normal31(.s0(s[31]), .s1(s[32]), .s2(s[33]), .s3(s[34]), .s4(s[35]), .s5(s[36]), .s6(s[37]), .s7(s[38]), .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]), .p4(p[4]), .p5(p[5]), .p6(p[6]), .p7(p[7]), .count_pattern(count_pattern), .m38_1bit(m38[31]));
m_8bit_calcuate m_8bit_normal32(.s0(s[32]), .s1(s[33]), .s2(s[34]), .s3(s[35]), .s4(s[36]), .s5(s[37]), .s6(s[38]), .s7(s[39]), .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]), .p4(p[4]), .p5(p[5]), .p6(p[6]), .p7(p[7]), .count_pattern(count_pattern), .m38_1bit(m38[32]));
m_8bit_calcuate m_8bit_normal33(.s0(s[33]), .s1(s[34]), .s2(s[35]), .s3(s[36]), .s4(s[37]), .s5(s[38]), .s6(s[39]), .s7(s[40]), .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]), .p4(p[4]), .p5(p[5]), .p6(p[6]), .p7(p[7]), .count_pattern(count_pattern), .m38_1bit(m38[33]));
m_8bit_calcuate m_8bit_normal34(.s0(s[34]), .s1(s[35]), .s2(s[36]), .s3(s[37]), .s4(s[38]), .s5(s[39]), .s6(s[40]), .s7(s[41]), .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]), .p4(p[4]), .p5(p[5]), .p6(p[6]), .p7(p[7]), .count_pattern(count_pattern), .m38_1bit(m38[34]));
m_8bit_calcuate m_8bit_normal35(.s0(s[35]), .s1(s[36]), .s2(s[37]), .s3(s[38]), .s4(s[39]), .s5(s[40]), .s6(s[41]), .s7(s[42]), .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]), .p4(p[4]), .p5(p[5]), .p6(p[6]), .p7(p[7]), .count_pattern(count_pattern), .m38_1bit(m38[35]));
m_8bit_calcuate m_8bit_normal36(.s0(s[36]), .s1(s[37]), .s2(s[38]), .s3(s[39]), .s4(s[40]), .s5(s[41]), .s6(s[42]), .s7(s[43]), .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]), .p4(p[4]), .p5(p[5]), .p6(p[6]), .p7(p[7]), .count_pattern(count_pattern), .m38_1bit(m38[36]));
m_8bit_calcuate m_8bit_normal37(.s0(s[37]), .s1(s[38]), .s2(s[39]), .s3(s[30]), .s4(s[41]), .s5(s[42]), .s6(s[43]), .s7(s[44]), .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]), .p4(p[4]), .p5(p[5]), .p6(p[6]), .p7(p[7]), .count_pattern(count_pattern), .m38_1bit(m38[37]));
m_8bit_calcuate m_8bit_normal38(.s0(s[38]), .s1(s[39]), .s2(s[30]), .s3(s[41]), .s4(s[42]), .s5(s[43]), .s6(s[44]), .s7(s[45]), .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]), .p4(p[4]), .p5(p[5]), .p6(p[6]), .p7(p[7]), .count_pattern(count_pattern), .m38_1bit(m38[38]));
assign sum_m38 = m38[0] +  m38[1] +  m38[2] +  m38[3] +  m38[4] +  m38[5] +  m38[6] +  m38[7]
			  +  m38[8] +  m38[9] + m38[10] + m38[11] + m38[12] + m38[13] + m38[14] + m38[15]
			  + m38[16] + m38[17] + m38[18] + m38[19] + m38[20] + m38[21] + m38[22] + m38[23]
			  + m38[24] + m38[25] + m38[26] + m38[27] + m38[28] + m38[29] + m38[30] + m38[31]
			  + m38[32] + m38[33] + m38[34] + m38[35] + m38[36] + m38[37] + m38[38];
find_ones_LSB find_ones(.x(m38), .y(y_out));
// p_start
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)                  p_start <= 0;
	else if (shift_pattern == 0) p_start <= p[0];
	else if (shift_pattern == 1) p_start <= p[1];
	else if (shift_pattern == 2) p_start <= p[2];
	else if (shift_pattern == 3) p_start <= p[3];
	else if (shift_pattern == 4) p_start <= p[4];
	else if (shift_pattern == 5) p_start <= p[5];
	else if (shift_pattern == 6) p_start <= p[6];
	else if (shift_pattern == 7) p_start <= p[7];
	else                         p_start <= p_start;
end
// index_value
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		index_value <= 0;
	else if (count_pattern == 0)
		index_value <= 0;
	// else if (curr_state == CALCUATE) begin
		// if (p_start == 94)
			// index_value <= y_out - shift_string + shift_pattern - 6;
		// else
			// index_value <= y_out - 1 - shift_string + shift_pattern  - 6;
	// end
	// else if (curr_state == OUTPUT)
		// index_value <= 0;
	// else
		// index_value <= index_value;
	else if (p_start == 94)
		index_value <= y_out - shift_string + shift_pattern - 6;
	else
		index_value <= y_out - 1 - shift_string + shift_pattern  - 6;
end
// wire [5:0] index_value;
// assign index_value = (count_pattern == 0) ? 0 : (p_start == 94) ? y_out - shift_string + shift_pattern  - 6 : y_out - 1 - shift_string + shift_pattern  - 6;


m_8bit_calcuate m_8bit_after00(.s0(s[00]), .s1(s[01]), .s2(s[02]), .s3(s[03]), .s4(s[04]), .s5(s[05]), .s6(s[06]), .s7(s[07]), .p0(p_after[0]), .p1(p_after[1]), .p2(p_after[2]), .p3(p_after[3]), .p4(p_after[4]), .p5(p_after[5]), .p6(p_after[6]), .p7(p_after[7]), .count_pattern(count_p_after), .m38_1bit(m38_after[00]));
m_8bit_calcuate m_8bit_after01(.s0(s[01]), .s1(s[02]), .s2(s[03]), .s3(s[04]), .s4(s[05]), .s5(s[06]), .s6(s[07]), .s7(s[08]), .p0(p_after[0]), .p1(p_after[1]), .p2(p_after[2]), .p3(p_after[3]), .p4(p_after[4]), .p5(p_after[5]), .p6(p_after[6]), .p7(p_after[7]), .count_pattern(count_p_after), .m38_1bit(m38_after[01]));
m_8bit_calcuate m_8bit_after02(.s0(s[02]), .s1(s[03]), .s2(s[04]), .s3(s[05]), .s4(s[06]), .s5(s[07]), .s6(s[08]), .s7(s[09]), .p0(p_after[0]), .p1(p_after[1]), .p2(p_after[2]), .p3(p_after[3]), .p4(p_after[4]), .p5(p_after[5]), .p6(p_after[6]), .p7(p_after[7]), .count_pattern(count_p_after), .m38_1bit(m38_after[02]));
m_8bit_calcuate m_8bit_after03(.s0(s[03]), .s1(s[04]), .s2(s[05]), .s3(s[06]), .s4(s[07]), .s5(s[08]), .s6(s[09]), .s7(s[10]), .p0(p_after[0]), .p1(p_after[1]), .p2(p_after[2]), .p3(p_after[3]), .p4(p_after[4]), .p5(p_after[5]), .p6(p_after[6]), .p7(p_after[7]), .count_pattern(count_p_after), .m38_1bit(m38_after[03]));
m_8bit_calcuate m_8bit_after04(.s0(s[04]), .s1(s[05]), .s2(s[06]), .s3(s[07]), .s4(s[08]), .s5(s[09]), .s6(s[10]), .s7(s[11]), .p0(p_after[0]), .p1(p_after[1]), .p2(p_after[2]), .p3(p_after[3]), .p4(p_after[4]), .p5(p_after[5]), .p6(p_after[6]), .p7(p_after[7]), .count_pattern(count_p_after), .m38_1bit(m38_after[04]));
m_8bit_calcuate m_8bit_after05(.s0(s[05]), .s1(s[06]), .s2(s[07]), .s3(s[08]), .s4(s[09]), .s5(s[10]), .s6(s[11]), .s7(s[12]), .p0(p_after[0]), .p1(p_after[1]), .p2(p_after[2]), .p3(p_after[3]), .p4(p_after[4]), .p5(p_after[5]), .p6(p_after[6]), .p7(p_after[7]), .count_pattern(count_p_after), .m38_1bit(m38_after[05]));
m_8bit_calcuate m_8bit_after06(.s0(s[06]), .s1(s[07]), .s2(s[08]), .s3(s[09]), .s4(s[10]), .s5(s[11]), .s6(s[12]), .s7(s[13]), .p0(p_after[0]), .p1(p_after[1]), .p2(p_after[2]), .p3(p_after[3]), .p4(p_after[4]), .p5(p_after[5]), .p6(p_after[6]), .p7(p_after[7]), .count_pattern(count_p_after), .m38_1bit(m38_after[06]));
m_8bit_calcuate m_8bit_after07(.s0(s[07]), .s1(s[08]), .s2(s[09]), .s3(s[10]), .s4(s[11]), .s5(s[12]), .s6(s[13]), .s7(s[14]), .p0(p_after[0]), .p1(p_after[1]), .p2(p_after[2]), .p3(p_after[3]), .p4(p_after[4]), .p5(p_after[5]), .p6(p_after[6]), .p7(p_after[7]), .count_pattern(count_p_after), .m38_1bit(m38_after[07]));
m_8bit_calcuate m_8bit_after08(.s0(s[08]), .s1(s[09]), .s2(s[10]), .s3(s[11]), .s4(s[12]), .s5(s[13]), .s6(s[14]), .s7(s[15]), .p0(p_after[0]), .p1(p_after[1]), .p2(p_after[2]), .p3(p_after[3]), .p4(p_after[4]), .p5(p_after[5]), .p6(p_after[6]), .p7(p_after[7]), .count_pattern(count_p_after), .m38_1bit(m38_after[08]));
m_8bit_calcuate m_8bit_after09(.s0(s[09]), .s1(s[10]), .s2(s[11]), .s3(s[12]), .s4(s[13]), .s5(s[14]), .s6(s[15]), .s7(s[16]), .p0(p_after[0]), .p1(p_after[1]), .p2(p_after[2]), .p3(p_after[3]), .p4(p_after[4]), .p5(p_after[5]), .p6(p_after[6]), .p7(p_after[7]), .count_pattern(count_p_after), .m38_1bit(m38_after[09]));
m_8bit_calcuate m_8bit_after10(.s0(s[10]), .s1(s[11]), .s2(s[12]), .s3(s[13]), .s4(s[14]), .s5(s[15]), .s6(s[16]), .s7(s[17]), .p0(p_after[0]), .p1(p_after[1]), .p2(p_after[2]), .p3(p_after[3]), .p4(p_after[4]), .p5(p_after[5]), .p6(p_after[6]), .p7(p_after[7]), .count_pattern(count_p_after), .m38_1bit(m38_after[10]));
m_8bit_calcuate m_8bit_after11(.s0(s[11]), .s1(s[12]), .s2(s[13]), .s3(s[14]), .s4(s[15]), .s5(s[16]), .s6(s[17]), .s7(s[18]), .p0(p_after[0]), .p1(p_after[1]), .p2(p_after[2]), .p3(p_after[3]), .p4(p_after[4]), .p5(p_after[5]), .p6(p_after[6]), .p7(p_after[7]), .count_pattern(count_p_after), .m38_1bit(m38_after[11]));
m_8bit_calcuate m_8bit_after12(.s0(s[12]), .s1(s[13]), .s2(s[14]), .s3(s[15]), .s4(s[16]), .s5(s[17]), .s6(s[18]), .s7(s[19]), .p0(p_after[0]), .p1(p_after[1]), .p2(p_after[2]), .p3(p_after[3]), .p4(p_after[4]), .p5(p_after[5]), .p6(p_after[6]), .p7(p_after[7]), .count_pattern(count_p_after), .m38_1bit(m38_after[12]));
m_8bit_calcuate m_8bit_after13(.s0(s[13]), .s1(s[14]), .s2(s[15]), .s3(s[16]), .s4(s[17]), .s5(s[18]), .s6(s[19]), .s7(s[20]), .p0(p_after[0]), .p1(p_after[1]), .p2(p_after[2]), .p3(p_after[3]), .p4(p_after[4]), .p5(p_after[5]), .p6(p_after[6]), .p7(p_after[7]), .count_pattern(count_p_after), .m38_1bit(m38_after[13]));
m_8bit_calcuate m_8bit_after14(.s0(s[14]), .s1(s[15]), .s2(s[16]), .s3(s[17]), .s4(s[18]), .s5(s[19]), .s6(s[20]), .s7(s[21]), .p0(p_after[0]), .p1(p_after[1]), .p2(p_after[2]), .p3(p_after[3]), .p4(p_after[4]), .p5(p_after[5]), .p6(p_after[6]), .p7(p_after[7]), .count_pattern(count_p_after), .m38_1bit(m38_after[14]));
m_8bit_calcuate m_8bit_after15(.s0(s[15]), .s1(s[16]), .s2(s[17]), .s3(s[18]), .s4(s[19]), .s5(s[20]), .s6(s[21]), .s7(s[22]), .p0(p_after[0]), .p1(p_after[1]), .p2(p_after[2]), .p3(p_after[3]), .p4(p_after[4]), .p5(p_after[5]), .p6(p_after[6]), .p7(p_after[7]), .count_pattern(count_p_after), .m38_1bit(m38_after[15]));
m_8bit_calcuate m_8bit_after16(.s0(s[16]), .s1(s[17]), .s2(s[18]), .s3(s[19]), .s4(s[20]), .s5(s[21]), .s6(s[22]), .s7(s[23]), .p0(p_after[0]), .p1(p_after[1]), .p2(p_after[2]), .p3(p_after[3]), .p4(p_after[4]), .p5(p_after[5]), .p6(p_after[6]), .p7(p_after[7]), .count_pattern(count_p_after), .m38_1bit(m38_after[16]));
m_8bit_calcuate m_8bit_after17(.s0(s[17]), .s1(s[18]), .s2(s[19]), .s3(s[20]), .s4(s[21]), .s5(s[22]), .s6(s[23]), .s7(s[24]), .p0(p_after[0]), .p1(p_after[1]), .p2(p_after[2]), .p3(p_after[3]), .p4(p_after[4]), .p5(p_after[5]), .p6(p_after[6]), .p7(p_after[7]), .count_pattern(count_p_after), .m38_1bit(m38_after[17]));
m_8bit_calcuate m_8bit_after18(.s0(s[18]), .s1(s[19]), .s2(s[20]), .s3(s[21]), .s4(s[22]), .s5(s[23]), .s6(s[24]), .s7(s[25]), .p0(p_after[0]), .p1(p_after[1]), .p2(p_after[2]), .p3(p_after[3]), .p4(p_after[4]), .p5(p_after[5]), .p6(p_after[6]), .p7(p_after[7]), .count_pattern(count_p_after), .m38_1bit(m38_after[18]));
m_8bit_calcuate m_8bit_after19(.s0(s[19]), .s1(s[20]), .s2(s[21]), .s3(s[22]), .s4(s[23]), .s5(s[24]), .s6(s[25]), .s7(s[26]), .p0(p_after[0]), .p1(p_after[1]), .p2(p_after[2]), .p3(p_after[3]), .p4(p_after[4]), .p5(p_after[5]), .p6(p_after[6]), .p7(p_after[7]), .count_pattern(count_p_after), .m38_1bit(m38_after[19]));
m_8bit_calcuate m_8bit_after20(.s0(s[20]), .s1(s[21]), .s2(s[22]), .s3(s[23]), .s4(s[24]), .s5(s[25]), .s6(s[26]), .s7(s[27]), .p0(p_after[0]), .p1(p_after[1]), .p2(p_after[2]), .p3(p_after[3]), .p4(p_after[4]), .p5(p_after[5]), .p6(p_after[6]), .p7(p_after[7]), .count_pattern(count_p_after), .m38_1bit(m38_after[20]));
m_8bit_calcuate m_8bit_after21(.s0(s[21]), .s1(s[22]), .s2(s[23]), .s3(s[24]), .s4(s[25]), .s5(s[26]), .s6(s[27]), .s7(s[28]), .p0(p_after[0]), .p1(p_after[1]), .p2(p_after[2]), .p3(p_after[3]), .p4(p_after[4]), .p5(p_after[5]), .p6(p_after[6]), .p7(p_after[7]), .count_pattern(count_p_after), .m38_1bit(m38_after[21]));
m_8bit_calcuate m_8bit_after22(.s0(s[22]), .s1(s[23]), .s2(s[24]), .s3(s[25]), .s4(s[26]), .s5(s[27]), .s6(s[28]), .s7(s[29]), .p0(p_after[0]), .p1(p_after[1]), .p2(p_after[2]), .p3(p_after[3]), .p4(p_after[4]), .p5(p_after[5]), .p6(p_after[6]), .p7(p_after[7]), .count_pattern(count_p_after), .m38_1bit(m38_after[22]));
m_8bit_calcuate m_8bit_after23(.s0(s[23]), .s1(s[24]), .s2(s[25]), .s3(s[26]), .s4(s[27]), .s5(s[28]), .s6(s[29]), .s7(s[30]), .p0(p_after[0]), .p1(p_after[1]), .p2(p_after[2]), .p3(p_after[3]), .p4(p_after[4]), .p5(p_after[5]), .p6(p_after[6]), .p7(p_after[7]), .count_pattern(count_p_after), .m38_1bit(m38_after[23]));
m_8bit_calcuate m_8bit_after24(.s0(s[24]), .s1(s[25]), .s2(s[26]), .s3(s[27]), .s4(s[28]), .s5(s[29]), .s6(s[30]), .s7(s[31]), .p0(p_after[0]), .p1(p_after[1]), .p2(p_after[2]), .p3(p_after[3]), .p4(p_after[4]), .p5(p_after[5]), .p6(p_after[6]), .p7(p_after[7]), .count_pattern(count_p_after), .m38_1bit(m38_after[24]));
m_8bit_calcuate m_8bit_after25(.s0(s[25]), .s1(s[26]), .s2(s[27]), .s3(s[28]), .s4(s[29]), .s5(s[30]), .s6(s[31]), .s7(s[32]), .p0(p_after[0]), .p1(p_after[1]), .p2(p_after[2]), .p3(p_after[3]), .p4(p_after[4]), .p5(p_after[5]), .p6(p_after[6]), .p7(p_after[7]), .count_pattern(count_p_after), .m38_1bit(m38_after[25]));
m_8bit_calcuate m_8bit_after26(.s0(s[26]), .s1(s[27]), .s2(s[28]), .s3(s[29]), .s4(s[30]), .s5(s[31]), .s6(s[32]), .s7(s[33]), .p0(p_after[0]), .p1(p_after[1]), .p2(p_after[2]), .p3(p_after[3]), .p4(p_after[4]), .p5(p_after[5]), .p6(p_after[6]), .p7(p_after[7]), .count_pattern(count_p_after), .m38_1bit(m38_after[26]));
m_8bit_calcuate m_8bit_after27(.s0(s[27]), .s1(s[28]), .s2(s[29]), .s3(s[30]), .s4(s[31]), .s5(s[32]), .s6(s[33]), .s7(s[34]), .p0(p_after[0]), .p1(p_after[1]), .p2(p_after[2]), .p3(p_after[3]), .p4(p_after[4]), .p5(p_after[5]), .p6(p_after[6]), .p7(p_after[7]), .count_pattern(count_p_after), .m38_1bit(m38_after[27]));
m_8bit_calcuate m_8bit_after28(.s0(s[28]), .s1(s[29]), .s2(s[30]), .s3(s[31]), .s4(s[32]), .s5(s[33]), .s6(s[34]), .s7(s[35]), .p0(p_after[0]), .p1(p_after[1]), .p2(p_after[2]), .p3(p_after[3]), .p4(p_after[4]), .p5(p_after[5]), .p6(p_after[6]), .p7(p_after[7]), .count_pattern(count_p_after), .m38_1bit(m38_after[28]));
m_8bit_calcuate m_8bit_after29(.s0(s[29]), .s1(s[30]), .s2(s[31]), .s3(s[32]), .s4(s[33]), .s5(s[34]), .s6(s[35]), .s7(s[36]), .p0(p_after[0]), .p1(p_after[1]), .p2(p_after[2]), .p3(p_after[3]), .p4(p_after[4]), .p5(p_after[5]), .p6(p_after[6]), .p7(p_after[7]), .count_pattern(count_p_after), .m38_1bit(m38_after[29]));
m_8bit_calcuate m_8bit_after30(.s0(s[30]), .s1(s[31]), .s2(s[32]), .s3(s[33]), .s4(s[34]), .s5(s[35]), .s6(s[36]), .s7(s[37]), .p0(p_after[0]), .p1(p_after[1]), .p2(p_after[2]), .p3(p_after[3]), .p4(p_after[4]), .p5(p_after[5]), .p6(p_after[6]), .p7(p_after[7]), .count_pattern(count_p_after), .m38_1bit(m38_after[30]));
m_8bit_calcuate m_8bit_after31(.s0(s[31]), .s1(s[32]), .s2(s[33]), .s3(s[34]), .s4(s[35]), .s5(s[36]), .s6(s[37]), .s7(s[38]), .p0(p_after[0]), .p1(p_after[1]), .p2(p_after[2]), .p3(p_after[3]), .p4(p_after[4]), .p5(p_after[5]), .p6(p_after[6]), .p7(p_after[7]), .count_pattern(count_p_after), .m38_1bit(m38_after[31]));
m_8bit_calcuate m_8bit_after32(.s0(s[32]), .s1(s[33]), .s2(s[34]), .s3(s[35]), .s4(s[36]), .s5(s[37]), .s6(s[38]), .s7(s[39]), .p0(p_after[0]), .p1(p_after[1]), .p2(p_after[2]), .p3(p_after[3]), .p4(p_after[4]), .p5(p_after[5]), .p6(p_after[6]), .p7(p_after[7]), .count_pattern(count_p_after), .m38_1bit(m38_after[32]));
m_8bit_calcuate m_8bit_after33(.s0(s[33]), .s1(s[34]), .s2(s[35]), .s3(s[36]), .s4(s[37]), .s5(s[38]), .s6(s[39]), .s7(s[40]), .p0(p_after[0]), .p1(p_after[1]), .p2(p_after[2]), .p3(p_after[3]), .p4(p_after[4]), .p5(p_after[5]), .p6(p_after[6]), .p7(p_after[7]), .count_pattern(count_p_after), .m38_1bit(m38_after[33]));
m_8bit_calcuate m_8bit_after34(.s0(s[34]), .s1(s[35]), .s2(s[36]), .s3(s[37]), .s4(s[38]), .s5(s[39]), .s6(s[40]), .s7(s[41]), .p0(p_after[0]), .p1(p_after[1]), .p2(p_after[2]), .p3(p_after[3]), .p4(p_after[4]), .p5(p_after[5]), .p6(p_after[6]), .p7(p_after[7]), .count_pattern(count_p_after), .m38_1bit(m38_after[34]));
m_8bit_calcuate m_8bit_after35(.s0(s[35]), .s1(s[36]), .s2(s[37]), .s3(s[38]), .s4(s[39]), .s5(s[40]), .s6(s[41]), .s7(s[42]), .p0(p_after[0]), .p1(p_after[1]), .p2(p_after[2]), .p3(p_after[3]), .p4(p_after[4]), .p5(p_after[5]), .p6(p_after[6]), .p7(p_after[7]), .count_pattern(count_p_after), .m38_1bit(m38_after[35]));
m_8bit_calcuate m_8bit_after36(.s0(s[36]), .s1(s[37]), .s2(s[38]), .s3(s[39]), .s4(s[40]), .s5(s[41]), .s6(s[42]), .s7(s[43]), .p0(p_after[0]), .p1(p_after[1]), .p2(p_after[2]), .p3(p_after[3]), .p4(p_after[4]), .p5(p_after[5]), .p6(p_after[6]), .p7(p_after[7]), .count_pattern(count_p_after), .m38_1bit(m38_after[36]));
m_8bit_calcuate m_8bit_after37(.s0(s[37]), .s1(s[38]), .s2(s[39]), .s3(s[30]), .s4(s[41]), .s5(s[42]), .s6(s[43]), .s7(s[44]), .p0(p_after[0]), .p1(p_after[1]), .p2(p_after[2]), .p3(p_after[3]), .p4(p_after[4]), .p5(p_after[5]), .p6(p_after[6]), .p7(p_after[7]), .count_pattern(count_p_after), .m38_1bit(m38_after[37]));
m_8bit_calcuate m_8bit_after38(.s0(s[38]), .s1(s[39]), .s2(s[30]), .s3(s[41]), .s4(s[42]), .s5(s[43]), .s6(s[44]), .s7(s[45]), .p0(p_after[0]), .p1(p_after[1]), .p2(p_after[2]), .p3(p_after[3]), .p4(p_after[4]), .p5(p_after[5]), .p6(p_after[6]), .p7(p_after[7]), .count_pattern(count_p_after), .m38_1bit(m38_after[38]));
assign sum_m38_after = m38_after[0] +  m38_after[1] +  m38_after[2] +  m38_after[3] +  m38_after[4] +  m38_after[5] +  m38_after[6] +  m38_after[7]
					+  m38_after[8] +  m38_after[9] + m38_after[10] + m38_after[11] + m38_after[12] + m38_after[13] + m38_after[14] + m38_after[15]
					+ m38_after[16] + m38_after[17] + m38_after[18] + m38_after[19] + m38_after[20] + m38_after[21] + m38_after[22] + m38_after[23]
					+ m38_after[24] + m38_after[25] + m38_after[26] + m38_after[27] + m38_after[28] + m38_after[29] + m38_after[30] + m38_after[31]
					+ m38_after[32] + m38_after[33] + m38_after[34] + m38_after[35] + m38_after[36] + m38_after[37] + m38_after[38];
find_ones_HSB find_ones_after(.x(m38_after), .y(y_after));
// p_after_start
// always@(posedge clk or negedge rst_n) begin
	// if (!rst_n)                        p_after_start <= 0;
	// else if (shift_pattern_after == 0) p_after_start <= p_after[0];
	// else if (shift_pattern_after == 1) p_after_start <= p_after[1];
	// else if (shift_pattern_after == 2) p_after_start <= p_after[2];
	// else if (shift_pattern_after == 3) p_after_start <= p_after[3];
	// else if (shift_pattern_after == 4) p_after_start <= p_after[4];
	// else if (shift_pattern_after == 5) p_after_start <= p_after[5];
	// else if (shift_pattern_after == 6) p_after_start <= p_after[6];
	// else if (shift_pattern_after == 7) p_after_start <= p_after[7];
	// else                               p_after_start <= p_after_start;
// end
// index_value_after
// always@(posedge clk or negedge rst_n) begin
	// if (!rst_n)
		// index_value_after <= 0;
	// else if (count_p_after == 0)
		// index_value_after <= 31;
	// else if (curr_state == CALCUATE) begin
		// if (p_after_start == 94)
			// index_value_after <= y_after - shift_string + shift_pattern_after - 6;
		// else
			// index_value_after <= y_after - 1 - shift_string + shift_pattern_after - 6;
	// end
	// else if (curr_state == OUTPUT)
		// index_value_after <= 0;
	// else
		// index_value_after <= index_value_after;
// end
// wire [5:0] index_value_after;
// assign index_value_after = (count_p_after == 0) ? 31 : (p_after_start == 94) ? y_after - shift_string + shift_pattern_after - 6 : y_after - 1 - shift_string + shift_pattern_after - 6;


// out_valid
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		out_valid <= 0;
	else if (curr_state == OUTPUT)
		out_valid <= 1;
	else
		out_valid <= 0;
end
// wire [4:0] index_value_end;
// assign index_value_end = (p_start == 94) ? index_value - 1 + count_pattern - 1 : index_value + count_pattern - 1;
// reg [4:0] index_value_end;
// index_value_end
// always@(posedge clk or negedge rst_n) begin
	// if (!rst_n)
		// index_value_end <= 0;
	// else if (p_start == 94)
		// index_value_end <= index_value - 1 + count_pattern - 1;
	// else
		// index_value_end <= index_value + count_pattern - 1;
// end
// wire [5:0] y_out_end;
// assign y_out_end = (count_pattern == 0) ? 0 : y_out + count_pattern - 1;
reg [5:0] y_out_end;
// y_out_end
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		y_out_end <= 0;
	else if (count_pattern == 0)
		y_out_end <= 0;
	else
		y_out_end <= y_out + shift_pattern + count_pattern - 1;
end
reg [5:0] y_after_start;
// y_after_start
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		y_after_start <= 0;
	else if (count_p_after == 0)
		y_after_start <= 38;
	else
		y_after_start <= y_after + shift_pattern_after;
end

assign y_out_end_54 = y_out_end[5] && y_out_end[4];

// match
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		match <= 0;
	else if (curr_state == OUTPUT) begin
		if (star_flag2) begin
			if ((sum_m38 >= 1) && (sum_m38_after >= 1) && (y_after_start > y_out_end))
				match <= 1;
			else
				match <= 0;
		end
		else begin
			if (sum_m38 >= 1)
				match <= 1;
			else
				match <= 0;
		end
	end
	else
		match <= 0;
end
// match_index
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		match_index <= 0;
	else if (curr_state == OUTPUT) begin
		if (star_flag2) begin
			if ((sum_m38 >= 1) && (sum_m38_after >= 1) && (y_after_start > y_out_end))
				match_index <= index_value;
			else
				match_index <= 0;
		end
		else begin
			if (sum_m38 >= 1)
				match_index <= index_value;
			else
				match_index <= 0;
		end
	end
	else
		match_index <= 0;
end

// curr_state
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		curr_state <= IDLE;
	else
		curr_state <= next_state;
end
// next_state
always @(*) begin
	if (!rst_n) next_state = IDLE;
	else begin
		case (curr_state)
		IDLE: begin				// 0
			if (isstring)
				next_state = STRING;
			else if (ispattern)
				next_state = PATTERN;
			else
				next_state = IDLE;
		end
		STRING: begin			// 1
			if (isstring == 0)
				next_state = STRING_SHIFT;
			else
				next_state = STRING;
		end
		STRING_SHIFT: begin		// 2
			if (ispattern == 1)
				next_state = PATTERN;
			else
				next_state = IDLE;
		end
		PATTERN: begin			// 3
			if (ispattern == 0)
				next_state = CALCUATE;
			else
				next_state = PATTERN;
		end
		CALCUATE: begin			// 4
			next_state = OUTPUT;
		end
		CALCUATE2: begin		// 5
			next_state = OUTPUT;
		end
		OUTPUT: begin			// 7
			next_state = IDLE;
		end
		default: next_state = IDLE;
		endcase
	end
end

endmodule


module find_ones_HSB(
input [38:0] x,
output [5:0] y);

wire [63:0] data_64;
wire [31:0] data_32;
wire [15:0] data_16;
wire [7:0] data_8;
wire [3:0] data_4;
wire [1:0] data_2;

assign data_64= {25'b0,x[38:0]};
assign y[5] = | data_64[33:32];
assign data_32= y[5] ? data_64[33:32] : data_64[31:0];
assign y[4] = | data_32[31:16];
assign data_16= y[4] ? data_32[31:16] : data_32[15:0];
assign y[3] = | data_16[15:8];
assign data_8 = y[3] ? data_16[15:8] : data_16[7:0];
assign y[2] = | data_8[7:4];
assign data_4 = y[2] ? data_8[7:4] : data_8[3:0];
assign y[1] = | data_4[3:2];
assign data_2 = y[1] ? data_4[3:2] : data_4[1:0];
assign y[0] = data_2[1];

endmodule


module find_ones_LSB(
input [38:0] x,
output [5:0] y);

wire [63:0] data_64;
wire [31:0] data_32;
wire [15:0] data_16;
wire [7:0] data_8;
wire [3:0] data_4;
wire [1:0] data_2;

assign data_64= {25'b0,x[38:0]};
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


module m_8bit_calcuate(
input [7:0] s0, s1, s2, s3, s4, s5, s6, s7,
input [7:0] p0, p1, p2, p3, p4, p5, p6, p7,
input [3:0] count_pattern,
output m38_1bit);

wire [7:0] m8;
wire [3:0] sum_m8;
m_1bit_calcuate m_1bit_calcuate0(.s_1bit(s0), .p_1bit(p0), .m8_1bit(m8[0]));
m_1bit_calcuate m_1bit_calcuate1(.s_1bit(s1), .p_1bit(p1), .m8_1bit(m8[1]));
m_1bit_calcuate m_1bit_calcuate2(.s_1bit(s2), .p_1bit(p2), .m8_1bit(m8[2]));
m_1bit_calcuate m_1bit_calcuate3(.s_1bit(s3), .p_1bit(p3), .m8_1bit(m8[3]));
m_1bit_calcuate m_1bit_calcuate4(.s_1bit(s4), .p_1bit(p4), .m8_1bit(m8[4]));
m_1bit_calcuate m_1bit_calcuate5(.s_1bit(s5), .p_1bit(p5), .m8_1bit(m8[5]));
m_1bit_calcuate m_1bit_calcuate6(.s_1bit(s6), .p_1bit(p6), .m8_1bit(m8[6]));
m_1bit_calcuate m_1bit_calcuate7(.s_1bit(s7), .p_1bit(p7), .m8_1bit(m8[7]));
assign sum_m8 = m8[0] + m8[1] + m8[2] + m8[3] + m8[4] + m8[5] + m8[6] + m8[7];
assign m38_1bit = (sum_m8 >= count_pattern) ? 1 : 0;
$display("sum_m8=%d count_pattern=%d",sum_m8,count_pattern);
endmodule

module m_1bit_calcuate(
input [7:0] s_1bit,
input [7:0] p_1bit,
// output reg m8_1bit
output m8_1bit
);

// always@(*) begin
	// if (p_1bit == 94) begin // ^
		// if (s_1bit == 94)
			// m8_1bit = 1;
		// else if (s_1bit == 32)
			// m8_1bit = 1;
		// else
			// m8_1bit = 0;
	// end
	// else if (p_1bit == 36) begin // $
		// if (s_1bit == 36)
			// m8_1bit = 1;
		// else if (s_1bit == 32)
			// m8_1bit = 1;
		// else
			// m8_1bit = 0;
	// end
	// else if (p_1bit == 46) begin // .
		// if (s_1bit == 94) begin
			// m8_1bit = 0;
		// end
		// else if (s_1bit == 36) begin
			// m8_1bit = 0;
		// end
		// else begin
			// m8_1bit = 1;
		// end
	// end
	// else if (p_1bit == s_1bit) begin
		// m8_1bit = 1;
	// end
	// else begin
		// m8_1bit = 0;
	// end
// end

wire power;
wire money;
wire dot;
wire same;

assign power = (p_1bit == 94) && ((s_1bit == 94) || (s_1bit == 32));
assign money = (p_1bit == 36) && ((s_1bit == 36) || (s_1bit == 32));
assign dot   = (p_1bit == 46) &&  (s_1bit != 94) && (s_1bit != 36);
assign same  = (p_1bit == s_1bit);
assign m8_1bit = power || money || dot || same;

endmodule
