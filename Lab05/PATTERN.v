

`ifdef RTL
`define CYCLE_TIME 12.0
`endif
`ifdef GATE
`define CYCLE_TIME 12.0
`endif

// `ifdef RTL
	// `define CYCLE_TIME 5.0  
// `endif
// `ifdef GATE
	// `define CYCLE_TIME 5.0
// `endif

module PATTERN(
        // input signals
		clk,
		rst_n,
		in_valid,
		in_data,
		size,
		action,
        // output signals
		out_valid,
		out_data
);
//io
output	reg		clk,rst_n,in_valid;
output	reg	[30:0]	in_data;
output 	reg	[1:0]	size;
output	reg	[2:0]	action;
real CYCLE=`CYCLE_TIME;
input			out_valid;
input		[30:0]	out_data;
initial clk = 0;
always #(CYCLE/2.0) clk = ~clk;
integer p,i;
integer lat,x;
integer in;
integer f_in;
// integer ans[1023:0];
integer ans[255:0];
reg [2:0] actions;
reg [1:0] sizes;
// integer matrix [1023:0];
integer matrix [255:0];
// parameter Trace=3'b000,Mirror=3'b001,Transpose=3'b010,Rotate=3'b011,Set_up=3'b100,Add=3'b101,Mult=3'b110;
parameter Set_up=3'b000,Add=3'b001,Mult=3'b010,Transpose=3'b011,Mirror=3'b100,Rotate=3'b101,Trace=3'b110;

// parameter patnumber=200;
parameter patnumber=34;
initial begin
  f_in  = $fopen("../00_TESTBED/MC.txt", "r");
  rst_n=1'b1;
  in_valid=1'b0;
  in_data='bx;
  size='bx;
  action='bx;
  // for(i=0;i<1024;i=i+1)begin
  for(i=0;i<255;i=i+1)begin
  matrix[i]='bx;
  end
  force clk = 0;
  reset_signal_task;
  for (p=0; p<patnumber; p=p+1)
	begin
		input_task;
        wait_out_valid;
        check_ans;
    end
  YOU_PASS_task;
  
end

task reset_signal_task; begin 
    #CYCLE; rst_n = 0; 
    #CYCLE; rst_n = 1;
    if(out_valid!==1'b0||out_data!==0) begin//out!==0
        $display("************************************************************");      
        $display("*  Output signal should be 0 after initial RESET  at %8t   *",$time);
        $display("************************************************************");
        repeat(2) #CYCLE;
        $finish;
    end
	#CYCLE; release clk;
end endtask
task input_task; begin

    
	    in =$fscanf(f_in,"%d",actions);
	  if(actions==Set_up)begin////////////////////
	     in =$fscanf(f_in,"%d",sizes);
	  end
    repeat(2) @(negedge clk);
	in_valid=1'b1;
if(actions==Mult||actions==Add||actions==Set_up)begin///////////////////////////////////////
  
if(sizes==2'b00)begin
    for(i=0;i<4;i=i+1)begin
	if(actions==Set_up)begin/////////
      if(i==0)size=sizes;
	  else size='bx;
	end
	if(i==0)action=actions;
	else action='bx;
	in =$fscanf(f_in,"%d",matrix[i]);
	in_data=matrix[i];
	@(negedge clk);
	end
end
else if(sizes==2'b01)begin
   for(i=0;i<16;i=i+1)begin
   if(actions==Set_up)begin/////
      if(i==0)size=sizes;
	  else size='bx;
	end
	if(i==0)action=actions;
	else action='bx;
	in =$fscanf(f_in,"%d",matrix[i]);
	in_data=matrix[i];
	@(negedge clk);
	end
end
else if(sizes==2'b10)begin
    for(i=0;i<64;i=i+1)begin
	if(actions==Set_up)begin
      if(i==0)size=sizes;
	  else size='bx;
	end
	if(i==0)action=actions;
	else action='bx;
	in =$fscanf(f_in,"%d",matrix[i]);
	in_data=matrix[i];
	@(negedge clk);
	end
end
else begin
    for(i=0;i<256;i=i+1)begin
	if(actions==Set_up)begin
      if(i==0)size=sizes;
	  else size='bx;
	end
	if(i==0)action=actions;
	else action='bx;
	in =$fscanf(f_in,"%d",matrix[i]);
	in_data=matrix[i];
	@(negedge clk);
	end
end
end
else begin
 action=actions;
 size=sizes;
 @(negedge clk);
end
  // if(actions==Trace)begin///////////////////////////////////
  if((actions==Transpose)||(actions==Mirror)||(actions==Rotate))begin///////////////////////////////////
   in =$fscanf(f_in,"%d",ans[0]);
   end
   else if(sizes==2'b00)begin
      for(i=0;i<4;i=i+1)begin
	    in =$fscanf(f_in,"%d",ans[i]);
	  end
   end
   else if(sizes==2'b01)begin
      for(i=0;i<16;i=i+1)begin
	    in =$fscanf(f_in,"%d",ans[i]);
	  end
   end
   else if(sizes==2'b10)begin
     for(i=0;i<64;i=i+1)begin
	    in =$fscanf(f_in,"%d",ans[i]);
	  end
   end
   else begin
      for(i=0;i<256;i=i+1)begin
	    in =$fscanf(f_in,"%d",ans[i]);
	  end
   end
in_valid='b0;
in_data='bx;
size='bx;
action='bx;
for(i=0;i<256;i=i+1)begin
  matrix[i]='bx;
  end

end endtask


// task compute_ans; begin
   // if(actions==Trace)begin
   // in =$fscanf(f_in,"%d",ans[0]);
   // end
   // else if(sizes==2'b00)begin
      // for(i=0;i<16;i=i+1)begin
	    // in =$fscanf(f_in,"%d",ans[i]);
	  // end
   // end
   // else if(sizes==2'b01)begin
      // for(i=0;i<64;i=i+1)begin
	    // in =$fscanf(f_in,"%d",ans[i]);
	  // end
   // end
   // else if(sizes==2'b10)begin
     // for(i=0;i<256;i=i+1)begin
	    // in =$fscanf(f_in,"%d",ans[i]);
	  // end
   // end
   // else begin
      // for(i=0;i<1024;i=i+1)begin
	    // in =$fscanf(f_in,"%d",ans[i]);
	  // end
   // end
// end endtask

task check_ans; begin
	x=0;
	while(out_valid)
	begin
	    // if(actions==Trace)begin///////////////////////////////////////////
		if((actions==Transpose)||(actions==Mirror)||(actions==Rotate))begin///////////////////////////////////////////
		    if(out_data!==ans[0] )//check ans
		    		begin
		    			$display ("------------------------------------------------------------------------------------------------------------------------------------------");
		    			$display ("                                                                      FAIL!                                                               ");
		    			$display ("                                                                 Trace Ans:          %1d                                                   ",ans[0]);//show ans
		    			$display ("                                                                 Your output : %d at %8t                                ",out_data,$time);//show output
		    			$display ("------------------------------------------------------------------------------------------------------------------------------------------");
		    			repeat(9) @(negedge clk);
		    			$finish;
		    		end
		    @(negedge clk);	
		end
		else if(sizes==2'b00&&x<4)begin
		    if(out_data!==ans[x] )//check ans
		    		begin
		    			$display ("------------------------------------------------------------------------------------------------------------------------------------------");
		    			$display ("                                                                      FAIL!                                                               ");
		    			$display ("                                                                 Ans:          %1d    %d                                               ",ans[x],x);//show ans
		    			$display ("                                                                 Your output : %d at %8t                                ",out_data,$time);//show output
		    			$display ("------------------------------------------------------------------------------------------------------------------------------------------");
		    			repeat(9) @(negedge clk);
		    			$finish;
		    		end
		    x=x+1;
		    @(negedge clk);	
		end
		else if(sizes==2'b01&&x<16)begin
		    if(out_data!==ans[x] )//check ans
		    		begin
		    			$display ("------------------------------------------------------------------------------------------------------------------------------------------");
		    			$display ("                                                                      FAIL!                                                               ");
		    			$display ("                                                                 Ans:          %1d    %d                                               ",ans[x],x);//show ans
		    			$display ("                                                                 Your output : %d at %8t                                ",out_data,$time);//show output
		    			$display ("------------------------------------------------------------------------------------------------------------------------------------------");
		    			repeat(9) @(negedge clk);
		    			$finish;
		    		end
		    x=x+1;
		    @(negedge clk);	
		end
		else if(sizes==2'b10&&x<64)begin
		    if(out_data!==ans[x] )//check ans
		    		begin
		    			$display ("------------------------------------------------------------------------------------------------------------------------------------------");
		    			$display ("                                                                      FAIL!                                                               ");
		    			$display ("                                                                 Ans:          %1d   %d                                                ",ans[x],x);//show ans
		    			$display ("                                                                 Your output : %d at %8t                                ",out_data,$time);//show output
		    			$display ("------------------------------------------------------------------------------------------------------------------------------------------");
		    			repeat(9) @(negedge clk);
		    			$finish;
		    		end
		    x=x+1;
		    @(negedge clk);	
		end
		else if(sizes==2'b11&&x<256)begin
		    if(out_data!==ans[x] )//check ans
		    		begin
		    			$display ("------------------------------------------------------------------------------------------------------------------------------------------");
		    			$display ("                                                                      FAIL!                                                               ");
		    			$display ("                                                                 Ans:          %1d    %d                                               ",ans[x],x);//show ans
		    			$display ("                                                                 Your output : %d at %8t                                ",out_data,$time);//show output
		    			$display ("------------------------------------------------------------------------------------------------------------------------------------------");
		    			repeat(9) @(negedge clk);
		    			$finish;
		    		end
		    x=x+1;
		    @(negedge clk);	
		end
	end		
	$display("\033[0;34mPASS PATTERN NO.%d,\033[m \033[0;32mexecution cycle : %d\033[m",p ,lat);
	@(negedge clk);
end endtask

task wait_out_valid; begin
    lat=-1;
    while(out_valid!==1) begin
	lat=lat+1;
      if(lat==25000)begin//lat==max+1
          $display("********************************************************");     
          $display("*  The execution latency are over 50000 cycles  at %8t   *",$time);//over max
          $display("********************************************************");
	    repeat(2)@(negedge clk);
	    $finish;
      end
     @(negedge clk);
   end
end endtask

task YOU_PASS_task; begin
    $display ("--------------------------------------------------------------------");
    $display ("                         Congratulations!                           ");
    $display ("                  You have passed all patterns!                     ");
    $display ("--------------------------------------------------------------------");        
    repeat(2)@(negedge clk);
    $finish;
end endtask

endmodule

