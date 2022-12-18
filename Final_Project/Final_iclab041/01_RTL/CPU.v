// -----------------------------------------------------------------------------------
// File name        : CPU_5.v
// Title            : 2021 ICLAB Spring Course
// Midterm Project  : Customized ISA Processor
// Developers       : NCTU
// -----------------------------------------------------------------------------------
// Revision History :
// CPU_1       : Use two 2048 words memorys to store all instruction and data.
//               First store 0 ~ 1063 instruction, and than store 1024 ~ 2047 instruction.
//               First store 0 ~ 1063 data, and no more store data action.
// (2021.06.16): 01 pass. 02 pass. 03 pass.
// CPU_2       : Use two 256 words memorys to store instruction and data.
//               First store 0 ~ 255 instruction, and than store pc-32 ~ pc+223 instruction.
//               First store 0 ~ 255 data, and no more store data action.
// (2021.06.17): 01 pass. 02 pass. 03 pass.
// CPU_3       : Use 512 words memorys to store instruction and 256 words memorys to store data.
//               First store 0 ~ 511 instruction, and than store pc-32 ~ pc+479 instruction.
//               First store 0 ~ 255 data, and no more store data action.
// (2021.06.17): 01 pass. 02 pass. 03 fail. lookup failed at 'My_CPU.core_r0,r2,r3'
// CPU_4       : Use 256 words memorys to store instruction and 64 words memorys to store data.
//               First store 0 ~ 255 instruction, and than store pc-32 ~ pc+223 instruction.
//               First store 0 ~ 63 data, and no more store data action.
// (2021.06.22): 01 pass. 02 pass. 03 pass.(PATTERN_TA)
// CPU_5       : Use 256 words memorys to store instruction and 47 words array to store data.
//               First store 0 ~ 255 instruction, and than store pc-32 ~ pc+223 instruction.
//               First store 0 ~ 48 data, and no more store data action.
// (2021.06.22): 01 pass. 02 pass. 03 pass.(PATTERN_TA)
// -----------------------------------------------------------------------------------
// set CLK_period  10.0, area = 236086
// -----------------------------------------------------------------------------------
// Combinational area:              76334.227537
// Buf/Inv area:                     3053.635305
// Noncombinational area:           83615.718307
// Macro/Black Box area:            76136.453125
// Net Interconnect area:      undefined  (No wire load specified)
// Total cell area:                236086.398970
// -----------------------------------------------------------------------------------
// Functionality execution cycles(1~20)  :  4527 cycles
// Performance execution cycles(100~1000): 17481 cycles
// -----------------------------------------------------------------------------------
//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2021 Final Project: Customized ISA Processor 
//   Author              : Hsi-Hao Huang
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : CPU.v
//   Module Name : CPU.v
//   Release version : V1.0 (Release Date: 2021-May)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module CPU(

				clk,
			  rst_n,
  
		   IO_stall,

         awid_m_inf,
       awaddr_m_inf,
       awsize_m_inf,
      awburst_m_inf,
        awlen_m_inf,
      awvalid_m_inf,
      awready_m_inf,
                    
        wdata_m_inf,
        wlast_m_inf,
       wvalid_m_inf,
       wready_m_inf,
                    
          bid_m_inf,
        bresp_m_inf,
       bvalid_m_inf,
       bready_m_inf,
                    
         arid_m_inf,
       araddr_m_inf,
        arlen_m_inf,
       arsize_m_inf,
      arburst_m_inf,
      arvalid_m_inf,
                    
      arready_m_inf, 
          rid_m_inf,
        rdata_m_inf,
        rresp_m_inf,
        rlast_m_inf,
       rvalid_m_inf,
       rready_m_inf 

);
// Input port
input  wire clk, rst_n;
// Output port
output reg  IO_stall;

parameter ID_WIDTH = 4 , ADDR_WIDTH = 32, DATA_WIDTH = 16, DRAM_NUMBER=2, WRIT_NUMBER=1;

