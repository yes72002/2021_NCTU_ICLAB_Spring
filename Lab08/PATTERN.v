

`define CYCLE_TIME 8


module PATTERN(
	// Output signals
	clk,
	rst_n,
	cg_en,
	in_valid,
	in_data,
	in_mode,
	// Input signals
	out_valid,
	out_data
);


output reg clk;
output reg rst_n;
output reg cg_en;
output reg in_valid;
output reg [8:0] in_data;
output reg [2:0] in_mode;

input out_valid;
input [8:0] out_data;


//================================================================
// parameters & integer
//================================================================
real CYCLE = `CYCLE_TIME;
integer total_latency,wait_val_time;
integer file_in, file_out, patnum;
integer q,a,b,c,i,s;

reg [8:0] gold_ans;
//================================================================
// clock
//================================================================
initial begin
    clk = 0;
end
always #(CYCLE/2.0) clk = ~clk;


//================================================================
// initial
//================================================================

initial begin

	file_in =  $fopen("../00_TESTBED/in.txt", "r");	
	file_out =  $fopen("../00_TESTBED/out.txt", "r");
	if (file_in == 0 || file_out == 0)begin
		$display ("Error in opening the files");
		$finish;
	end
	//$finish;
	rst_n = 1'b1;
	cg_en   = 1'b0;
	in_valid = 1'b0;
	in_data = 9'bx; 
	in_mode = 3'bx;
	force clk = 0;
	total_latency = 0;
	reset_signal_task;
	a = $fscanf(file_in, "%d", patnum);
	for(q=0;q<patnum;q=q+1)begin
		give_input_task;
		wait_out_valid;
		check_ans;
		

	end
	YOU_PASS_task;
	$fclose(file_in);
	$fclose(file_out);
end

//================================================================
// task
//================================================================
task reset_signal_task;
begin
  #(10.0);  rst_n=0;
  #(2.0);
  if((out_valid !== 0)||(out_data !== 0))
  begin
    $display("**************************************************************");
    $display("*   Output signal should be 0 after initial RESET            *");
    $display("**************************************************************");
	$finish;
	repeat(2)@(negedge clk);
  end
  #(5);  rst_n=1;
  #(3);  release clk;
end 
endtask



task give_input_task;
begin
	in_valid = 1'b1;
	if(out_valid !== 0 || out_data !== 0) begin
		$display("***************************************************************");
		$display("*           out_valid can't overlap with in_valid             *");
		$display("***************************************************************");
		repeat(2)@(negedge clk);
		$finish;
	end
	
	b = $fscanf(file_in, "%d", in_mode);
	for(i = 0 ; i < 6 ; i = i + 1)begin
		c = $fscanf(file_in, "%d", in_data);
		if(i == 1)begin
			in_mode = 3'bxxx;
		end
		@(negedge clk);
			
	end

	in_valid = 1'b0;
	in_data = 31'bx;
end
endtask


task wait_out_valid; begin
  wait_val_time = 0;
  while(out_valid !== 1) begin 
	wait_val_time = wait_val_time + 1;
	if(wait_val_time == 2000)begin
		$display("***************************************************************");
		$display("*         The execution latency are over 2000 cycles.         *");
		$display("***************************************************************");
		repeat(2)@(negedge clk);
		$finish;
	end

	if(out_data != 0) begin
		$display("***************************************************************");
		$display("*           out should be 0 when out valid is low             *");
		$display("***************************************************************");
		repeat(2)@(negedge clk);
		$finish;
	end

	@(negedge clk);
  end
  total_latency = total_latency + wait_val_time;
end endtask

task check_ans; 
begin

	s = 0;
	while(out_valid===1'b1) begin
	
		a = $fscanf(file_out, "%d", gold_ans);
		if(gold_ans !== out_data) begin
			$display ("---------------------------------------------------");
			$display ("                  Output Error.                    ");
			$display ("               pattern number = %d                 ",q);
			$display ("               Correct answer =%d   				",gold_ans);
			$display ("                 your answer =%d  at ans num:%d  ",out_data, s);			
			$display ("---------------------------------------------------");
			repeat(2) @(negedge clk);
			$finish;
		end
		if(s > 6) begin
			$display ("---------------------------------------------------");
			$display ("          out_valid is more than 6 cycle.          ");
			$display ("---------------------------------------------------");
			repeat(2) @(negedge clk);
			$finish;
		end
		s=s+1;
        @(negedge clk);

	end



	$display("\033[0;34mPASS PATTERN num:%4d ,\033[m \033[0;32mexecution cycle : %3d\033[m",q+1,wait_val_time);
	
	if(out_data!==0)begin
		$display("***************************************************************");
		$display("*        The out should be reset after your out_valid is pulled down.   *");
		$display("***************************************************************");
		repeat(2)@(negedge clk);
		$finish;	
	end
	repeat(2)@(negedge clk);

end
endtask


task YOU_PASS_task; 
begin
  $display ("--------------------------------------------------------------------");
  $display ("                         Congratulations!                           ");
  $display ("                  You have passed all patterns!                     ");
  $display ("             Total Cycle: %d --- Cycle time: %.2fns                 ", total_latency, CYCLE); 
  $display ("                      Total Latency: %.2fns                        ", total_latency * CYCLE); 
  $display ("--------------------------------------------------------------------");
#(100);
$finish;
end
endtask

endmodule


