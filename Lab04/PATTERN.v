`ifdef RTL
	`timescale 1ns/10ps
	`include "NN.v"  
	// `include "Lab04_NN.v"  
	`define CYCLE_TIME 20.0
`endif
`ifdef GATE
	`timescale 1ns/10ps
	`include "NN_SYN.v"
	`define CYCLE_TIME 20.0
`endif

// PATTERN_MING

//synopsys translate_off
`include "DW_fp_mult.v"
`include "DW_fp_addsub.v"
//synopsys translate_on
module PATTERN(
	// Output signals
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
	// Input signals
	out_valid,
	out
);

//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch = 2;

//================================================================
//   INPUT AND OUTPUT DECLARATION                         
//================================================================
input out_valid;
input [inst_sig_width+inst_exp_width:0] out;
output reg clk, rst_n, in_valid_d, in_valid_t, in_valid_w1, in_valid_w2;
output reg [inst_sig_width+inst_exp_width:0] data_point, target;
output reg [inst_sig_width+inst_exp_width:0] weight1, weight2;

//================================================================
// integer
//================================================================
real CYCLE = `CYCLE_TIME;
real delay_time = 0.01;
integer PATNUM = 10;
integer epoch = 25;
integer iteration = 100;
// integer learn = 32'b00110111000000000000000000000000;// learning rate
integer learn = 32'h3A83126F;// learning rate
integer seed = 32;
integer i, j, k, lat, total_latency;
integer patcount, epocount, itercount;
integer pat_delay;
integer weight1_store[11:0], weight2_store[2:0];
integer data_store[3:0], total_data_store[399:0], target_store, total_target_store[99:0];
integer ans, error, gradient[2:0], hidden_store[2:0], hidden_back_store[2:0];
integer file_data, file_target, file_W0, file_W1;
integer cnt_data, cnt_target, cnt_W0, cnt_W1;

//================================================================
// wire & registers 
//================================================================
reg op;
reg [inst_sig_width+inst_exp_width:0] mult_a, mult_b, addsub_a, addsub_b;
wire [inst_sig_width+inst_exp_width:0] mult_out, addsub_out;

//================================================================
// clock
//================================================================
always	#(CYCLE/2.0) clk = ~clk;
initial	clk = 0;