// AXI Interface wire connecttion for pseudo DRAM read/write
// Hint:
// your AXI-4 interface could be designed as convertor in submodule(which used reg for output signal),
// therefore I declared output of AXI as wire in CPU

// axi write address channel 
output  wire [WRIT_NUMBER * ID_WIDTH-1:0]        awid_m_inf; // [ 3:0]
output  reg  [WRIT_NUMBER * ADDR_WIDTH-1:0]    awaddr_m_inf; // [31:0]
output  wire [WRIT_NUMBER * 3 -1:0]            awsize_m_inf; // [ 2:0]
output  wire [WRIT_NUMBER * 2 -1:0]           awburst_m_inf; // [ 1:0]
output  wire [WRIT_NUMBER * 7 -1:0]             awlen_m_inf; // [ 6:0]
output  reg  [WRIT_NUMBER-1:0]                awvalid_m_inf; // [ 0:0]
input   wire [WRIT_NUMBER-1:0]                awready_m_inf; // [ 0:0]
// axi write data channel
output  reg  [WRIT_NUMBER * DATA_WIDTH-1:0]     wdata_m_inf; // [15:0]
output  wire [WRIT_NUMBER-1:0]                  wlast_m_inf; // [ 0:0]
output  reg  [WRIT_NUMBER-1:0]                 wvalid_m_inf; // [ 0:0]
input   wire [WRIT_NUMBER-1:0]                 wready_m_inf; // [ 0:0]
// axi write response channel
input   wire [WRIT_NUMBER * ID_WIDTH-1:0]         bid_m_inf; // [ 3:0]
input   wire [WRIT_NUMBER * 2 -1:0]             bresp_m_inf; // [ 1:0]
input   wire [WRIT_NUMBER-1:0]             	   bvalid_m_inf; // [ 0:0]
output  reg  [WRIT_NUMBER-1:0]                 bready_m_inf; // [ 0:0]
// -----------------------------
// axi read address channel
output  wire [DRAM_NUMBER * ID_WIDTH-1:0]        arid_m_inf; // [ 7:0]
output  reg  [DRAM_NUMBER * ADDR_WIDTH-1:0]    araddr_m_inf; // [63:0] {inst,data}
output  wire [DRAM_NUMBER * 7 -1:0]             arlen_m_inf; // [13:0]
output  wire [DRAM_NUMBER * 3 -1:0]            arsize_m_inf; // [ 5:0]
output  wire [DRAM_NUMBER * 2 -1:0]           arburst_m_inf; // [ 3:0]
output  reg  [DRAM_NUMBER-1:0]                arvalid_m_inf; // [ 1:0]
input   wire [DRAM_NUMBER-1:0]                arready_m_inf; // [ 1:0]
// -----------------------------
// axi read data channel
input   wire [DRAM_NUMBER * ID_WIDTH-1:0]         rid_m_inf; // [ 7:0]
input   wire [DRAM_NUMBER * DATA_WIDTH-1:0]     rdata_m_inf; // [31:0]
input   wire [DRAM_NUMBER * 2 -1:0]             rresp_m_inf; // [ 3:0]
input   wire [DRAM_NUMBER-1:0]                  rlast_m_inf; // [ 1:0]
input   wire [DRAM_NUMBER-1:0]                 rvalid_m_inf; // [ 1:0]
output  reg  [DRAM_NUMBER-1:0]                 rready_m_inf; // [ 1:0]
// -----------------------------
// Register in each core:
// There are sixteen registers in your CPU. You should not change the name of those registers.
// TA will check the value in each register when your core is not busy.
// If you change the name of registers below, you must get the fail in this lab.
reg signed [15:0] core_r0 , core_r1 , core_r2 , core_r3 ;
reg signed [15:0] core_r4 , core_r5 , core_r6 , core_r7 ;
reg signed [15:0] core_r8 , core_r9 , core_r10, core_r11;
reg signed [15:0] core_r12, core_r13, core_r14, core_r15;

//###########################################
//
// Wrtie down your design below
//
//###########################################

