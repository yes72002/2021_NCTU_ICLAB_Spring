//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//
//   File Name   : TESTBED.sv
//   Module Name : TESTBED
//   Release version : v1.0 (Release Date: May-2020)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

`timescale 1ns/1ps

`include "Usertype_PKG.sv"
`include "INF.sv"
`include "PATTERN.sv"
`include "../00_TESTBED/pseudo_DRAM.sv"
`include "CHECKER.sv"

`ifdef RTL
  `include "bridge.sv"
  `include "farm.sv"
`endif

module TESTBED;
  
  parameter simulation_cycle = 15.0;
  reg  SystemClock;

  INF  inf(SystemClock);
  PATTERN test_p(.clk(SystemClock), .inf(inf.PATTERN));
  pseudo_DRAM dram_r(.clk(SystemClock), .inf(inf.DRAM));
  Checker check_inst (.clk(SystemClock), .inf(inf.CHECKER));
  
  `ifdef RTL
	bridge    dut_b(.clk(SystemClock), .inf(inf.bridge_inf) );
	farm   dut_p(.clk(SystemClock), .inf(inf.farm_inf) );
  `endif
  
 //------ Generate Clock ------------
  initial begin
    SystemClock = 0;
	#30
    forever begin
      #(simulation_cycle/2.0)
        SystemClock = ~SystemClock;
    end
  end
  
//------ Dump VCD File ------------  
initial begin
  `ifdef RTL
    $fsdbDumpfile("HF.fsdb");
    $fsdbDumpvars(0,"+all");
    $fsdbDumpSVA;
  `endif
end

endmodule