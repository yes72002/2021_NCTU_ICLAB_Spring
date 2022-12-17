
module SMC(
	W_0, V_GS_0, V_DS_0,
	W_1, V_GS_1, V_DS_1,
	W_2, V_GS_2, V_DS_2,
	W_3, V_GS_3, V_DS_3,
	W_4, V_GS_4, V_DS_4,
	W_5, V_GS_5, V_DS_5,
	mode,
	out_n
);
input [2:0] W_0, V_GS_0, V_DS_0;
input [2:0] W_1, V_GS_1, V_DS_1;
input [2:0] W_2, V_GS_2, V_DS_2;
input [2:0] W_3, V_GS_3, V_DS_3;
input [2:0] W_4, V_GS_4, V_DS_4;
input [2:0] W_5, V_GS_5, V_DS_5;
input [1:0] mode;
output [9:0] out_n;

wire [9:0] out_n;
wire [9:0] Id_0, Id_1, Id_2, Id_3, Id_4, Id_5;
wire [9:0] gm_0, gm_1, gm_2, gm_3, gm_4, gm_5;
wire [9:0]   m0,   m1,   m2,   m3,   m4,   m5;
wire [9:0]   n0,   n1,   n2,   n3,   n4,   n5;

Idgm Idgm0(.W(W_0), .V_GS(V_GS_0), .V_DS(V_DS_0), .Id(Id_0), .gm(gm_0));
Idgm Idgm1(.W(W_1), .V_GS(V_GS_1), .V_DS(V_DS_1), .Id(Id_1), .gm(gm_1));
Idgm Idgm2(.W(W_2), .V_GS(V_GS_2), .V_DS(V_DS_2), .Id(Id_2), .gm(gm_2));
Idgm Idgm3(.W(W_3), .V_GS(V_GS_3), .V_DS(V_DS_3), .Id(Id_3), .gm(gm_3));
Idgm Idgm4(.W(W_4), .V_GS(V_GS_4), .V_DS(V_DS_4), .Id(Id_4), .gm(gm_4));
Idgm Idgm5(.W(W_5), .V_GS(V_GS_5), .V_DS(V_DS_5), .Id(Id_5), .gm(gm_5));

assign  m0 = (Id_0 * mode[0]) + (gm_0 * !(mode[0]));
assign  m1 = (Id_1 * mode[0]) + (gm_1 * !(mode[0]));
assign  m2 = (Id_2 * mode[0]) + (gm_2 * !(mode[0]));
assign  m3 = (Id_3 * mode[0]) + (gm_3 * !(mode[0]));
assign  m4 = (Id_4 * mode[0]) + (gm_4 * !(mode[0]));
assign  m5 = (Id_5 * mode[0]) + (gm_5 * !(mode[0]));

Sort Sort0(. in0(m0), . in1(m1), . in2(m2), . in3(m3), . in4(m4), . in5(m5), 
           .out0(n0), .out1(n1), .out2(n2), .out3(n3), .out4(n4), .out5(n5));

Calculate Calculate0(.in0(n0), .in1(n1), .in2(n2), .in3(n3), .in4(n4), .in5(n5),
                     .mode(mode), .out(out_n));

endmodule


//================================================================
// SUB MODULE Idgm
//================================================================
module Idgm (W,V_GS,V_DS,Id,gm);
input  [2:0] W,V_GS,V_DS;
output [9:0] Id,gm;

reg [9:0] Id,gm;
reg [2:0] V_OV;
reg [2:0] V_SAT;
reg [5:0] W_V_SAT;
always@(*) begin
	V_OV = V_GS - 1;
	if(( V_OV >= 0) && (V_OV > V_DS)) begin //Triode region
		V_SAT = V_DS;	
	end
	else if ((V_OV >= 0) && (V_OV <= V_DS)) begin //Saturation region
		V_SAT = V_OV;
	end
	else begin
		V_SAT = 0;
	end
	W_V_SAT = W*V_SAT;
	Id = W_V_SAT*(2*V_OV-V_SAT) / 3;
	gm = (W_V_SAT << 1) / 3;
end

endmodule


//================================================================
// SUB MODULE Sort
//================================================================
module Sort (in0,in1,in2,in3,in4,in5,out0,out1,out2,out3,out4,out5);
input  [9:0] in0,in1,in2,in3,in4,in5;
output [9:0] out0,out1,out2,out3,out4,out5;