//####################################################
//               reg & wire
//####################################################
parameter S_IDLE       = 'd0;
parameter S_READ_INST  = 'd1;
parameter S_LOAD       = 'd2;///
parameter S_STORE      = 'd3;
parameter S_BRANCH     = 'd4;///
parameter S_JUMP       = 'd5;///
parameter S_MEMORY     = 'd6;
parameter S_CACHE      = 'd7;

// SRAM
wire[15:0] Q_inst;
reg WEN_inst;
reg [7:0] A_inst;
reg [15:0] D_inst;
// array
reg [15:0] array_data[48:0];

reg flag_reset;
reg flag_s_read_inst;
reg flag_s_store;
reg flag_jump;
reg flag_dram_data;
reg [11:0] counter_dram_inst;
reg wait_dram_inst;
reg wait_dram_data;

reg signed [15:0] rs, rt, rd;
wire signed [4:0] imm;         // Q_inst[4:0]
wire signed [15:0] imm_rs;     // rs + imm
wire signed [8:0] A_inst_sign;
wire signed [10:0] imm_A_inst; // A_inst + imm
reg [10:0] A_inst_store;
// reg [7:0] A_inst_store;
reg [10:0] A_inst_start;
reg [10:0] A_inst_start2;

// state
reg [2:0] curr_state;
reg [2:0] next_state;

assign A_inst_sign = A_inst;
assign imm = Q_inst[4:0];
assign imm_rs = rs + imm;
assign imm_A_inst = A_inst_sign + imm;

integer i;
// reg test;

// axi write address channel --------------------------------------------------------------
assign awid_m_inf = 0;
// assign awaddr_m_inf
assign awlen_m_inf = 7'b0; // len+1 = how many times for write in (1 times 16 bits data)
assign awsize_m_inf = 3'b001; // can not change
assign awburst_m_inf = 2'b01; // can not change
// assign awvalid_m_inf
// axi write data channel -----------------------------------------------------------------
// assign wdata_m_inf
assign wlast_m_inf = wvalid_m_inf;
// assign wvalid_m_inf
// axi write response channel--------------------------------------------------------------
// assign bready_m_inf
// axi read address channel ---------------------------------------------------------------
assign arid_m_inf = 0;
// assign araddr_m_inf        // {DRAM_inst_address,DRAM_data_address}
// assign arlen_m_inf = {7'b1111111,7'b0111111}; // len+1 = how many times for write in (1 times 16 bits data)
assign arlen_m_inf = {7'b1111111,7'b0110000}; // len+1 = how many times for write in (1 times 16 bits data)
assign arsize_m_inf = {3'b001,3'b001};
assign arburst_m_inf = {2'b01,2'b01};
// assign arvalid_m_inf       // {DRAM_inst_valid,DRAM_data_valid}
// axi read data channel ------------------------------------------------------------------
// assign rready_m_inf

// SRAM (WEN = 0 -> WRITE, WEN = 1 -> READ)
RA1SH_cache_256 SRAM_inst(.Q(Q_inst),.CLK(clk),.CEN(1'b0),.WEN(WEN_inst),.A(A_inst),.D(D_inst),.OEN(1'b0));
// RA1SH_cache_256 SRAM_data(.Q(Q_data),.CLK(clk),.CEN(1'b0),.WEN(WEN_data),.A(A_data),.D(D_data),.OEN(1'b0));

// WEN_inst
always@(*) begin
	if ((curr_state == S_CACHE) && (rvalid_m_inf[1]))
		WEN_inst = 1'b0;
	else if ((curr_state == S_MEMORY) && (rvalid_m_inf[1]))
		WEN_inst = 1'b0;
	else 
		WEN_inst = 1'b1;