//================================================================
// initial
//================================================================
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M0 (.a(mult_a), .b(mult_b), .rnd(3'b000), .z(mult_out));
DW_fp_addsub #(inst_sig_width, inst_exp_width, inst_ieee_compliance) AS0 (.a(addsub_a), .b(addsub_b), .rnd(3'b000), .op(op), .z(addsub_out));

initial begin
	file_W0 = $fopen("../00_TESTBED/W0_MING.txt", "r");
	file_W1 = $fopen("../00_TESTBED/W1_MING.txt", "r");
	file_data =  $fopen("../00_TESTBED/data_MING.txt", "r");
	file_target = $fopen("../00_TESTBED/target_MING.txt", "r");
	if ((file_W0 == 0) || (file_W1 == 0) || (file_data == 0) || (file_target == 0)) begin
		$display ("Error in opening the files");
		$finish;
	end	
	
    rst_n = 1;
	in_valid_d = 0;
	in_valid_t = 0;
	in_valid_w1 = 0;
	in_valid_w2 = 0;
    data_point = 32'dx;
	target = 32'dx;
	weight1 = 32'dx;
	weight2 = 32'dx;

	force clk = 0;

	total_latency = 0;
	reset_signal_task;
	repeat(2)@(negedge clk);
	
	for(patcount = 0; patcount < PATNUM; patcount = patcount + 1) begin
		input_weight_task;
		repeat(2)@(negedge clk);
		for(epocount = 0; epocount < epoch; epocount = epocount + 1) begin
			for(itercount = 0; itercount < iteration; itercount = itercount + 1) begin
				input_data_task;
				calculate_ans;
				wait_out_valid;
				check_ans;
			end			
		end
	end
	
	pass;	
	$fclose(file_W0);
	$fclose(file_W1);
	$fclose(file_data);
	$fclose(file_target);
end

//================================================================
// task
//================================================================
task reset_signal_task; begin 
    #(0.5); rst_n = 0;	
	#(2.0);
	if((out_valid !== 0) || (out !== 32'b0)) begin
		$display("************************************************************");
		$display("    output signal should be 0 after initial RESET at %t     ", $time);
		$display("************************************************************");
		$finish;
	end
	#(10); rst_n=1;
	#(3); release clk;
end endtask


task input_weight_task; begin
	//repeat(2)@(negedge clk);
	in_valid_w1 = 1;
	in_valid_w2 = 1;
	for(j = 0; j < 12; j = j+1) begin
		cnt_W0 = $fscanf(file_W0, "%b", weight1);
		weight1_store[j] = weight1;
		if(j < 3) begin
			cnt_W1 = $fscanf(file_W1, "%b", weight2);
			weight2_store[j] = weight2;
		end else begin
			in_valid_w2 = 0;
			weight2 = 32'bx;
		end		
		@(negedge clk);
	end		   
	in_valid_w1 = 0;  weight1 = 32'bx;
end endtask


task input_data_task; begin
	//repeat(2)@(negedge clk);	
	in_valid_d = 1;
	in_valid_t = 1;
	for(j = 0; j < 4; j = j + 1) begin
		if(epocount == 0) begin
			cnt_data = $fscanf(file_data, "%b", data_point);
			total_data_store[itercount * 4 + j] = data_point;
		end else begin
			data_point = total_data_store[itercount * 4 + j];
		end		
		data_store[j] = data_point;
		if(j == 0) begin
			if(epocount == 0) begin
				cnt_target = $fscanf(file_target, "%b", target);
				total_target_store[itercount] = target;
			end else begin
				target = total_target_store[itercount];
			end						
			target_store = target;
		end else begin
			in_valid_t = 0;
			target = 32'bx;
		end		
		@(negedge clk);
	end
	in_valid_d = 0; data_point = 32'bx;
end endtask


task calculate_ans; begin
// Forward Stage
	ans = 0;
	for(i = 0; i < 3; i = i + 1) begin	
		for(j = 0; j < 4; j = j + 1) begin
			mult_a = data_store[j];
			mult_b = weight1_store[i * 4 + j];
			#delay_time;
			op = 0;
			addsub_a = mult_out;
			addsub_b = ans;
			#delay_time;
			ans = addsub_out;
		end
		if(ans <= 0) begin // ReLU
			hidden_store[i] = 0;
			gradient[i] = 0;
		end else begin
			hidden_store[i] = ans;
			gradient[i] = 1;
		end
		ans = 0;
	end
	
	ans = 0;
	for(k = 0; k < 3; k = k + 1) begin
		mult_a = hidden_store[k];
		mult_b = weight2_store[k];
		#delay_time;
		op = 0;
		addsub_a = mult_out;
		addsub_b = ans;
		#delay_time;
		ans = addsub_out;
	end

	
// Backward Stage
	error = 0;
	op = 1;
	addsub_a = ans;
	addsub_b = target_store;
	#delay_time;
	error = addsub_out;

	for(i = 0; i < 3; i = i + 1) begin
		if(gradient[i] == 0) begin
			hidden_back_store[i] = 0;
		end else begin
			mult_a = error;
			mult_b = weight2_store[i];
			#delay_time;
			hidden_back_store[i] = mult_out;
		end
	end
	
	
// Update Stage
	for(i = 0; i < 3; i = i + 1) begin // Weight2
		mult_a = learn;
		mult_b = error;
		#delay_time;
		mult_a = mult_out;
		mult_b = hidden_store[i];
		#delay_time;
		op = 1;
		addsub_a = weight2_store[i];
		addsub_b = mult_out;
		#delay_time;
		weight2_store[i] = addsub_out;
	end

	for(j = 0; j < 3; j = j + 1) begin // Weight1
		for(k = 0; k < 4; k = k + 1) begin
			mult_a = learn;
			mult_b = hidden_back_store[j];
			#delay_time;
			mult_a = mult_out;
			mult_b = data_store[k];
			#delay_time;
			op = 1;
			addsub_a = weight1_store[j * 4 + k];
			addsub_b = mult_out;
			#delay_time;
			weight1_store[j * 4 + k] = addsub_out;
		end
	end
end endtask


task wait_out_valid; begin
  lat = -1;
  while(out_valid !== 1) begin
	lat = lat + 1;
	if(out !== 0) begin 
		$display("**************************************************************************");
		$display("            The out should be reseted when out_valid is down.             ");
		$display("**************************************************************************");
		repeat(2)@(negedge clk);
		$finish;
	end
	else if(lat == 20) begin//200
		$display("**************************************************************");
		$display("          The execution latency are over 200 cycles.          ");
		$display("**************************************************************");
		repeat(2)@(negedge clk);
		$finish;
	end
	@(negedge clk);
  end
  total_latency = total_latency + lat;
end endtask


task check_ans; begin
	// if(out !== ans)
	// if((ans > out) && ((ans-out)/ans > 0.0000001))
	if((out[31] !== ans[31]) || (out[31-1] !== ans[31-1]) || (out[31-2] !== ans[31-2]) || (out[31-3] !== ans[31-3]) || 
	   (out[27] !== ans[27]) || (out[27-1] !== ans[27-1]) || (out[27-2] !== ans[27-2]) || (out[27-3] !== ans[27-3]) || 
	   (out[23] !== ans[23]) || (out[23-1] !== ans[23-1]) || (out[23-2] !== ans[23-2]) || (out[23-3] !== ans[23-3]) || 
	   (out[19] !== ans[19]) || (out[19-1] !== ans[19-1]) || (out[19-2] !== ans[19-2]) || (out[19-3] !== ans[19-3]))
	// if((out[15] !== ans[15]) || (out[15-1] !== ans[15-1]) || (out[15-2] !== ans[15-2]) || (out[15-3] !== ans[15-3]))
	begin
		$display("*****************************************************************************");
		$display("                               PATTERN  NO.%4d                               ", patcount);
		$display("                                EPOCH   NO.%4d                               ", epocount);
		$display("                              ITERATION NO.%4d                               ", itercount);		
		$display("                     ans : %h,  Your output : %h  at %8t                     ", ans, out, $time);
        $display("*****************************************************************************");
		repeat(2) @(negedge clk);
		$finish;
	end
	else
	begin
		check_out_valid;
		$display("\033[0;34mPASS PATTERN NO.%4d, EPOCH NO.%4d, ITERATION NO.%4d,\033[m \033[0;32mexecution cycle : %3d,\033[m  \033[0;36mans : %d\033[m", patcount, epocount, itercount, lat, ans);	
		pat_delay = 0;
		repeat(pat_delay)@(negedge clk);
	end
end endtask


task check_out_valid; begin
	@(negedge clk);
	if(out_valid == 1'b1) begin
		$display("***************************************************************");
		$display("                The out_valid is over 1 cycles.                ");
		$display("***************************************************************");
		repeat(2)@(negedge clk);
		$finish;
	end
	@(negedge clk);
end endtask


task pass; begin
	  $display ("-------------------------------------------------------------------");
	  $display ("                         Congratulations!                          ");
	  $display ("                  You have passed all patterns!                    ");
	  $display ("                 Your execution cycles = %5d cycles                ", total_latency);
	  $display ("                    Your clock period = %.1f ns                    ", CYCLE);
	  $display ("                    Your total latency = %.1f ns                   ", total_latency * CYCLE);
	  $display ("-------------------------------------------------------------------");    
	  $finish;	
end endtask

endmodule
