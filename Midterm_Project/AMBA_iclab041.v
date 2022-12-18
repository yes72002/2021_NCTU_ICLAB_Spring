//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Si2 LAB @NCTU ED415
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2021 spring
//   Midterm Proejct            : AMBA (Cache & AXI-4)
//   Author                     : Hsi-Hao Huang
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : AMBA.v
//   Module Name : AMBA
//   Release version : V1.0 (Release Date: 2021-04)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module AMBA(
				clk,	
			  rst_n,	
	
			  PADDR,
			 PRDATA,
			  PSELx, 
			PENABLE, 
			 PWRITE, 
			 PREADY,  
	

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
parameter ID_WIDTH = 4 , ADDR_WIDTH = 32, DATA_WIDTH = 32, DRAM_NUMBER=2, WRIT_NUMBER=1;
input			  clk,rst_n;



// AXI Interface wire connecttion for pseudo DRAM read/write
/* Hint:
       your AXI-4 interface could //b//e// designed as convertor in submodule(which used reg for output signal),
	   therefore I declared output of AXI as wire in Poly_Ring
*/
   
// -----------------------------
// APB channel 
input   wire [ADDR_WIDTH-1:0] 	   PADDR;
output  reg [DATA_WIDTH-1:0]  	  PRDATA;
input   wire			    	   PSELx;
input   wire		             PENABLE;
input   wire 		              PWRITE;
output  reg 			          PREADY;
// -----------------------------


// axi write address channel 
output  wire [WRIT_NUMBER * ID_WIDTH-1:0]        awid_m_inf; // [ 3:0]
output  reg  [WRIT_NUMBER * ADDR_WIDTH-1:0]    awaddr_m_inf; // [31:0]
output  wire [WRIT_NUMBER * 3 -1:0]            awsize_m_inf; // [ 2:0]
output  wire [WRIT_NUMBER * 2 -1:0]           awburst_m_inf; // [ 1:0]
output  wire [WRIT_NUMBER * 4 -1:0]             awlen_m_inf; // [ 3:0]
output  reg  [WRIT_NUMBER-1:0]                awvalid_m_inf; // [   0]
input   wire [WRIT_NUMBER-1:0]                awready_m_inf; // [   0]
// axi write data channel                                   
output  reg  [WRIT_NUMBER * DATA_WIDTH-1:0]     wdata_m_inf; // [31:0]
output  reg  [WRIT_NUMBER-1:0]                  wlast_m_inf; // [   0]
output  reg  [WRIT_NUMBER-1:0]                 wvalid_m_inf; // [   0]
input   wire [WRIT_NUMBER-1:0]                 wready_m_inf; // [   0]
// axi write response channel                               
input   wire [WRIT_NUMBER * ID_WIDTH-1:0]         bid_m_inf; // [31:0]
input   wire [WRIT_NUMBER * 2 -1:0]             bresp_m_inf; // [ 1:0]
input   wire [WRIT_NUMBER-1:0]             	   bvalid_m_inf; // [   0]
output  reg  [WRIT_NUMBER-1:0]                 bready_m_inf; // [   0]
// -----------------------------
// axi read address channel 
output  wire [DRAM_NUMBER * ID_WIDTH-1:0]       arid_m_inf; // [ 7:0]
output  reg [DRAM_NUMBER * ADDR_WIDTH-1:0]    araddr_m_inf; // [63:0]
output  reg [DRAM_NUMBER * 4 -1:0]             arlen_m_inf; // [ 7:0]
output  wire [DRAM_NUMBER * 3 -1:0]           arsize_m_inf; // [ 5:0]
output  wire [DRAM_NUMBER * 2 -1:0]          arburst_m_inf; // [ 3:0]
output  reg [DRAM_NUMBER-1:0]                arvalid_m_inf; // [ 1:0]
input   wire [DRAM_NUMBER-1:0]               arready_m_inf; // [ 1:0]
// -----------------------------
// axi read data channel 
input   wire [DRAM_NUMBER * ID_WIDTH-1:0]         rid_m_inf;
input   wire [DRAM_NUMBER * DATA_WIDTH-1:0]     rdata_m_inf;
input   wire [DRAM_NUMBER * 2 -1:0]             rresp_m_inf;
input   wire [DRAM_NUMBER-1:0]                  rlast_m_inf;
input   wire [DRAM_NUMBER-1:0]                 rvalid_m_inf;
output  reg [DRAM_NUMBER-1:0]                  rready_m_inf;
// -----------------------------