reg [9:0]  out0,  out1,  out2,  out3,  out4,  out5;
reg [9:0] in_o0, in_o1, in_o2, in_o3, in_o4, in_o5;
reg [9:0] in_p0, in_p1, in_p2, in_p3, in_p4, in_p5;
reg [9:0] in_q0, in_q1, in_q2, in_q3, in_q4, in_q5;
reg [9:0] in_r0, in_r1, in_r2, in_r3, in_r4, in_r5;
reg [9:0] in_s0, in_s1, in_s2, in_s3, in_s4, in_s5;

always@(*) begin
	in_o0 = (in0 > in1) ? in0 : in1;
	in_o1 = (in0 > in1) ? in1 : in0;
	in_o2 = (in2 > in3) ? in2 : in3;
	in_o3 = (in2 > in3) ? in3 : in2;
	in_o4 = (in4 > in5) ? in4 : in5;
	in_o5 = (in4 > in5) ? in5 : in4;

	in_p0 = in_o0;
	in_p1 = (in_o1 > in_o2) ? in_o1 : in_o2;
	in_p2 = (in_o1 > in_o2) ? in_o2 : in_o1;
	in_p3 = (in_o3 > in_o4) ? in_o3 : in_o4;
	in_p4 = (in_o3 > in_o4) ? in_o4 : in_o3;
	in_p5 = in_o5;
	
	in_q0 = (in_p0 > in_p1) ? in_p0 : in_p1;
	in_q1 = (in_p0 > in_p1) ? in_p1 : in_p0;
	in_q2 = (in_p2 > in_p3) ? in_p2 : in_p3;
	in_q3 = (in_p2 > in_p3) ? in_p3 : in_p2;
	in_q4 = (in_p4 > in_p5) ? in_p4 : in_p5;
	in_q5 = (in_p4 > in_p5) ? in_p5 : in_p4;
	
	in_r0 = in_q0;
	in_r1 = (in_q1 > in_q2) ? in_q1 : in_q2;
	in_r2 = (in_q1 > in_q2) ? in_q2 : in_q1;
	in_r3 = (in_q3 > in_q4) ? in_q3 : in_q4;
	in_r4 = (in_q3 > in_q4) ? in_q4 : in_q3;
	in_r5 = in_q5;
	
	in_s0 = (in_r0 > in_r1) ? in_r0 : in_r1;
	in_s1 = (in_r0 > in_r1) ? in_r1 : in_r0;
	in_s2 = (in_r2 > in_r3) ? in_r2 : in_r3;
	in_s3 = (in_r2 > in_r3) ? in_r3 : in_r2;
	in_s4 = (in_r4 > in_r5) ? in_r4 : in_r5;
	in_s5 = (in_r4 > in_r5) ? in_r5 : in_r4;
	
	out0 =  in_s0;
	out1 = (in_s1 > in_s2) ? in_s1 : in_s2;
	out2 = (in_s1 > in_s2) ? in_s2 : in_s1;
	out3 = (in_s3 > in_s4) ? in_s3 : in_s4;
	out4 = (in_s3 > in_s4) ? in_s4 : in_s3;
	out5 =  in_s5;
end

endmodule


//================================================================
// SUB MODULE Calculate
//================================================================
module Calculate (in0,in1,in2,in3,in4,in5,mode,out);
input  [9:0] in0,in1,in2,in3,in4,in5;
input  [1:0] mode;
output [9:0] out;

reg [9:0] out;
reg [9:0] Part_A, Part_B, Part_C;
reg [9:0]  out_1,  out_2;
always@(*) begin
	//mode=00: smaller transconductance
	//mode=01: smaller current
	//mode=10: larger  transconductance
	//mode=11: larger  current
	if (mode[1]==1) begin
		Part_A = in0;
		Part_B = in1;
		Part_C = in2;
	end
	else begin
		Part_A = in3;
		Part_B = in4;
		Part_C = in5;
	end
	// out_1 = 3*Part_A + (Part_B << 2)+ 5*Part_C; // area = 57862
	out_1 = (Part_A<<1)+Part_A + (Part_B << 2)+ (Part_C<<2)+Part_C; //area = 58002

	out_2 =   Part_A +       Part_B +   Part_C;
	out = (out_1 * mode[0]) + (out_2 * !(mode[0]));
end

endmodule

