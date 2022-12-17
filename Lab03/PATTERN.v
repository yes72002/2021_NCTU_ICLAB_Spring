//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : PATTERN.v
//   Module Name : PATTERN
//   Release version : v1.0
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
`ifdef RTL
	`timescale 1ns/10ps
	`include "SD.v"
    `define CYCLE_TIME 7.0
`endif
`ifdef GATE
	`timescale 1ns/10ps
	`include "SD_SYN.v"
    `define CYCLE_TIME 7.0
`endif
// `timescale 1ns/10ps
// `include "SD.v"
// `define CYCLE_TIME 7.0

module PATTERN(
    // Output signals
	clk,
    rst_n,
	in_valid,
	in,
    // Input signals
    out_valid,
    out
);

//================================================================ 
//   INPUT AND OUTPUT DECLARATION
//================================================================
output reg clk, rst_n, in_valid;
output reg [3:0] in;
input out_valid;
input [3:0] out;

//================================================================
// parameters & integer
//================================================================
real CYCLE = 7.0;
integer PATNUM;
integer total_latency;
integer patcount;
integer file_iclab041;
integer cut_iclab041;
integer lat,x;
integer i,j;
integer out_cycle,gap;
//================================================================
// wire & registers 
//================================================================
reg	[3:0] ANS;
//================================================================
// clock
//================================================================
always	#(`CYCLE_TIME/2.0) clk = ~clk;
initial	clk = 0;
//================================================================
// initial
//================================================================
initial begin
	file_iclab041 = $fopen("../00_TESTBED/xxxiclab041xxx.txt", "r");
	// file_iclab041 = $fopen("../00_TESTBED/pat_yen.txt", "r");
	// file_iclab041 = $fopen("xxxiclab041xxx.txt", "r");
	cut_iclab041 = $fscanf(file_iclab041,"%d\n",PATNUM);
	
	if (file_iclab041 == 0)begin
		$display ("Error in opening the files");
		$finish;
	end
	
	// $display("PASS PATTERN NO.%4d\n\n\n\n\n\n,", PATNUM);
	
	rst_n = 1;
	in_valid = 0;
	in = 4'bx;
	// golden_out = 0;

	force clk = 0;
	total_latency = 0;
	
	reset_signal_task;//3
	// total_cycles = 0;
	// total_pat = 0;

    @(negedge clk);

	for (patcount=0; patcount < PATNUM; patcount = patcount + 1) begin
		reset_ornot_task;//4
		input_task;
		overlap_task;
		latency_ans;//6
		check_ans;//7,8
		delay_task;
	end
	#(1000);
	YOU_PASS_task;
	$finish;
end
//================================================================
// SPEC 3 task
// SPEC 3 FAIL!
// 3. The reset signal (rst_n) would be given only once at the beginning of simulation. All output 
//    signals should be reset after the reset signal is asserted.
//================================================================
task reset_signal_task; begin 
    #(1.0); rst_n = 0; 
    #(2.0);
    if((out_valid!==1'b0)||(out!==1'b0)) begin
		// $display("out_valid=%d,out=%d",out_valid,out);
        // $display("***************************************************************");
		// $display("*                      SPEC 3 FAIL!                           *");
        // $display("*   Output signal should be 0 after initial RESET at%8t  *",$time);
        // $display("***************************************************************");
		$display("  SPEC 3 FAIL!  ");
		$finish;
    end
	#(2.0);  rst_n = 1;
	#(3.0); release clk;
end endtask
// SPEC 4 FAIL!
// 4. The out should be reset whenever your out_valid isn’t high.
task reset_ornot_task; begin
	if((out_valid==0)&&(out!=0)) begin
		// $display ("************************************************************");
		// $display ("*                     SPEC 4 FAIL!                         *");
		// $display ("*   The out should be reset after out_valid is low.  *");
		// $display ("************************************************************");	
		$display("  SPEC 4 FAIL!  ");
		repeat(2)@(negedge clk);
		$finish;		
	end
end endtask

task delay_task ; begin
	gap = $urandom_range(2, 4);
	repeat(gap)@(negedge clk);
end endtask
//================================================================
// input task
//================================================================
task input_task ; begin
   	for(i = 0; i < 81; i = i + 1)begin
		@(negedge clk);
		in_valid = 1;
		cut_iclab041 = $fscanf(file_iclab041,"%d\n",in);
	end
	@(negedge clk);
	in_valid = 0;
	in = 4'bx;
end endtask
// SPEC 5 FAIL!
// 5. The out_valid should not overlap with in_valid when in_valid hasn’t been pulled down yet.
task overlap_task; begin
	if((out_valid==1)&&(in_valid==1)) begin
		// $display ("************************************************************");
		// $display ("*                     SPEC 5 FAIL!                         *");
		// $display ("*      The out_valid should not overlap with in_valid      *");
		// $display ("************************************************************");	
		$display("  SPEC 5 FAIL!  ");
		repeat(2)@(negedge clk);
		$finish;		
	end
