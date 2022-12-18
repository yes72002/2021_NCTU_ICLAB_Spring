

// PATTERN_JIM Lab10

`include "../00_TESTBED/pseudo_DRAM.sv"
`include "Usertype_PKG.sv"
// `include "success.sv"
program automatic PATTERN(input clk, INF.PATTERN inf);
import usertype::*;

//================================================================
// parameters & integer
//================================================================
parameter DRAM_p_r = "../00_TESTBED/DRAM/dram.dat";
integer   i,k;
integer   user_cnt, act_cnt;
integer   wait_val_time, total_latency;
integer   lat;

//================================================================
// wire & registers 
//================================================================
logic [7:0] golden_DRAM[ ((65536+256*4)-1) : (65536+0) ];
// 10000 ~ 103FC
// 65536 ~ 66556

// typedef union packed{ 
    // Action       [3:0]d_act;
	// Land         [1:0]d_id;
	// Crop_cat     [3:0]d_cat;
	// Water_amnt        d_amnt;
// } DATA;


//      GOLDEN      //
// Balance    golden_out_balance;
DATA       golden_DATA;
Land_Info  golden_land_info;

Land       golden_land_id;
Crop_cat   golden_land_crop;
Crop_sta   golden_land_status;
Water_amnt golden_land_water;

Error_Msg  golden_err_msg;
logic      golden_complete;
logic [31:0] golden_out_info;
logic [31:0] golden_out_deposit;
// logic [31:0] out_info;
// logic [31:0] out_deposit;
logic [31:0] golden_info;
logic [31:0] golden_deposit;

// logic [3:0]golden_user_pw;
// logic [7:0]golden_user_pw_en;

logic [7:0] golden_id;
logic [3:0] golden_act;
logic [3:0] golden_crop;
logic [15:0] golden_water;
logic [16:0] golden_DRAM_addr;


//================================================================
// class random
//================================================================
class random_id;
        randc logic [7:0] ran_id;
        logic [7:0] ran_id_0  ;
		logic [7:0] out;
		// function new (int seed);
			// this.srandom(seed);
		// endfunction
        constraint range{ ran_id inside{[0:255]}; }
        // constraint range{ ran_id_0 inside{0}; }
		task set (logic [7:0] in);
			out = in;
		endtask
		
endclass
class pkt;
	rand logic [7:0] saddr, daddr;
	rand logic [3:0] etype;
	logic [15:0] pkt_size;
	function new(int in);
	pkt_size = in;
	endfunction: new
endclass: pkt

// class test_id #(parameter in = 5);
class test_id #( in = 5);
        // randc logic [7:0] ran_id;
        // logic [7:0] ran_id_0  ;
		logic [7:0] out;
        // constraint range{ ran_id inside{[0:255]}; }
		task sss;
			out = in;
		endtask
		
endclass


class random_act;
        rand Action ran_act;
        constraint range{ ran_act inside{Seed,Water,Reap,Steal}; }
endclass

class random_user_act_cnt;
        rand integer    ran_act_cnt;
        constraint range{ ran_act_cnt inside{[1:100]}; }
endclass

class random_crop;
        rand logic [3:0] ran_crop;
        constraint range{ ran_crop inside{Potato,Corn,Tomato,Wheat}; }
endclass

class random_water;
        rand logic [15:0] ran_water;
		rand logic [15:0] ran_water_0;
        rand logic [15:0] ran_water_1;
        rand logic [15:0] ran_water_2;
        rand logic [15:0] ran_water_3;
        rand logic [15:0] ran_water_4;
        rand logic [15:0] ran_water_5;
        rand logic [15:0] ran_water_6;
        constraint range{ ran_water inside{[0:1023]}; }
        constraint range_0{ ran_water_0 inside{[    0:12000]}; }
		constraint range_1{ ran_water_1 inside{[12001:24000]}; }
        constraint range_2{ ran_water_2 inside{[24001:36000]}; }
        constraint range_3{ ran_water_3 inside{[36001:48000]}; }
        constraint range_4{ ran_water_4 inside{[48001:60000]}; }
        constraint range_5{ ran_water_5 inside{[60001:65535]}; }