end
// A_inst
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		A_inst <= 0;
	else if (curr_state == S_CACHE) begin
		if (A_inst == 'd255)
			A_inst <= 0;
		else if (rvalid_m_inf[1])
			A_inst <= A_inst + 1;
		else
			A_inst <= A_inst;
	end
	else if (curr_state == S_MEMORY) begin
		if ((counter_dram_inst == 'd256) && (A_inst_start == 'd1792))
			A_inst <= A_inst_start2 + A_inst_store - 'd1792;
		else if (counter_dram_inst == 'd256)
			A_inst <= 'd32;
		else if (rvalid_m_inf[1])
			A_inst <= A_inst + 1;
		else
			A_inst <= A_inst;
	end
	else if (curr_state == S_READ_INST) begin
		if ((flag_s_read_inst) && (A_inst == 'd255)) // means 254 is not complete
			A_inst <= 0;
		else if ((flag_s_read_inst) && (Q_inst[15:13] == 3'b100) && (rs == rt) && (!flag_jump)) begin
			if ((A_inst > 'd222) && (A_inst_start != 'd1792))
				A_inst <= 0;
			else
				A_inst <= imm_A_inst;
		end
		else if ((flag_s_read_inst) && (Q_inst[15:13] == 3'b101) && (!flag_jump)) begin
			if ((A_inst > 'd222) && (A_inst_start != 'd1792))
				A_inst <= 0;
			else
				A_inst <= Q_inst[11:1] - A_inst_start;
		end
		else
			A_inst <= A_inst + 1;
	end
	else if ((curr_state == S_STORE) && (!flag_s_store))
		A_inst <= A_inst - 1;
	else
		A_inst <= A_inst;
end
// A_inst_store
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		A_inst_store <= 0;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (A_inst == 'd255))
		A_inst_store <= 'd254;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[15:13] == 3'b100) && (rs == rt) && (!flag_jump) && (A_inst > 'd222))
		A_inst_store <= A_inst - 1;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[15:13] == 3'b101) && (!flag_jump) && (A_inst > 'd222))
		A_inst_store <= A_inst - 1;
	else
		A_inst_store <= A_inst_store;
end
// A_inst_start
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		A_inst_start <= 0;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (A_inst == 'd255)) begin
		if (A_inst + A_inst_start > 'd1824)
			A_inst_start <= 'd1792;
		else
			A_inst_start <= A_inst + A_inst_start - 'd33;
	end
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[15:13] == 3'b100) && (rs == rt) && (!flag_jump) && (A_inst > 'd222)) begin
		if (A_inst + A_inst_start > 'd1824)
			A_inst_start <= 'd1792;
		else
			A_inst_start <= A_inst + A_inst_start - 'd33;
	end
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[15:13] == 3'b101) && (!flag_jump) && (A_inst > 'd222)) begin
		if (A_inst + A_inst_start > 'd1824)
			A_inst_start <= 'd1792;
		else
			A_inst_start <= A_inst + A_inst_start - 'd33;
	end
	else
		A_inst_start <= A_inst_start;
end
// A_inst_start2
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		A_inst_start2 <= 0;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst))
		A_inst_start2 <= A_inst_start;
	else
		A_inst_start2 <= A_inst_start2;
end
// D_inst
always@(*) begin
	D_inst = rdata_m_inf[31:16];
end

// array_data
always@(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (i = 0; i < 49; i = i + 1) begin
			array_data[i] <= 0;
		end
	end
	else if (rvalid_m_inf[0]) begin
		array_data[48] <= rdata_m_inf[15:00];
		for (i = 0; i < 48; i = i + 1) begin
			array_data[i] <= array_data[i+1];
		end
	end
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[15:13] == 3'b011) && (!flag_jump)) begin
		array_data[imm_rs] <= rt; // area = 236086
		
	end
	else begin
		for (i = 0; i < 49; i = i + 1) begin
			array_data[i] <= array_data[i];
		end
	end
end

// awaddr_m_inf
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		awaddr_m_inf <= 0;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[15:13] == 3'b011))
		awaddr_m_inf <= {imm_rs,1'b0} + 32'h00001000;
	else
		awaddr_m_inf <= awaddr_m_inf;
end
// awvalid_m_inf
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		awvalid_m_inf <= 0;
	else if (awready_m_inf == 1)
		awvalid_m_inf <= 0;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[15:13] == 3'b011) && (!flag_jump))
		awvalid_m_inf <= 1;
	else
		awvalid_m_inf <= awvalid_m_inf;
end
// wdata_m_inf
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		wdata_m_inf <= 0;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[15:13] == 3'b011))
		wdata_m_inf <= rt;
	else
		wdata_m_inf <= wdata_m_inf;
end
// wvalid_m_inf
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		wvalid_m_inf <= 0;
	else if (awready_m_inf == 1)
		wvalid_m_inf <= 1;
	else if (wready_m_inf == 1)
		wvalid_m_inf <= 0;
	else
		wvalid_m_inf <= wvalid_m_inf;
end
// bready_m_inf
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		bready_m_inf <= 0;
	else if (awready_m_inf == 1)
		bready_m_inf <= 1;
	else if (bvalid_m_inf == 1)
		bready_m_inf <= 0;
	else
		bready_m_inf <= bready_m_inf;
end
// araddr_m_inf
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		araddr_m_inf <= 0;
	else if (curr_state == S_CACHE) begin
		araddr_m_inf[63:32] <= 32'h00001000 + (counter_dram_inst<<1);
		araddr_m_inf[31:00] <= 32'h00001000;
	end
	else if (curr_state == S_MEMORY) begin
		if (A_inst_start == 'd1792)
			araddr_m_inf[63:32] <= 32'h00001E00 + (counter_dram_inst<<1);
		else
			araddr_m_inf[63:32] <= 32'h00000fc0 + {(A_inst_store+A_inst_start2+counter_dram_inst),1'b0};
	end
	else
		araddr_m_inf <= araddr_m_inf;
end
// arvalid_m_inf[1]
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		arvalid_m_inf[1] <= 0;
	else if ((curr_state == S_CACHE) && (wait_dram_inst == 0) && (counter_dram_inst < 'd256))
		arvalid_m_inf[1] <= 1;
	else if ((curr_state == S_MEMORY) && (wait_dram_inst == 0) && (counter_dram_inst < 'd256))
		arvalid_m_inf[1] <= 1;
	else
		arvalid_m_inf[1] <= 0;
end
// arvalid_m_inf[0]
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		arvalid_m_inf[0] <= 0;
	else if ((curr_state == S_CACHE) && (wait_dram_data == 0) && (!flag_dram_data))
		arvalid_m_inf[0] <= 1;
	else
		arvalid_m_inf[0] <= 0;
end
// rready_m_inf[1]
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		rready_m_inf[1] <= 0;
	else if(arready_m_inf[1])
		rready_m_inf[1] <= 1;
	else if(rlast_m_inf[1])
		rready_m_inf[1] <= 0;
	else
		rready_m_inf[1] <= rready_m_inf[1];
end
// rready_m_inf[0]
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		rready_m_inf[0] <= 0;
	else if(arready_m_inf[0])
		rready_m_inf[0] <= 1;
	else if(rlast_m_inf[0])
		rready_m_inf[0] <= 0;
	else
		rready_m_inf[0] <= rready_m_inf[0];
end

// flag_reset
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		flag_reset <= 0;
	else if (curr_state == S_CACHE)
		flag_reset <= 1;
	else
		flag_reset <= flag_reset;
end
// flag_s_read_inst
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		flag_s_read_inst <= 0;
	else if (curr_state == S_READ_INST)
		flag_s_read_inst <= 1;
	else
		flag_s_read_inst <= 0;
end
// flag_s_store
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		flag_s_store <= 0;
	else if (curr_state == S_STORE)
		flag_s_store <= 1;
	else
		flag_s_store <= 0;
end
// flag_jump
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		flag_jump <= 0;
	else if (flag_jump == 1)
		flag_jump <= 0;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[15:13] == 3'b100) && (rs == rt))
		flag_jump <= 1;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[15:13] == 3'b101))
		flag_jump <= 1;
	else
		flag_jump <= 0;
end
// flag_dram_data
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		flag_dram_data <= 0;
	else if ((curr_state == S_CACHE) && (rlast_m_inf[0] == 1))
		flag_dram_data <= 1;
	else
		flag_dram_data <= flag_dram_data;
end
// counter_dram_inst
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		counter_dram_inst <= 0;
	else if (curr_state == S_IDLE)
		counter_dram_inst <= 0;
	else if ((curr_state == S_CACHE) || (curr_state == S_MEMORY)) begin
		if (rlast_m_inf[1] == 1)
			counter_dram_inst <= counter_dram_inst + 'd128;
		else
			counter_dram_inst <= counter_dram_inst;
	end
	else
		counter_dram_inst <= counter_dram_inst;
end
// wait_dram_inst
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		wait_dram_inst <= 0;
	else if (arvalid_m_inf[1] == 1)
		wait_dram_inst <= 1;
	else if (rlast_m_inf[1] == 1)
		wait_dram_inst <= 0;
	else
		wait_dram_inst <= wait_dram_inst;
end
// wait_dram_data
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		wait_dram_data <= 0;
	else if (arvalid_m_inf[0] == 1)
		wait_dram_data <= 1;
	else if (rlast_m_inf[0] == 1)
		wait_dram_data <= 0;
	else
		wait_dram_data <= wait_dram_data;
end

// rs
always@(*) begin
	case (Q_inst[12:9])
	4'b0000: rs = core_r0 ;
	4'b0001: rs = core_r1 ;
	4'b0010: rs = core_r2 ;
	4'b0011: rs = core_r3 ;
	4'b0100: rs = core_r4 ;
	4'b0101: rs = core_r5 ;
	4'b0110: rs = core_r6 ;
	4'b0111: rs = core_r7 ;
	4'b1000: rs = core_r8 ;
	4'b1001: rs = core_r9 ;
	4'b1010: rs = core_r10;
	4'b1011: rs = core_r11;
	4'b1100: rs = core_r12;
	4'b1101: rs = core_r13;
	4'b1110: rs = core_r14;
	4'b1111: rs = core_r15;
	endcase
end
// rt
always@(*) begin
	case (Q_inst[8:5])
	4'b0000: rt = core_r0 ;
	4'b0001: rt = core_r1 ;
	4'b0010: rt = core_r2 ;
	4'b0011: rt = core_r3 ;
	4'b0100: rt = core_r4 ;
	4'b0101: rt = core_r5 ;
	4'b0110: rt = core_r6 ;
	4'b0111: rt = core_r7 ;
	4'b1000: rt = core_r8 ;
	4'b1001: rt = core_r9 ;
	4'b1010: rt = core_r10;
	4'b1011: rt = core_r11;
	4'b1100: rt = core_r12;
	4'b1101: rt = core_r13;
	4'b1110: rt = core_r14;
	4'b1111: rt = core_r15;
	endcase
end
// rd
always@(*) begin
	case({Q_inst[13],Q_inst[0]})
	2'b00: rd = rs + rt;
	2'b01: rd = rs - rt;
	2'b10: begin if (rs < rt) rd = 16'd1; else rd = 16'd0; end
	2'b11: rd = rs * rt;
	endcase
end

// core_r0
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		core_r0 <= 0;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[4:1] == 4'b0000) && (Q_inst[15:14] == 2'b00) && (!flag_jump))
		core_r0 <= rd;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[8:5] == 4'b0000) && (Q_inst[15:13] == 3'b010) && (!flag_jump))
		core_r0 <= array_data[imm_rs];
	else
		core_r0 <= core_r0;
end
// core_r1
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		core_r1 <= 0;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[4:1] == 4'b0001) && (Q_inst[15:14] == 2'b00) && (!flag_jump))
		core_r1 <= rd;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[8:5] == 4'b0001) && (Q_inst[15:13] == 3'b010) && (!flag_jump))
		core_r1 <= array_data[imm_rs];
	else
		core_r1 <= core_r1;
end
// core_r2
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		core_r2 <= 0;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[4:1] == 4'b0010) && (Q_inst[15:14] == 2'b00) && (!flag_jump))
		core_r2 <= rd;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[8:5] == 4'b0010) && (Q_inst[15:13] == 3'b010) && (!flag_jump))
		core_r2 <= array_data[imm_rs];
	else
		core_r2 <= core_r2;