//####################################################
//               reg & wire
//####################################################
parameter S_IDLE       = 'd0;
parameter S_READ_INST  = 'd1;
parameter S_READ_MULT  = 'd2;
parameter S_READ_CONV  = 'd3;
parameter S_CALC_MULT  = 'd4;
parameter S_CALC_CONV  = 'd5;
parameter S_WRITE_DRAM = 'd6;
parameter S_WRITE_SRAM = 'd7;
parameter S_DONE       = 'd8;
parameter S_CACHE      = 'd9;

parameter MULT      = 2'b00;
parameter CONV      = 2'b11;

wire[31:0] Q_cache1,Q_cache2,Q_cal_1,Q_cal_2,Q_cal_3;
reg WEN_cache1,WEN_cache2,WEN_cal_1,WEN_cal_2,WEN_cal_3;
reg [8:0] A_cache1,A_cache2,A_cal_1;
reg [7:0] A_cal_2,A_cal_3;
reg [31:0] D_cache1,D_cache2,D_cal_1,D_cal_2,D_cal_3;

reg rst_flag;
reg [63:0] address_start;
reg [1:0] op;
reg [13:0] counter_dram_read;
reg [13:0] counter_dram_1;
reg [7:0] counter_mult_read;
reg [7:0] counter_mult_1;
reg [13:0] counter_mult;
reg [4:0] counter_mult_row;
reg [3:0] counter_mult_col;
reg [7:0] counter_sum_mult;
reg [7:0] counter_sum_mult1;
reg [7:0] counter_sum_mult2;
reg [7:0] counter_sum_conv;
reg [7:0] counter_sum_conv1;
reg [7:0] counter_sum_conv2;
reg [7:0] counter_sum_conv3;
reg [7:0] counter_write_data;
reg [31:0] sum_mult0;
reg [31:0] sum_mult1;
reg wait_dram_read;
reg wait_dram_1;
reg need_dram_read;
reg need_dram_1;
reg flag_read_mult;
reg flag_calc_mult;
reg flag_calc_mult1;
reg flag_write_sram;
reg flag_write_sram1;
reg wvalid_delay1;

reg [31:0] PRDATA_temp;
reg [3:0] curr_state;
reg [3:0] next_state;

integer i;
// axi write address channel --------------------------------------------------------------
assign awid_m_inf = 0;
// assign awaddr_m_inf
assign awsize_m_inf = 3'b010; // can not change
assign awburst_m_inf = 2'b01; // can not change
assign awlen_m_inf = 4'b1111; // len+1 = how many times for write in (1 times 32 bits data)
// assign awvalid_m_inf
// axi write data channel -----------------------------------------------------------------
// assign wdata_m_inf
// assign wlast_m_inf
// assign wvalid_m_inf
// axi write response channel--------------------------------------------------------------
// assign bready_m_inf
// axi read address channel ---------------------------------------------------------------
assign arid_m_inf = 0;
// assign araddr_m_inf        // {DRAM_read_address,DRAM_1_address}
// assign arlen_m_inf         // len+1 = how many times for write in (1 times 32 bits data)
assign arsize_m_inf = {3'b010,3'b010};
assign arburst_m_inf = {2'b01,2'b01};
// assign arvalid_m_inf       // {DRAM_read_valid,DRAM_1_valid}
// axi read data channel ------------------------------------------------------------------
// assign rready_m_inf
// SRAM (WEN = 0 -> WRITE, WEN = 1 -> READ)
RA1SH_cache SRAM_cache_1(.Q(Q_cache1),.CLK(clk),.CEN(1'b0),.WEN(WEN_cache1),.A(A_cache1),.D(D_cache1),.OEN(1'b0));
RA1SH_cache SRAM_cache_2(.Q(Q_cache2),.CLK(clk),.CEN(1'b0),.WEN(WEN_cache2),.A(A_cache2),.D(D_cache2),.OEN(1'b0));
RA1SH_cal_1 SRAM_cal_1(.Q(Q_cal_1),.CLK(clk),.CEN(1'b0),.WEN(WEN_cal_1),.A(A_cal_1),.D(D_cal_1),.OEN(1'b0));
RA1SH_cal_2 SRAM_cal_2(.Q(Q_cal_2),.CLK(clk),.CEN(1'b0),.WEN(WEN_cal_2),.A(A_cal_2),.D(D_cal_2),.OEN(1'b0));
RA1SH_cal_2 SRAM_cal_3(.Q(Q_cal_3),.CLK(clk),.CEN(1'b0),.WEN(WEN_cal_3),.A(A_cal_3),.D(D_cal_3),.OEN(1'b0));