endclass
// 16'd0~16'd12000
// class random_water_0;
        // rand logic [15:0] ran_water_0;
        // constraint range{ ran_water_0 inside{[0:12000]}; }
// endclass
// 16'd12001~16'd24000
// class random_water_1;
        // rand logic [15:0] ran_water_1;
        // constraint range{ ran_water_1 inside{[12001:24000]}; }
// endclass
// 16'd24001~16'd36000
// class random_water_2;
        // rand logic [15:0] ran_water_2;
        // constraint range{ ran_water_2 inside{[24001:36000]}; }
// endclass
// 16'd36001~16'd48000
// class random_water_3;
        // rand logic [15:0] ran_water_3;
        // constraint range{ ran_water_3 inside{[36001:48000]}; }
// endclass
// 16'd48001~16'd60000
// class random_water_4;
        // rand logic [15:0] ran_water_4;
        // constraint range{ ran_water_4 inside{[48001:60000]}; }
// endclass
// 16'd60001~16'd65535
// class random_water_5;
        // rand logic [15:0] ran_water_5;
        // constraint range{ ran_water_5 inside{[60001:65535]}; }
// endclass

class random_passwd;
		rand logic [3:0]    ran_passwd;
		constraint range{ ran_passwd inside{[0:15]}; }
endclass


//================================================================
// initial
//================================================================
initial $readmemh(DRAM_p_r, golden_DRAM);
random_id            r_id      =  new();
pkt                  p = new(1);
// test_id              r_t = new(1);
random_act           r_act     =  new();
random_user_act_cnt  r_act_cnt =  new();
random_crop          r_crop    =  new();
random_water         r_water   =  new();
// random_water_0       r_water_0 =  new();
// random_water_1       r_water_1 =  new();
// random_water_2       r_water_2 =  new();
// random_water_3       r_water_3 =  new();
// random_water_4       r_water_4 =  new();
// random_water_5       r_water_5 =  new();
random_passwd        r_passwd  =  new();
logic [2:0] x;
initial begin
	inf.rst_n = 1;
	inf.id_valid = 0;
	inf.act_valid = 0;
	inf.cat_valid = 0;
	inf.amnt_valid = 0;
	inf.D = 'bx;
	
	// force clk = 0;
	golden_err_msg = 0;
    golden_complete = 0;
	
	golden_id = 0;
	golden_act = 0;
	golden_crop = 0;
	golden_water = 0;
	// golden_DRAM_addr = 0;
	
	golden_info = 0;
	golden_deposit  = 0;
	golden_out_info = 0;
	golden_out_deposit = 0;
	lat = 0;
	wait_val_time   = 0;
	total_latency   = 0;
	
	reset_signal_task;
	
	golden_deposit = {golden_DRAM[66556],golden_DRAM[66557],golden_DRAM[66558],golden_DRAM[66559]};
	// golden_out_deposit = {golden_DRAM[66556],golden_DRAM[66557],golden_DRAM[66558],golden_DRAM[66559]};
	repeat(1) @(negedge clk);
	give_check_deposit;
	latency_task;
	
	give_id_0;
	give_act_seed;
	give_crop;
	give_water_0;
	latency_task;
	check_ans;
	
	// give_act_reap;
	// give_water_1;
	// latency_task;
	// check_ans;
	
	// give_id_1;
	// give_act_seed;
	// give_crop;
	// give_water_0;
	// give_act_reap;
	// give_water_1;
	// latency_task;
	
	
	
	// repeat(100) @(negedge clk);
	
	// No_Err       = 4'd0 ,
	// Is_Empty     = 4'd1 ,
	// Not_Empty    = 4'd2 ,
	// Has_Grown    = 4'd3 ,
	// Not_Grown    = 4'd4 
	
	// seed to seed - Not_Empty
	// seed to water - Is_Empty or Has_Grown
	// seed to reap - Is_Empty or Not_Grown
	// seed to steal - Is_Empty or Not_Grown
	// seed to check_deposit
	// water to seed
	// water to water
	// water to reap
	// water to steal
	// water to check_deposit
	// reap to seed
	// reap to water
	// reap to reap
	// reap to steal
	// reap to check_deposit
	// steal to seed
	// steal to water
	// steal to reap
	// steal to steal
	// steal to check_deposit
	// check_deposit to seed
	// check_deposit to water
	// check_deposit to reap
	// check_deposit to steal
	// check_deposit to check_deposit
	
	
    // for(user_num=0; user_num < user_num ; user_num = user_num +1)begin
		// input_task;
		// wait_out_valid;
		// check_ans;
		// repeat(3) @(negedge clk);
    // end
	// input_task;
	#(10);
	
	$finish;