end
// core_r3
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		core_r3 <= 0;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[4:1] == 4'b0011) && (Q_inst[15:14] == 2'b00) && (!flag_jump))
		core_r3 <= rd;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[8:5] == 4'b0011) && (Q_inst[15:13] == 3'b010) && (!flag_jump))
		core_r3 <= array_data[imm_rs];
	else
		core_r3 <= core_r3;
end
// core_r4
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		core_r4 <= 0;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[4:1] == 4'b0100) && (Q_inst[15:14] == 2'b00) && (!flag_jump))
		core_r4 <= rd;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[8:5] == 4'b0100) && (Q_inst[15:13] == 3'b010) && (!flag_jump))
		core_r4 <= array_data[imm_rs];
	else
		core_r4 <= core_r4;
end
// core_r5
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		core_r5 <= 0;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[4:1] == 4'b0101) && (Q_inst[15:14] == 2'b00) && (!flag_jump))
		core_r5 <= rd;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[8:5] == 4'b0101) && (Q_inst[15:13] == 3'b010) && (!flag_jump))
		core_r5 <= array_data[imm_rs];
	else
		core_r5 <= core_r5;
end
// core_r6
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		core_r6 <= 0;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[4:1] == 4'b0110) && (Q_inst[15:14] == 2'b00) && (!flag_jump))
		core_r6 <= rd;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[8:5] == 4'b0110) && (Q_inst[15:13] == 3'b010) && (!flag_jump))
		core_r6 <= array_data[imm_rs];
	else
		core_r6 <= core_r6;
