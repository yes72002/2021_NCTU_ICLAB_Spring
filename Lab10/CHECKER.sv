//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//
//   File Name   : CHECKER.sv
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
//`include "Usertype_PKG.sv"

module Checker(input clk, INF.CHECKER inf);
import usertype::*;

Action action_store;

//covergroup Spec1 @();
//	
//       finish your covergroup here
//	
//	
//endgroup

//declare other cover group



//declare the cover group 
//Spec1 cov_inst_1 = new();
// Spec1
covergroup Spec1 @(posedge inf.amnt_valid);
	AMNT: coverpoint inf.D.d_amnt[15:0]{
		bins amnt1 = {[    0:12000]};
		bins amnt2 = {[12001:24000]};
		bins amnt3 = {[24001:36000]};
		bins amnt4 = {[36001:48000]};
		bins amnt5 = {[48001:60000]};
		option.at_least = 100;
	}
	option.per_instance = 1;
endgroup

// Spec2
covergroup Spec2 @(posedge inf.id_valid);
	ID: coverpoint inf.D.d_id[0]{
		bins id [] = {[0:254]};
		option.at_least = 10;
		// option.auto_bin_max = 255;
	}
	option.per_instance = 1;
endgroup

// Spec3
covergroup Spec3 @(posedge inf.act_valid);
	ACTION: coverpoint inf.D.d_act[0]{
		// bins t [] = ({Seed,Water,Reap,Steal,Check_dep}=>{Seed,Water,Reap,Steal,Check_dep}); // can't work
		// bins t [] = ({4'd1,4'd3,4'd2,4'd4,4'd8}=>{4'd1,4'd3,4'd2,4'd4,4'd8}); // can't work
		bins t1  = (Seed  => Seed);
		bins t2  = (Seed  => Water);
		bins t3  = (Seed  => Reap);
		bins t4  = (Seed  => Steal);
		bins t5  = (Seed  => Check_dep);
		bins t6  = (Water => Seed);
		bins t7  = (Water => Water);
		bins t8  = (Water => Reap);
		bins t9  = (Water => Steal);
		bins t10 = (Water => Check_dep);
		bins t11 = (Reap  => Seed);
		bins t12 = (Reap  => Water);
		bins t13 = (Reap  => Reap);
		bins t14 = (Reap  => Steal);
		bins t15 = (Reap  => Check_dep);
		bins t16 = (Steal => Seed);
		bins t17 = (Steal => Water);
		bins t18 = (Steal => Reap);
		bins t19 = (Steal => Steal);
		bins t20 = (Steal => Check_dep);
		bins t21 = (Check_dep => Seed);
		bins t22 = (Check_dep => Water);
		bins t23 = (Check_dep => Reap);
		bins t24 = (Check_dep => Steal);
		bins t25 = (Check_dep => Check_dep);
		option.at_least = 10;
		// option.at_least = 1;
	}
	option.per_instance = 1;
endgroup

// Spec4
covergroup Spec4 @(posedge inf.out_valid);
	ERR_MSG: coverpoint inf.err_msg{
		bins e0 [] = {Is_Empty,Not_Empty,Has_Grown,Not_Grown};
		option.at_least = 100;
	}
	option.per_instance = 1;
endgroup

//declare the cover group 
Spec1 cov_inst_1 = new();
Spec2 cov_inst_2 = new();
Spec3 cov_inst_3 = new();
Spec4 cov_inst_4 = new();

//************************************ below assertion is to check your pattern ***************************************** 
//                                          Please finish and hand in it
// This is an example assertion given by TA, please write other assertions at the below
// assert_interval : assert property ( @(posedge clk)  inf.out_valid |=> inf.id_valid == 0)
// else
// begin
// 	$display("Assertion X is violated");
// 	$fatal; 
// end

//write other assertions

// Assertion 1 is violated
assert_reset : assert property ( @(inf.rst_n)  inf.rst_n == 0 |-> ((inf.out_valid == 0)&&(inf.complete == 0)&&(inf.err_msg == 0)&&(inf.out_info == 0)&&(inf.out_deposit == 0)))
else begin
	$display("Assertion 1 is violated");
	$fatal;
end
// Assertion 2 is violated
assert_complete: assert property( @(posedge clk) inf.complete == 1 |-> inf.err_msg == No_Err) // 0
else begin
	$display("Assertion 2 is violated");
	$fatal;
