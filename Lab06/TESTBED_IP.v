//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   2021 ICLAB Spring Course
//   Lab06       : CheckSum Soft IP
//   Author      : Huan-Jung Lee (alexli1205.ee09g@nctu.edu.tw)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : TESTBED.v
//   Module Name : TESTBED
//   Release version : v1.0
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

`timescale 1ns/1ps

`ifdef RTL
    `include "PATTERN_IP.v"
    `include "CS_IP_Demo.v"
`endif

`ifdef GATE
    `include "PATTERN_IP.v"
    `include "CS_IP_Demo_SYN.v"
`endif

module TESTBED;

parameter WIDTH_DATA = 256, WIDTH_RESULT = 1;

//Connection wires
wire [(WIDTH_DATA-1):0]     data;
wire [(WIDTH_RESULT-1):0]   result;
wire	                    clk,rst_n;
wire	                    in_valid,out_valid;


initial begin
    `ifdef RTL
        $fsdbDumpfile("CS_IP_Demo.fsdb");
        $fsdbDumpvars(0,"+mda");
    `endif
    `ifdef GATE
        $sdf_annotate("CS_IP_Demo_SYN.sdf",My_IP);
        $fsdbDumpfile("CS_IP_Demo_SYN.fsdb");
        $fsdbDumpvars(0,"+mda");
    `endif
end

`ifdef RTL
	CS_IP_Demo #(.WIDTH_DATA(WIDTH_DATA), .WIDTH_RESULT(WIDTH_RESULT)) My_IP(
        .data(data),
        .in_valid(in_valid),
        .clk(clk),
        .rst_n(rst_n),
        .result(result),
        .out_valid(out_valid)
	);

	PATTERN_IP #(.WIDTH_DATA(WIDTH_DATA), .WIDTH_RESULT(WIDTH_RESULT)) My_PATTERN(
        .data(data),
        .in_valid(in_valid),
        .clk(clk),
        .rst_n(rst_n),
        .result(result),
        .out_valid(out_valid)
	);

`elsif GATE
	CS_IP_Demo My_IP(
        .data(data),
        .in_valid(in_valid),
        .clk(clk),
        .rst_n(rst_n),
        .result(result),
        .out_valid(out_valid)
	);

	PATTERN_IP #(.WIDTH_DATA(WIDTH_DATA), .WIDTH_RESULT(WIDTH_RESULT)) My_PATTERN(
        .data(data),
        .in_valid(in_valid),
        .clk(clk),
        .rst_n(rst_n),
        .result(result),
        .out_valid(out_valid)
	);
`endif


endmodule