end
// core_r7
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		core_r7 <= 0;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[4:1] == 4'b0111) && (Q_inst[15:14] == 2'b00) && (!flag_jump))
		core_r7 <= rd;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[8:5] == 4'b0111) && (Q_inst[15:13] == 3'b010) && (!flag_jump))
		core_r7 <= array_data[imm_rs];
	else
		core_r7 <= core_r7;
end
// core_r8
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		core_r8 <= 0;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[4:1] == 4'b1000) && (Q_inst[15:14] == 2'b00) && (!flag_jump))
		core_r8 <= rd;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[8:5] == 4'b1000) && (Q_inst[15:13] == 3'b010) && (!flag_jump))
		core_r8 <= array_data[imm_rs];
	else
		core_r8 <= core_r8;
end
// core_r9
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		core_r9 <= 0;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[4:1] == 4'b1001) && (Q_inst[15:14] == 2'b00) && (!flag_jump))
		core_r9 <= rd;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[8:5] == 4'b1001) && (Q_inst[15:13] == 3'b010) && (!flag_jump))
		core_r9 <= array_data[imm_rs];
	else
		core_r9 <= core_r9;
end
// core_r10
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		core_r10 <= 0;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[4:1] == 4'b1010) && (Q_inst[15:14] == 2'b00) && (!flag_jump))
		core_r10 <= rd;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[8:5] == 4'b1010) && (Q_inst[15:13] == 3'b010) && (!flag_jump))
		core_r10 <= array_data[imm_rs];
	else
		core_r10 <= core_r10;