end endtask
// SPEC 6 FAIL!
// 6. The execution latency is limited in 300 cycles. The latency is the clock cycles between the falling 
//    edge of the last cycle of in_valid and the rising edge of the out_valid.
task latency_ans; begin 
    lat=-1;
    while(out_valid!==1) begin
	lat=lat+1;
		if(lat==300)begin
		// if(lat==50)begin
				// $display ("*********************************************************");
				// $display ("*                     SPEC 6 FAIL!                      *");
				// $display ("*       The execution latency are over 300 cycles.      *");
				// $display ("*********************************************************");
				$display("  SPEC 6 FAIL!  ");
			repeat(2)@(negedge clk);
			$finish;
		end
	@(negedge clk);
    end
	total_latency = total_latency + lat;
end endtask

// SPEC 7 FAIL!
// 7. When out_valid is pulled up and there’re no solutions for the grid, out should be 4’d10, and 
//    out_valid is limited to be high for only 1 cycle.

// SPEC 8 FAIL!
// 8. When out_valid is pulled up and there exists a solution for the grid, out should be correct, and
//    out_valid is limited to be high for 15 cycles.
task check_ans; begin
	x=1;
	cut_iclab041 = $fscanf(file_iclab041,"%d\n",out_cycle);
	if(out_cycle == 1) begin
		while(out_valid===1'b1) begin
			if(x==1) begin
				cut_iclab041 = $fscanf(file_iclab041,"%d\n", ANS);
				if( ANS !== out ) begin
					// $display("*********************************************************");
					// $display("*                     SPEC 7 FAIL!                      *");		
					// $display("*                     PATTERN NO.%4d 	                *",patcount);
					// $display("*       Ans : %d,  Your output : %d  at %8t      *",ANS,out,$time);
					// $display("*********************************************************");
					$display("  SPEC 7 FAIL!  ");
					$finish; 
				end
				
				else begin
					// $display("*              PATTERN NO.%4d  passed	                  *",patcount);
					$display("\033[0;34mPASS PATTERN NO.%4d,\033[m \033[0;32mexecution cycle : %3d\033[m",patcount ,lat);
				end
			end
			else begin
				// $display("*********************************************************");
				// $display("*                     SPEC 7 FAIL!                      *");
				// $display("*       Out_valid is limited to high only 1 cycle       *");
				// $display("*********************************************************");
				$display("  SPEC 7 FAIL!  ");
				repeat(2) @(negedge clk);
				$finish;
			end	
		@(negedge clk);	
		x=x+1;	
		end	
	end
	else if (out_cycle == 15) begin
		while(out_valid===1'b1) begin
			if(x <= 16) begin
				// for (i = 0; i < 15; i = i + 1) begin
					cut_iclab041 = $fscanf(file_iclab041,"%d\n", ANS);
					if( ANS !== out ) begin
						// $display("*********************************************************");
						// $display("*                     SPEC 8 FAIL!                    *");		
						// $display("*                     PATTERN NO.%4d, cycle %d      *",patcount,x);
						// $display("*       Ans : %d,  Your output : %d  at %8t      *",ANS,out,$time);
						// $display("*********************************************************");
						$display("  SPEC 8 FAIL!  ");
						$finish; 
					end
					// else begin
						// $display("*              PATTERN NO.%4d  passed	                  *",patcount);
						// $display("\033[0;34mPASS PATTERN NO.%4d,\033[m \033[0;32mexecution cycle : %3d\033[m",patcount ,lat);
					// end
				// end
				// $display("\033[0;34mPASS PATTERN NO.%4d,\033[m \033[0;32mexecution cycle : %3d\033[m",patcount ,lat);
			end
			else if(x > 16) begin
				// $display("*********************************************************");
				// $display("*                     SPEC 8 FAIL!                    *");
				// $display("*       Out_valid is limited to high for 15 cycles      *");
				// $display("*********************************************************");
				$display("  SPEC 8 FAIL!  ");
				repeat(2) @(negedge clk);
				$finish;
			end
			
		@(negedge clk);	
		x=x+1;	
		end
		if(x < 16) begin
			// $display("*********************************************************");
			// $display("*                     SPEC 8 FAIL!                    *");
			// $display("*       Out_valid is shorter than 15 cycles             *");
			// $display("*********************************************************");
			$display("  SPEC 8 FAIL!  ");
			repeat(2) @(negedge clk);
			$finish;
		end
		$display("\033[0;34mPASS PATTERN NO.%4d,\033[m \033[0;32mexecution cycle : %3d\033[m",patcount ,lat);
	end
	else begin
		$display("pattern out cycle is wrong");
		$finish; 
	end
end endtask


task YOU_PASS_task;begin
	  $display ("-------------------------------------------------------------------");
	  $display ("                         Congratulations!                          ");
	  $display ("                  You have passed all patterns!                    ");
	  $display ("                 Your execution cycles = %5d cycles                ", total_latency);
	  $display ("                    Your clock period = %.1f ns                    ", CYCLE);
	  $display ("                    Your total latency = %.1f ns                   ", total_latency*CYCLE);
	  $display ("-------------------------------------------------------------------");    
	  $finish;
end endtask
endmodule