// WEN_cache1
always@(*) begin
	if ((curr_state == S_CACHE) && (rvalid_m_inf[0]))
		WEN_cache1 = 1'b0;
	else if ((curr_state == S_WRITE_SRAM) && (counter_write_data < (1536 - address_start[31:02])))
		WEN_cache1 = 1'b0;
	else 
		WEN_cache1 = 1'b1;
end
// WEN_cache2
always@(*) begin
	if ((curr_state == S_CACHE) && (rvalid_m_inf[1]))
		WEN_cache2 = 1'b0;
	else
		WEN_cache2 = 1'b1;
end
// A_cache1
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		A_cache1 <= 0;
	else if (curr_state == S_CACHE) begin
		if(rvalid_m_inf[0])
			A_cache1 <= A_cache1 + 1;
		else
			A_cache1 <= A_cache1;
	end
	else if (curr_state == S_READ_INST)
		A_cache1 <= (rdata_m_inf[63:50] - 1024); // (address_start[31:00] - 4096)/4
	else if ((curr_state == S_READ_MULT) || (curr_state == S_READ_CONV))
		A_cache1 <= A_cache1 + 1;
	else if ((curr_state == S_CALC_MULT) || (curr_state == S_CALC_CONV))
		A_cache1 <= (address_start[31:02] - 1024);
	else if ((curr_state == S_WRITE_SRAM) && (flag_write_sram))
		A_cache1 <= A_cache1 + 1;
	else
		A_cache1 <= A_cache1;
end
// A_cache2
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		A_cache2 <= 0;
	else if (curr_state == S_CACHE) begin
		if(rvalid_m_inf[1])
			A_cache2 <= A_cache2 + 1;
		else
			A_cache2 <= A_cache2;
	end
	else if (curr_state == S_READ_INST)
			A_cache2 <= (rdata_m_inf[47:34] - 2560); // (address_start[63:32] - 10240)/4
	else if ((curr_state == S_READ_MULT) || (curr_state == S_READ_CONV))
			A_cache2 <= A_cache2 + 1;
	else
		A_cache2 <= A_cache2;
end
// D_cache1
always@(*) begin
	if (curr_state == S_WRITE_SRAM)
		D_cache1 = Q_cal_3;
	else
		D_cache1 = rdata_m_inf[31:00];
end
// D_cache2
always@(*) begin
	D_cache2 = rdata_m_inf[63:32];
end
// WEN_cal_1
always@(*) begin
	if(curr_state == S_CACHE)
		WEN_cal_1 = 1'b0;
	else if ((curr_state == S_READ_MULT) || (curr_state == S_READ_CONV)) begin
		if ((need_dram_1) && (rvalid_m_inf[0]))
			WEN_cal_1 = 1'b0;
		else if ((need_dram_1 == 0) && (flag_read_mult) && (counter_dram_1[8] == 0))
			WEN_cal_1 = 1'b0;
		else
			WEN_cal_1 = 1'b1;
	end
	else
		WEN_cal_1 = 1'b1;
end
// WEN_cal_2
always@(*) begin
	if(curr_state == S_CACHE)
		WEN_cal_2 = 1'b0;
	else if ((curr_state == S_READ_MULT) || (curr_state == S_READ_CONV)) begin
		if ((need_dram_read) && (rvalid_m_inf[1]))
			WEN_cal_2 = 1'b0;
		else if ((need_dram_read == 0) && (flag_read_mult) && (counter_dram_read[8] == 0))
			WEN_cal_2 = 1'b0;
		else
			WEN_cal_2 = 1'b1;
	end
	else
		WEN_cal_2 = 1'b1;
end
// WEN_cal_3
always@(*) begin
	if(curr_state == S_CALC_MULT)
		WEN_cal_3 = 1'b0;
	else if(curr_state == S_CALC_CONV)
		WEN_cal_3 = 1'b0;
	else
		WEN_cal_3 = 1'b1;
end
// A_cal_1
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		A_cal_1 <= 0;
	else if (curr_state == S_CACHE)
		A_cal_1 <= A_cal_1 + 1;
	else if (curr_state == S_READ_INST)
		A_cal_1 <= 19;
	else if ((curr_state == S_READ_MULT) || (curr_state == S_READ_CONV)) begin
		if (A_cal_1 == 304)
			A_cal_1 <= 19;
		else if ((need_dram_1) && (rlast_m_inf[0]))
			A_cal_1 <= A_cal_1 + 3;
		else if ((need_dram_1) && (rvalid_m_inf[0]))
			A_cal_1 <= A_cal_1 + 1;
		else if ((need_dram_1 == 0) && (flag_read_mult)) begin// read_SRAM
			if (counter_dram_1[3:0] == 15)
				A_cal_1 <= A_cal_1 + 3;
			else
				A_cal_1 <= A_cal_1 + 1;
		end
		else
			A_cal_1 <= A_cal_1;
	end
	else if (curr_state == S_CALC_MULT)
		A_cal_1 <= 18*counter_mult_row + 1 + counter_mult_1;
	else if (curr_state == S_CALC_CONV)
		A_cal_1 <= 18*counter_mult_row  + counter_mult_1 + counter_sum_conv[3:0];
	else
		A_cal_1 <= A_cal_1;