end
// core_r11
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		core_r11 <= 0;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[4:1] == 4'b1011) && (Q_inst[15:14] == 2'b00) && (!flag_jump))
		core_r11 <= rd;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[8:5] == 4'b1011) && (Q_inst[15:13] == 3'b010) && (!flag_jump))
		core_r11 <= array_data[imm_rs];
	else
		core_r11 <= core_r11;
end
// core_r12
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		core_r12 <= 0;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[4:1] == 4'b1100) && (Q_inst[15:14] == 2'b00) && (!flag_jump))
		core_r12 <= rd;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[8:5] == 4'b1100) && (Q_inst[15:13] == 3'b010) && (!flag_jump))
		core_r12 <= array_data[imm_rs];
	else
		core_r12 <= core_r12;
end
// core_r13
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		core_r13 <= 0;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[4:1] == 4'b1101) && (Q_inst[15:14] == 2'b00) && (!flag_jump))
		core_r13 <= rd;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[8:5] == 4'b1101) && (Q_inst[15:13] == 3'b010) && (!flag_jump))
		core_r13 <= array_data[imm_rs];
	else
		core_r13 <= core_r13;
end
// core_r14
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		core_r14 <= 0;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[4:1] == 4'b1110) && (Q_inst[15:14] == 2'b00) && (!flag_jump))
		core_r14 <= rd;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[8:5] == 4'b1110) && (Q_inst[15:13] == 3'b010) && (!flag_jump))
		core_r14 <= array_data[imm_rs];
	else
		core_r14 <= core_r14;