end

// initial begin
	// #(1000);
	// $finish;
	// congratulations;
// end

// initial begin
	// forever@(posedge clk)begin
		// if(inf.out_valid)begin
		    // @(negedge clk);
			// if((inf.complete    !== golden_complete) ||
			   // (inf.err_msg     !== golden_err_msg ) ||
			   // (inf.out_info    !== golden_out_info) ||
			   // (inf.out_deposit !== golden_out_deposit) ) begin
				// #(100)
				// $finish;
			// end
            // else begin

				// $display("\033[0;38;5;111mPASS USER \033[4m NO.%3d \033[m \033[0;38;5;219mACT NO. %d\033[m latency: %3d", user_cnt, act_cnt, wait_val_time);
            // end			
		// end
	// end
// end

//================================================================
// task definition
//================================================================
task reset_signal_task; begin 
    #(0.5);  inf.rst_n <= 0;
    $readmemh(DRAM_p_r, golden_DRAM);	
	inf.D           = 0;
	inf.id_valid    = 0;
	inf.cat_valid   = 0;
	inf.amnt_valid  = 0;
	inf.act_valid   = 0;
	#(5);
	if((inf.out_valid   !== 'b0)||
	   (inf.complete    !== 'b0)||
	   (inf.err_msg     !== 'b0)||
	   (inf.out_info    !== 'b0)||
	   (inf.out_deposit !== 'b0)) begin
		$display("************************************************************");
		$display("*                             FAIL                         *");
		$display("*   Output signal should be 0 after initial RESET at %t    *",$time);
		$display("************************************************************");
		$finish;
	end
    #(5);
	inf.rst_n <=1;
end endtask

task latency_task; begin 
    lat=-1;
    while(inf.out_valid!==1) begin
		lat=lat+1;
		if(lat==1200)begin
			// if(lat==50)begin
				// $display ("*********************************************************");
				// $display ("*                     SPEC 6 FAIL!                      *");
				// $display ("*       The execution latency are over 300 cycles.      *");
				// $display ("*********************************************************");
				$display("  SPEC 6 FAIL!  ");
			// end
			repeat(2)@(negedge clk);
			$finish;
		end
		@(negedge clk);
    end
	// @(negedge clk);
	total_latency = total_latency + lat;
end endtask

task input_task; begin
    // D,
	// id_valid,
	// passwd_valid,
	// amnt_valid,
	// act_valid,
	// C_out_valid,
	// C_data_r
	
	// user_log_in;
	// r_act.randomize();
	// case(r_act.ran_act)
		// 3'd2:
		// 3'd3:
		// 3'd5:
		// 3'd6:
		// 3'd7:
	// endcase
	
	//transfer_money;
	// make_a_deposit;
	//check_balance;
    //change_user_password;
	
    // user_log_out;
	// user_log_in;
end
endtask
task check_ans; begin
	$display("golden_id = %d",golden_id);
	// 0~255 -> 65536~66559(66560)
	// golden_DRAM[golden_id]
	// 0 ->
	// $display("land id = %d",golden_DRAM[golden_id+65536]);
	// $display("land crop = %d",golden_DRAM[golden_id+65536+1][3:0]);
	// $display("land status = %d",golden_DRAM[golden_id+65536+1][7:4]);
	// $display("land water = %d",golden_DRAM[golden_id+65536+2]);
	// $display("land water = %d",golden_DRAM[golden_id+65536+3]);
    golden_info = {golden_DRAM[golden_id+65536],golden_DRAM[golden_id+65536+1],golden_DRAM[golden_id+65536+2],golden_DRAM[golden_id+65536+3]};
	// golden_land_info.land_id     = golden_DRAM[golden_id+65536];
	// golden_land_info.land_status = golden_DRAM[golden_id+65536+1];
	// golden_land_info.water_amnt  = {golden_DRAM[golden_id+65536+2],golden_DRAM[golden_id+65536+3]};
	// $display("land id = %d",golden_land_info.land_id);
	// $display("land crop = %d",golden_land_info.land_status);
	// $display("land water = %d",golden_land_info.water_amnt);
	
end
endtask

task give_id; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.randomize();
	golden_id = r_id.ran_id;
	inf.D     = {8'b0, golden_id};
	// inf.D     = {8'b0, 8'b0};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_0; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(0);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
	// $display("%d",golden_id);
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_1; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(1);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_2; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(2);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_3; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(3);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_4; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(5);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_5; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(5);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_6; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(6);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_7; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(7);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_8; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(8);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_9; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(9);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_10; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(10);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_11; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(11);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_12; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(12);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_13; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(13);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_14; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(14);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_15; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(15);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_16; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(16);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_17; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(17);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_18; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(18);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_19; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(19);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_20; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(20);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_21; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(21);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_22; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(22);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_23; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(23);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_24; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(24);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_25; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(25);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_26; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(26);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_27; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(27);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_28; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(28);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_29; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(29);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_30; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(30);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_31; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(31);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_32; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(32);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_33; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(33);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_34; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(34);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_35; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(35);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_36; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(36);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_37; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(37);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_38; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(38);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_39; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(39);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_40; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(40);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_41; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(41);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_42; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(42);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_43; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(43);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_44; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(44);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_45; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(45);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_46; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(46);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_47; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(47);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_48; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(48);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_49; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(49);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_50; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(50);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_51; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(51);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_52; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(52);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_53; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(53);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_54; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(54);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_55; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(55);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_56; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(56);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_57; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(57);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_58; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(58);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_59; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(59);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_60; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(60);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_61; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(61);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_62; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(62);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_63; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(63);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_64; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(64);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_65; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(65);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_66; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(66);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_67; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(67);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_68; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(68);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_69; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(69);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_70; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(70);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_71; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(71);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_72; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(72);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_73; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(73);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_74; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(74);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_75; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(75);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_76; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(76);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_77; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(77);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_78; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(78);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_79; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(79);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_80; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(80);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_81; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(81);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_82; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(82);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_83; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(83);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_84; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(84);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_85; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(85);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_86; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(86);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_87; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(87);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_88; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(88);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_89; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(89);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_90; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(90);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_91; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(91);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_92; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(92);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_93; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(93);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_94; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(94);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_95; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(95);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_96; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(96);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_97; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(97);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_98; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(98);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_99; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(99);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_100; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(100);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_101; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(101);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_102; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(102);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_103; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(103);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_104; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(104);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_105; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(105);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_106; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(106);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_107; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(107);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_108; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(108);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_109; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(109);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_110; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(110);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_111; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(111);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_112; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(112);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_113; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(113);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_114; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(114);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_115; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(115);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_116; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(116);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_117; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(117);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_118; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(118);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_119; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(119);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_120; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(120);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_121; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(121);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_122; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(122);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_123; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(123);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_124; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(124);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_125; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(125);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_126; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(126);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_127; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(127);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_128; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(128);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_129; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(129);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_130; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(130);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_131; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(131);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_132; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(132);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_133; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(133);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_134; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(134);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_135; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(135);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_136; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(136);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_137; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(137);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_138; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(138);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_139; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(139);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_140; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(140);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_141; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(141);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_142; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(142);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_143; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(143);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_144; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(144);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_145; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(145);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_146; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(146);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_147; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(147);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_148; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(148);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_149; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(149);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_150; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(150);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_151; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(151);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_152; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(152);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_153; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(153);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_154; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(154);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_155; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(155);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_156; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(156);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_157; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(157);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_158; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(158);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_159; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(159);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_160; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(160);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_161; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(161);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_162; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(162);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_163; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(163);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_164; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(164);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_165; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(165);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_166; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(166);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_167; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(167);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_168; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(168);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_169; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(169);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_170; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(170);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_171; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(171);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_172; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(172);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_173; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(173);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_174; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(174);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_175; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(175);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_176; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(176);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_177; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(177);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_178; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(178);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_179; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(179);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_180; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(180);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_181; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(181);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_182; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(182);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_183; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(183);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_184; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(184);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_185; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(185);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_186; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(186);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_187; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(187);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_188; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(188);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_189; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(189);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_190; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(190);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_191; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(191);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_192; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(192);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_193; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(193);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_194; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(194);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_195; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(195);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_196; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(196);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_197; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(197);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_198; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(198);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_199; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(199);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_200; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(200);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_201; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(201);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_202; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(202);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_203; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(203);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_204; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(204);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_205; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(205);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_206; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(206);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_207; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(207);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_208; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(208);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_209; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(209);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_210; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(210);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_211; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(211);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_212; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(212);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_213; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(213);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_214; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(214);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_215; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(215);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_216; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(216);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_217; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(217);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_218; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(218);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_219; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(219);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_220; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(220);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_221; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(221);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_222; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(222);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_223; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(223);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_224; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(224);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_225; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(225);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_226; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(226);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_227; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(227);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_228; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(228);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_229; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(229);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_230; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(230);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_231; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(231);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_232; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(232);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_233; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(233);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_234; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(234);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_235; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(235);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_236; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(236);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_237; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(237);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_238; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(238);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_239; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(239);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_240; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(240);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_241; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(241);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_242; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(242);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_243; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(243);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_244; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(244);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_245; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(245);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_246; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(246);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_247; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(247);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_248; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(248);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_249; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(249);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_250; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(250);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_251; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(251);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_252; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(252);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_253; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(253);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_254; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(254);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask

task give_id_255; begin
	repeat(1) @(negedge clk);
	inf.id_valid = 'b1;
	r_id.set(255);
	golden_id = r_id.out;
	inf.D     = {8'b0, golden_id};
    repeat(1) @(negedge clk);
	inf.id_valid = 'b0;
	inf.D        = 'dx;
end
endtask






task give_act; begin
	repeat(1) @(negedge clk);
	inf.act_valid = 'b1;
	r_act.randomize();
	golden_act = r_act.ran_act;
	inf.D     = {12'b0, golden_act};
    repeat(1) @(negedge clk);
	inf.act_valid = 'b0;
	inf.D         = 'dx;
end
endtask


task give_act_seed; begin
	repeat(1) @(negedge clk);
	inf.act_valid = 'b1;
	inf.D     = {12'b0, Seed};
    repeat(1) @(negedge clk);
	inf.act_valid = 'b0;
	inf.D         = 'dx;
end
endtask

task give_act_water; begin
	repeat(1) @(negedge clk);
	inf.act_valid = 'b1;
	inf.D     = {12'b0, Water};
    repeat(1) @(negedge clk);
	inf.act_valid = 'b0;
	inf.D         = 'dx;
end
endtask

task give_act_reap; begin
	repeat(1) @(negedge clk);
	inf.act_valid = 'b1;
	inf.D     = {12'b0, Reap};
    repeat(1) @(negedge clk);
	inf.act_valid = 'b0;
	inf.D         = 'dx;
end
endtask

task give_act_steal; begin
	repeat(1) @(negedge clk);
	inf.act_valid = 'b1;
	inf.D     = {12'b0, Steal};
    repeat(1) @(negedge clk);
	inf.act_valid = 'b0;
	inf.D         = 'dx;
end
endtask

task give_check_deposit; begin
	repeat(1) @(negedge clk);
	inf.act_valid = 'b1;
	inf.D         = {12'b0, 4'b1000};
    repeat(1) @(negedge clk);
	inf.act_valid = 'b0;
	inf.D         = 'dx;
end
endtask

task give_crop; begin
	repeat(1) @(negedge clk);
	inf.cat_valid = 'b1;
	r_crop.randomize();
	golden_crop = r_crop.ran_crop;
	inf.D       = {12'b0, golden_crop};
    repeat(1) @(negedge clk);
	inf.cat_valid = 'b0;
	inf.D         = 'dx;
end
endtask

task give_water; begin
	repeat(1) @(negedge clk);
	inf.amnt_valid = 'b1;
	r_water.randomize();
	golden_water = r_water.ran_water;
	inf.D       = {golden_water};
    repeat(1) @(negedge clk);
	inf.amnt_valid = 'b0;
	inf.D          = 'dx;
end
endtask

task give_water_0; begin
	repeat(1) @(negedge clk);
	inf.amnt_valid = 'b1;
	r_water.randomize();
	golden_water = r_water.ran_water_0;
	// $display("%d",golden_water);
	inf.D       = {golden_water};
    repeat(1) @(negedge clk);
	inf.amnt_valid = 'b0;
	inf.D          = 'dx;
end
endtask

task give_water_1; begin
	repeat(1) @(negedge clk);
	inf.amnt_valid = 'b1;
	r_water.randomize();
	golden_water = r_water.ran_water_1;
	inf.D       = {golden_water};
    repeat(1) @(negedge clk);
	inf.amnt_valid = 'b0;
	inf.D          = 'dx;
end
endtask
task give_water_2; begin
	repeat(1) @(negedge clk);
	inf.amnt_valid = 'b1;
	r_water.randomize();
	golden_water = r_water.ran_water_2;
	inf.D       = {golden_water};
    repeat(1) @(negedge clk);
	inf.amnt_valid = 'b0;
	inf.D          = 'dx;
end
endtask

task give_water_3; begin
	repeat(1) @(negedge clk);
	inf.amnt_valid = 'b1;
	r_water.randomize();
	golden_water = r_water.ran_water_3;
	inf.D       = {golden_water};
    repeat(1) @(negedge clk);
	inf.amnt_valid = 'b0;
	inf.D          = 'dx;
end
endtask

task give_water_4; begin
	repeat(1) @(negedge clk);
	inf.amnt_valid = 'b1;
	r_water.randomize();
	golden_water = r_water.ran_water_4;
	inf.D       = {golden_water};
    repeat(1) @(negedge clk);
	inf.amnt_valid = 'b0;
	inf.D          = 'dx;
end
endtask

task give_water_5; begin
	repeat(1) @(negedge clk);
	inf.amnt_valid = 'b1;
	r_water.randomize();
	golden_water = r_water.ran_water_6;
	inf.D       = {golden_water};
    repeat(1) @(negedge clk);
	inf.amnt_valid = 'b0;
	inf.D          = 'dx;
end
endtask



// id_seed_task
task id_seed_task; begin
	repeat(1) @(negedge clk);
	give_id;
	give_act_seed;
	give_crop;
	give_water;
end
endtask
// id_water_task
task id_water_task; begin
	repeat(1) @(negedge clk);
	give_id;
	give_act_water;
	give_water;
end
endtask
// id_reap_task
task id_reap_task; begin
	repeat(1) @(negedge clk);
	give_id;
	give_act_reap;
end
endtask
// id_steal_task
task id_steal_task; begin
	repeat(1) @(negedge clk);
	give_id;
	give_act_steal;
end
endtask

// seed_task
task seed_task; begin
	repeat(1) @(negedge clk);
	// seed-cat_valid-amnt_valid
	give_act_seed;
	give_crop;
	give_water;
end
endtask
// water_task
task water_task; begin
	repeat(1) @(negedge clk);
	// water-amnt_valid
	give_act_water;
	give_water;
end
endtask
// reap_task
task reap_task; begin
	repeat(1) @(negedge clk);
	// reap-only act_valid
	give_act_reap;
end
endtask
// steal_task
task steal_task; begin
	repeat(1) @(negedge clk);
	// steal-only act_valid
	give_act_steal;
end
endtask

task congratulations; begin
    $display("********************************************************************");
    $display("                        \033[0;38;5;219mCongratulations!\033[m      ");
    $display("                 \033[0;38;5;219mYou have passed all patterns!\033[m");
    $display("                 \033[0;38;5;219mTotal time: %d \033[m",$time);
    $display("********************************************************************");
    // image_.success;
	repeat(2) @(negedge clk);
    $finish;
end
endtask

endprogram