end
// A_cal_2
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		A_cal_2 <= 0;
	else if (curr_state == S_READ_INST)
		A_cal_2 <= 0;
	else if ((curr_state == S_READ_MULT)|| (curr_state == S_READ_CONV)) begin
		if ((need_dram_read) && (rvalid_m_inf[1]))
			A_cal_2 <= A_cal_2 + 1;
		else if ((need_dram_read == 0) && (flag_read_mult)) // read_SRAM
			A_cal_2 <= A_cal_2 + 1;
		else
			A_cal_2 <= A_cal_2;
	end
	else if ((curr_state == S_CALC_MULT)|| (curr_state == S_CALC_CONV))
		A_cal_2 <= counter_mult_read + counter_mult_col;
	else
		A_cal_2 <= A_cal_2;
end
// A_cal_3
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		A_cal_3 <= 0;
	else if (curr_state == S_CALC_MULT)
		A_cal_3 <= counter_sum_mult1;
	else if (curr_state == S_CALC_CONV)
		A_cal_3 <= counter_sum_conv2;
	else if ((curr_state == S_WRITE_DRAM) && (wvalid_delay1))
		A_cal_3 <= A_cal_3 + 1;
	else if (curr_state == S_WRITE_SRAM)
		A_cal_3 <= A_cal_3 + 1;
	else
		A_cal_3 <= A_cal_3;
end
// D_cal_1
always@(*) begin
	if (curr_state == S_CACHE)
		D_cal_1 = 0;
	else if (need_dram_1)
		D_cal_1 = rdata_m_inf[31:00];
	else
		D_cal_1 = Q_cache1;
end
// D_cal_2
always@(*) begin
	if (curr_state == S_CACHE)
		D_cal_2 = 0;
	else if (need_dram_read)
		D_cal_2 = rdata_m_inf[63:32];
	else
		D_cal_2 = Q_cache2;
end
// D_cal_3
always@(*) begin
	if ((curr_state == S_CALC_MULT) && (counter_sum_mult2[0] == 0))
		D_cal_3 = sum_mult0;
	else if ((curr_state == S_CALC_MULT) && (counter_sum_mult2[0] == 1))
		D_cal_3 = sum_mult1;
	else if ((curr_state == S_CALC_CONV) && (counter_sum_conv3[0] == 0))
		D_cal_3 = sum_mult0;
	else if ((curr_state == S_CALC_CONV) && (counter_sum_conv3[0] == 1))
		D_cal_3 = sum_mult1;
	else
		D_cal_3 = 0;
end
// awaddr_m_inf
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		awaddr_m_inf <= 0;
	else if (curr_state == S_WRITE_DRAM)
		awaddr_m_inf <= address_start[31:00] + counter_dram_1;
	else
		awaddr_m_inf <= awaddr_m_inf;