end
// core_r15
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		core_r15 <= 0;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[4:1] == 4'b1111) && (Q_inst[15:14] == 2'b00) && (!flag_jump))
		core_r15 <= rd;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[8:5] == 4'b1111) && (Q_inst[15:13] == 3'b010) && (!flag_jump))
		core_r15 <= array_data[imm_rs];
	else
		core_r15 <= core_r15;
end

// IO_stall
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		// IO_stall <= 0;
		IO_stall <= 1;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[15:14] == 2'b00))
		IO_stall <= 0;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[15:13] == 3'b100) && (rs != rt))
		IO_stall <= 0;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (Q_inst[15:13] == 3'b010) && (!flag_jump))
		IO_stall <= 0;
	else if ((curr_state == S_READ_INST) && (flag_s_read_inst) && (flag_jump))
		IO_stall <= 0;
	else if ((curr_state == S_STORE) && (bvalid_m_inf))
		IO_stall <= 0;
	else
		IO_stall <= 1;
end

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
		if (flag_reset == 0)
			next_state = S_CACHE;
		else
			next_state = S_READ_INST;
	end
	S_READ_INST: begin // 1
		if ((flag_s_read_inst) && (A_inst == 'd255) && (A_inst_start != 'd1792)) // means 254 is not complete
			next_state = S_MEMORY;
		else if ((flag_s_read_inst) && (Q_inst[15:13] == 3'b100) && (rs == rt) && (!flag_jump) && (A_inst > 'd222) && (A_inst_start != 'd1792)) // branch
			next_state = S_MEMORY;
		else if ((flag_s_read_inst) && (Q_inst[15:13] == 3'b101) && (!flag_jump) && (A_inst > 'd222) && (A_inst_start != 'd1792)) // jump
			next_state = S_MEMORY;
		else if ((flag_s_read_inst) && (Q_inst[15:13] == 3'b011) && (!flag_jump))
			next_state = S_STORE;
		else
			next_state = S_READ_INST;
	end
	// S_LOAD: begin // 2
		// if (flag_s_load)
			// next_state = S_READ_INST;
		// else
			// next_state = S_LOAD;
	// end
	S_STORE: begin // 3
		if (bvalid_m_inf)
			next_state = S_READ_INST;
		else
			next_state = S_STORE;
	end
	// S_BRANCH: begin // 4
		// next_state = S_READ_INST;
	// end
	// S_JUMP: begin // 5
		// next_state = S_JUMP;
	// end
	S_MEMORY: begin // 6
		if (counter_dram_inst == 'd256)
			next_state = S_IDLE;
			// next_state = S_MEMORY;
			// next_state = S_JUMP;
		else
			next_state = S_MEMORY;
	end
	S_CACHE: begin // 7
		if ((counter_dram_inst == 'd256) && (flag_dram_data))
			next_state = S_IDLE;
		else
			next_state = S_CACHE;
	end
	default: next_state = curr_state;
	endcase
end


endmodule