end

// action_store
always@(posedge clk or negedge inf.rst_n) begin
	if(!inf.rst_n)
		action_store <= 0;
	else if(inf.act_valid)
		action_store <= inf.D.d_act[0];
	else
		action_store <= action_store;
end

// Assertion 3 is violated
assert_is_check_deposit: assert property( @(posedge clk) (action_store == Check_dep)&&(inf.out_valid == 1) |-> (inf.out_info == 0))
else begin
	$display("Assertion 3 is violated");
	$fatal;
end

// Assertion 4 is violated
assert_isnot_check_deposit: assert property( @(posedge clk) (action_store !== Check_dep)&&(inf.out_valid == 1) |-> (inf.out_deposit == 0))
else begin
	$display("Assertion 4 is violated");
	$fatal;
end

// Assertion 5 is violated
// assert_outvalid: assert property( @(posedge clk) (inf.out_valid) ##1 (!inf.out_valid))
assert_outvalid: assert property( @(posedge clk) (inf.out_valid) |=> (!inf.out_valid))
else begin
	$display("Assertion 5 is violated");
	$fatal;
end

// Assertion 6 is violated
// assert_gap_id_act: assert property( @(posedge clk) inf.id_valid ##[1:$] inf.act_valid)
assert_gap_id_act: assert property( @(posedge clk) (inf.id_valid) |=> (!inf.act_valid))
else begin
	$display("Assertion 6 is violated");
	$fatal;
end

// Assertion 7 is violated
// assert_gap_cat_amnt: assert property( @(posedge clk) (action_store == Seed)&&(inf.cat_valid) ##[1:$] (inf.amnt_valid))
assert_gap_cat_amnt: assert property( @(posedge clk) (action_store == Seed)&&(inf.cat_valid) |=> (!inf.amnt_valid))
else begin
	$display("Assertion 7 is violated");
	$fatal;
end

// Assertion 8 is violated
assert_four_valid_1: assert property( @(posedge clk) (inf.id_valid) |-> ((!inf.act_valid)&&(!inf.cat_valid)&&(!inf.amnt_valid)))
else begin
	$display("Assertion 8 is violated");
	$fatal;
end
assert_four_valid_2: assert property( @(posedge clk) (inf.act_valid) |-> ((!inf.id_valid)&&(!inf.cat_valid)&&(!inf.amnt_valid)))
else begin
	$display("Assertion 8 is violated");
	$fatal;
end
assert_four_valid_3: assert property( @(posedge clk) (inf.cat_valid) |-> ((!inf.id_valid)&&(!inf.act_valid)&&(!inf.amnt_valid)))
else begin
	$display("Assertion 8 is violated");
	$fatal;
end
assert_four_valid_4: assert property( @(posedge clk) (inf.amnt_valid) |-> ((!inf.id_valid)&&(!inf.act_valid)&&(!inf.cat_valid)))
else begin
	$display("Assertion 8 is violated");
	$fatal;
end

// Assertion 9 is violated
// assert_next_operation: assert property( @(posedge clk) (inf.out_valid) ##[2:10] ((inf.id_valid)||(inf.act_valid)))
assert_next_operation_1: assert property( @(posedge clk) (inf.out_valid) |=> (!inf.id_valid)[*1])
// assert_next_operation_1: assert property( @(posedge clk) (inf.out_valid) |=> ##[2:10] (!inf.id_valid)[*1])
else begin
	$display("Assertion 9 is violated");
	$fatal;
end
assert_next_operation_2: assert property( @(posedge clk) (inf.out_valid) |=> (!inf.act_valid)[*1])
// assert_next_operation_2: assert property( @(posedge clk) (inf.out_valid) |=> ##[2:10] (!inf.act_valid)[*1])
else begin
	$display("Assertion 9 is violated");
	$fatal;
end

// Assertion 10 is violated
assert_latency: assert property( @(posedge clk) (inf.act_valid) |=> ##[1:1200] (inf.out_valid))
// assert_latency: assert property( @(posedge clk) (inf.act_valid) |=> ##[30:31] (inf.out_valid))
// assert_latency: assert property( @(posedge clk) (inf.act_valid) |=> ##19 ( inf.out_valid))
else begin
	$display("Assertion 10 is violated");
	$fatal;
end


endmodule