end
// awvalid_m_inf
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		awvalid_m_inf <= 0;
	else if (awready_m_inf == 1)
		awvalid_m_inf <= 0;
	else if (bready_m_inf == 1)
		awvalid_m_inf <= 0;
	else if (counter_dram_1 >= 'h400)
		awvalid_m_inf <= 0;
	else if (curr_state == S_WRITE_DRAM)
		awvalid_m_inf <= 1;
	else
		awvalid_m_inf <= awvalid_m_inf;
end
// wdata_m_inf
always @(*) begin
	wdata_m_inf = Q_cal_3;
end
// wlast_m_inf
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		wlast_m_inf <= 0;
	else if (counter_write_data[3:0] == 14)
		wlast_m_inf <= 1;
	else
		wlast_m_inf <= 0;
end
// wvalid_m_inf
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		wvalid_m_inf <= 0;
	else if (awready_m_inf == 1)
		wvalid_m_inf <= 1;
	else if (wlast_m_inf == 1)
		wvalid_m_inf <= 0;
	else
		wvalid_m_inf <= wvalid_m_inf;
end
// wvalid_delay1
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		wvalid_delay1 <= 0;
	else if ((counter_write_data[3:0] == 14) || (counter_write_data[3:0] == 15))
		wvalid_delay1 <= 0;
	else if (wvalid_m_inf == 1)
		wvalid_delay1 <= 1;
	else
		wvalid_delay1 <= wvalid_delay1;
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
	else if (curr_state == S_IDLE)
		araddr_m_inf <= araddr_m_inf;
	else if (curr_state == S_READ_INST) begin
		araddr_m_inf[63:32] <= PADDR;
		araddr_m_inf[31:00] <= 0;
	end
	else if ((curr_state == S_CACHE) || (curr_state == S_READ_MULT) || (curr_state == S_READ_CONV)) begin
		araddr_m_inf[63:32] <= address_start[63:32] + counter_dram_read;
		araddr_m_inf[31:00] <= address_start[31:00] + counter_dram_1;
	end
	else
		araddr_m_inf <= araddr_m_inf;
end
// arlen_m_inf
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		arlen_m_inf <= 0;
	else if (curr_state == S_READ_INST)
		arlen_m_inf <= 0;
	else if (curr_state == S_READ_CONV)
		arlen_m_inf <= {4'b1000,4'b1111};
	else
		arlen_m_inf <= {4'b1111,4'b1111};
end
// arvalid_m_inf[1]
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		arvalid_m_inf[1] <= 0;
	else if (curr_state == S_IDLE)
		arvalid_m_inf[1] <= 0;
	else if (curr_state == S_CACHE) begin
		if (arready_m_inf[1] == 1)
			arvalid_m_inf[1] <= 0;
		else if (wait_dram_read == 1)
			arvalid_m_inf[1] <= 0;
		else if (counter_dram_read >= 'h800)
			arvalid_m_inf[1] <= 0;
		else
			arvalid_m_inf[1] <= 1;
	end
	else if (curr_state == S_READ_INST) begin
		if (arready_m_inf[1] == 1)
			arvalid_m_inf[1] <= 0;
		else if (wait_dram_read == 1)
			arvalid_m_inf[1] <= 0;
		else
			arvalid_m_inf[1] <= 1;
	end
	else if (curr_state == S_READ_MULT) begin
		if (need_dram_read == 0)
			arvalid_m_inf[1] <= 0;
		else if (arready_m_inf[1] == 1)
			arvalid_m_inf[1] <= 0;
		else if (wait_dram_read == 1)
			arvalid_m_inf[1] <= 0;
		else if (counter_dram_read >= 'h400)
			arvalid_m_inf[1] <= 0;
		else
			arvalid_m_inf[1] <= 1;
	end
	else if (curr_state == S_READ_CONV) begin
		if (need_dram_read == 0)
			arvalid_m_inf[1] <= 0;
		else if (arready_m_inf[1] == 1)
			arvalid_m_inf[1] <= 0;
		else if (wait_dram_read == 1)
			arvalid_m_inf[1] <= 0;
		else if (counter_dram_read >= 'h40)
			arvalid_m_inf[1] <= 0;
		else
			arvalid_m_inf[1] <= 1;
	end
	else
		arvalid_m_inf[1] <= arvalid_m_inf[1];
end
// arvalid_m_inf[0]
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		arvalid_m_inf[0] <= 0;
	else if (curr_state == S_IDLE)
		arvalid_m_inf[0] <= 0;
	else if (curr_state == S_CACHE) begin
		if (arready_m_inf[0] == 1)
			arvalid_m_inf[0] <= 0;
		else if (wait_dram_1 == 1)
			arvalid_m_inf[0] <= 0;
		else if (counter_dram_1 >= 'h800)
			arvalid_m_inf[0] <= 0;
		else
			arvalid_m_inf[0] <= 1;
	end
	else if ((curr_state == S_READ_MULT) || (curr_state == S_READ_CONV)) begin
		if (need_dram_1 == 0)
			arvalid_m_inf[0] <= 0;
		else if (arready_m_inf[0] == 1)
			arvalid_m_inf[0] <= 0;
		else if (wait_dram_1 == 1)
			arvalid_m_inf[0] <= 0;
		else if (counter_dram_1 >= 'h400)
			arvalid_m_inf[0] <= 0;
		else
			arvalid_m_inf[0] <= 1;
	end
	else
		arvalid_m_inf[0] <= arvalid_m_inf[0];
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
// rst_flag
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		rst_flag <= 0;
	else if (curr_state == S_CACHE)
		rst_flag <= 1;
	else
		rst_flag <= rst_flag;
end
// address_start
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		address_start <= 0;
	else if (curr_state == S_IDLE) begin
		address_start[63:32] <= 32'h00002800;
		address_start[31:00] <= 32'h00001000;
	end
	else if (curr_state == S_READ_INST) begin
		address_start[63:32] <= {16'b0,rdata_m_inf[47:34],2'b00};
		address_start[31:00] <= {16'b0,rdata_m_inf[63:50],2'b00};
	end
	else
		address_start <= address_start;
end
// need_dram_read
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		need_dram_read <= 0;
	else if (curr_state == S_READ_INST) begin
		if ({rdata_m_inf[47:34],2'b00} < 16'h2800)
			need_dram_read <= 1;
		else
			need_dram_read <= 0;
	end
	else
		need_dram_read <= need_dram_read;
end
// need_dram_1
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		need_dram_1 <= 0;
	else if (curr_state == S_READ_INST) begin
		if ({rdata_m_inf[63:50],2'b00} > 16'h1400)
			need_dram_1 <= 1;
		else
			need_dram_1 <= 0;
	end
	else
		need_dram_1 <= need_dram_1;
end
// op
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		op <= 0;
	else if (curr_state == S_READ_INST)
		op <= rdata_m_inf[33:32];
	else
		op <= op;
end
// wait_dram_read
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		wait_dram_read <= 0;
	else if (arvalid_m_inf[1] == 1)
		wait_dram_read <= 1;
	else if (rlast_m_inf[1] == 1)
		wait_dram_read <= 0;
	else
		wait_dram_read <= wait_dram_read;
end
// wait_dram_1
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		wait_dram_1 <= 0;
	else if (arvalid_m_inf[0] == 1)
		wait_dram_1 <= 1;
	else if (rlast_m_inf[0] == 1)
		wait_dram_1 <= 0;
	else
		wait_dram_1 <= wait_dram_1;
end
// counter_dram_read
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		counter_dram_read <= 0;
	else if ((curr_state == S_IDLE) || (curr_state == S_CALC_MULT) || (curr_state == S_CALC_CONV))
		counter_dram_read <= 0;
	else if (curr_state == S_CACHE) begin
		if (rlast_m_inf[1] == 1)
			counter_dram_read <= counter_dram_read + 4*16;
		else
			counter_dram_read <= counter_dram_read;
	end
	else if ((curr_state == S_READ_MULT) || (curr_state == S_READ_CONV) || (curr_state == S_WRITE_DRAM)) begin
		if ((need_dram_read) && rlast_m_inf[1] == 1)
			counter_dram_read <= counter_dram_read + 4*16;
		else if ((need_dram_read == 0) && (flag_read_mult) && (counter_dram_read < 256))
			counter_dram_read <= counter_dram_read + 1;
		else
			counter_dram_read <= counter_dram_read;
	end
	else if (curr_state == S_DONE)
		counter_dram_read <= 0;
	else
		counter_dram_read <= counter_dram_read;
end
// counter_dram_1
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		counter_dram_1 <= 0;
	else if ((curr_state == S_IDLE) || (curr_state == S_CALC_MULT) || (curr_state == S_CALC_CONV))
		counter_dram_1 <= 0;
	else if (curr_state == S_CACHE) begin
		if (rlast_m_inf[0] == 1)
			counter_dram_1 <= counter_dram_1 + 4*16;
		else
			counter_dram_1 <= counter_dram_1;
	end
	else if (curr_state == S_READ_MULT) begin
		if ((need_dram_1) && (rlast_m_inf[0] == 1))
			counter_dram_1 <= counter_dram_1 + 4*16;
		else if ((need_dram_1 == 0) && (flag_read_mult) && (counter_dram_1 < 256))
			counter_dram_1 <= counter_dram_1 + 1;
		else
			counter_dram_1 <= counter_dram_1;
	end
	else if (curr_state == S_READ_CONV) begin
		if ((need_dram_1) && (rlast_m_inf[0] == 1))
			counter_dram_1 <= counter_dram_1 + 4*16;
		else if ((need_dram_1 == 0) && (flag_read_mult) && (counter_dram_1 < 324))
			counter_dram_1 <= counter_dram_1 + 1;
		else
			counter_dram_1 <= counter_dram_1;
	end
	else if (curr_state == S_WRITE_DRAM) begin
		if (bvalid_m_inf[0] == 1)
			counter_dram_1 <= counter_dram_1 + 4*16;
		else
			counter_dram_1 <= counter_dram_1;
	end
	else if (curr_state == S_DONE)
		counter_dram_1 <= 0;
	else
		counter_dram_1 <= counter_dram_1;
end
// counter_mult_read
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		counter_mult_read <= 0;
	else if (curr_state == S_CALC_MULT)
		counter_mult_read <= counter_mult_read + 16;
	else if (curr_state == S_CALC_CONV) begin
		if (counter_mult_read == 8)
			counter_mult_read <= 0;
		else
			counter_mult_read <= counter_mult_read + 1;
	end
	else if (curr_state == S_DONE)
		counter_mult_read <= 0;
	else
		counter_mult_read <= counter_mult_read;
end
// counter_mult_1
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		counter_mult_1 <= 0;
	else if (curr_state == S_CALC_MULT) begin
		if (counter_mult_1 == 15)
			counter_mult_1 <= 0;
		else
			counter_mult_1 <= counter_mult_1 + 1;
	end
	else if (curr_state == S_CALC_CONV) begin
		if (counter_mult_1 == 38)
			counter_mult_1 <= 0;
		else if ((counter_mult_1 == 2) || (counter_mult_1 == 20))
			counter_mult_1 <= counter_mult_1 + 16;
		else
			counter_mult_1 <= counter_mult_1 + 1;
	end
	else if (curr_state == S_DONE)
		counter_mult_1 <= 0;
	else
		counter_mult_1 <= counter_mult_1;
end
// counter_mult
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		counter_mult <= 0;
	else if (curr_state == S_CALC_MULT)
		counter_mult <= counter_mult + 1;
	else if (curr_state == S_DONE)
		counter_mult <= 0;
	else
		counter_mult <= counter_mult;
end
// counter_mult_row
always @(*) begin
	if (curr_state == S_CALC_MULT)
		counter_mult_row = counter_mult[11:8] + 1;
	else
		counter_mult_row = counter_sum_conv[7:4];
end
// counter_mult_col
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		counter_mult_col <= 0;
	else if (counter_mult_1 == 15)
		counter_mult_col <= counter_mult_col + 1;
	else if (curr_state == S_DONE)
		counter_mult_col <= 0;
	else
		counter_mult_col <= counter_mult_col;
end
// counter_sum_mult
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		counter_sum_mult <= 0;
	else
		counter_sum_mult <= counter_mult[11:4];
end
// counter_sum_mult1
// counter_sum_mult2
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		counter_sum_mult1 <= 0;
		counter_sum_mult2 <= 0;
	end
	else begin
		counter_sum_mult1 <= counter_sum_mult;
		counter_sum_mult2 <= counter_sum_mult1;
	end
end
// counter_sum_conv
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		counter_sum_conv <= 0;
	else if (counter_mult_1 == 38)
		counter_sum_conv <= counter_sum_conv + 1;
	else if (curr_state == S_DONE)
		counter_sum_conv <= 0;
	else
		counter_sum_conv <= counter_sum_conv;
end
// counter_sum_conv1
// counter_sum_conv2
// counter_sum_conv3
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		counter_sum_conv1 <= 0;
		counter_sum_conv2 <= 0;
		counter_sum_conv3 <= 0;
	end
	else begin
		counter_sum_conv1 <= counter_sum_conv;
		counter_sum_conv2 <= counter_sum_conv1;
		counter_sum_conv3 <= counter_sum_conv2;
	end
end
// counter_write_data
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		counter_write_data <= 0;
	else if (wready_m_inf)
		counter_write_data <= counter_write_data + 1;
	else if ((curr_state == S_WRITE_SRAM) && (flag_write_sram))
		counter_write_data <= counter_write_data + 1;
	else if (curr_state == S_DONE)
		counter_write_data <= 0;
	else
		counter_write_data <= counter_write_data;
end
// flag_read_mult
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		flag_read_mult <= 0;
	else if ((curr_state == S_READ_MULT) || (curr_state == S_READ_CONV))
		flag_read_mult <= 1;
	else
		flag_read_mult <= 0;
end
// flag_calc_mult
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		flag_calc_mult <= 0;
	else if ((curr_state == S_CALC_MULT) || (curr_state == S_CALC_CONV))
		flag_calc_mult <= 1;
	else
		flag_calc_mult <= 0;
end
// flag_calc_mult1
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		flag_calc_mult1 <= 0;
	else
		flag_calc_mult1 <= flag_calc_mult;
end
// sum_mult0
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		sum_mult0 <= 0;
	else if ((curr_state == S_CALC_MULT) && (flag_calc_mult1 == 1) && (counter_sum_mult1[0] == 0))
			sum_mult0 <= sum_mult0 + Q_cal_1 * Q_cal_2;
	else if ((curr_state == S_CALC_CONV) && (flag_calc_mult1 == 1) && (counter_sum_conv2[0] == 0))
			sum_mult0 <= sum_mult0 + Q_cal_1 * Q_cal_2;
	else
		sum_mult0 <= 0;
end
// sum_mult1
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		sum_mult1 <= 0;
	else if ((curr_state == S_CALC_MULT) && (flag_calc_mult1 == 1) && (counter_sum_mult1[0] == 1))
			sum_mult1 <= sum_mult1 + Q_cal_1 * Q_cal_2;
	else if ((curr_state == S_CALC_CONV) && (flag_calc_mult1 == 1) && (counter_sum_conv2[0] == 1))
			sum_mult1 <= sum_mult1 + Q_cal_1 * Q_cal_2;
	else
		sum_mult1 <= 0;
end
// flag_write_sram
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		flag_write_sram <= 0;
	else if (curr_state == S_WRITE_SRAM)
		flag_write_sram <= 1;
	else
		flag_write_sram <= 0;
end
// flag_write_sram1
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		flag_write_sram1 <= 0;
	else
		flag_write_sram1 <= flag_write_sram;
end

//PRDATA_temp
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		PRDATA_temp <= 0;
	else if (curr_state == S_READ_INST)
		PRDATA_temp <= rdata_m_inf[63:32];
	else
		PRDATA_temp <= PRDATA_temp;
end
//PRDATA
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		PRDATA <= 0;
	else if (curr_state == S_DONE)
		PRDATA <= PRDATA_temp;
	else
		PRDATA <= 0;
end
//PREADY
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		PREADY <= 0;
	else if (curr_state == S_DONE)
		PREADY <= 1;
	else
		PREADY <= 0;
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
		if (rst_flag == 0)
			next_state = S_CACHE;
		else if (PENABLE)
			next_state = S_READ_INST;
		else
			next_state = S_IDLE;
	end
	S_READ_INST: begin // 1
		if (rlast_m_inf[1] == 1) begin
			if (rdata_m_inf[33:32] == MULT)
				next_state = S_READ_MULT;
			else
				next_state = S_READ_CONV;
		end
		else
			next_state = S_READ_INST;
	end
	S_READ_MULT: begin // 2
		if ((need_dram_read) && (need_dram_1) && (counter_dram_read == 'h400) && (counter_dram_1 == 'h400))
			next_state = S_CALC_MULT;
		else if ((need_dram_read) && (need_dram_1 == 0) && (counter_dram_read == 'h400) && (counter_dram_1 == 'h100))
			next_state = S_CALC_MULT;
		else if ((need_dram_read == 0) && (need_dram_1) && (counter_dram_1 == 'h400) && (A_cal_2 == 255))
			next_state = S_CALC_MULT;
		else if ((need_dram_read == 0) && (need_dram_1 == 0) && (A_cal_2 == 255))
			next_state = S_CALC_MULT;
		else
			next_state = S_READ_MULT;
	end
	S_READ_CONV: begin // 3
		if ((need_dram_read) && (need_dram_1) && (counter_dram_read >= 'h40) && (counter_dram_1 == 'h400))
			next_state = S_CALC_CONV;
		else if ((need_dram_read) && (need_dram_1 == 0)&& (counter_dram_read == 'h40) && (counter_dram_1 == 'h100))
			next_state = S_CALC_CONV;
		else if ((need_dram_read == 0) && (need_dram_1) && (counter_dram_1 == 'h400) && (A_cal_2 == 255))
			next_state = S_CALC_CONV;
		else if ((need_dram_read == 0) && (need_dram_1 == 0) && (A_cal_2 == 255))
			next_state = S_CALC_CONV;
		else
			next_state = S_READ_CONV;
	end
	S_CALC_MULT: begin // 4
		if ((counter_sum_mult1 == 0) && (counter_sum_mult2 == 255))
			next_state = S_WRITE_DRAM;
		else
			next_state = S_CALC_MULT;
	end
	S_CALC_CONV: begin // 5
		if ((counter_sum_conv2 == 0) && (counter_sum_conv3 == 255))
			next_state = S_WRITE_DRAM;
		else
			next_state = S_CALC_CONV;
	end
	S_WRITE_DRAM: begin // 6
		if ((address_start[31:00] < 16'h1800) && (counter_dram_1 >= 'h400))
			next_state = S_WRITE_SRAM;
		else if ((counter_dram_1 >= 'h400))
			next_state = S_DONE;
		else
			next_state = S_WRITE_DRAM;
	end
	S_WRITE_SRAM: begin // 7
		if ((counter_write_data == (1535 - address_start[31:02])) || (counter_write_data == 255))
			next_state = S_DONE;
		else
			next_state = S_WRITE_SRAM;
	end
	S_DONE: next_state = S_IDLE;
	S_CACHE: begin // 9
		if((counter_dram_read == 2048) && (counter_dram_1 == 2048))
			next_state = S_IDLE;
		else
			next_state = S_CACHE;
	end
	default: next_state = curr_state;
	endcase
end

endmodule

