`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/05 16:10:35
// Design Name: 
// Module Name: INF
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   2020 ICLAB Fall Course
//   Lab09      : HF
//   Author     : Lien-Feng Hsu
//                
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : INF.sv
//   Module Name : INF
//   Release version : v1.0 (Release Date: May -2020)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

interface INF(input clk);
	import      usertype::*;
	logic 	rst_n ; 
	logic   act_valid;
	logic   id_valid;
	logic   cat_valid;
	logic   amnt_valid;
	DATA  	D;  
	
	logic   	out_valid;
	logic 		complete;
	Error_Msg 	err_msg;
	logic[31:0] out_deposit;
	logic[31:0] out_info;
	
	logic [7:0]  C_addr;
	logic [31:0] C_data_w;
	logic [31:0] C_data_r;
	logic C_in_valid;
	logic C_out_valid;
	logic C_r_wb;
	
	logic   AR_READY, R_VALID, AW_READY, W_READY, B_VALID,
	        AR_VALID, R_READY, AW_VALID, W_VALID, B_READY;
	logic [1:0]	 R_RESP, B_RESP;
    logic [31:0] R_DATA, W_DATA;
	logic [16:0] AW_ADDR, AR_ADDR;

    modport PATTERN(
	    //code here
	    output rst_n,
	    output id_valid,
	    output act_valid,
	    output cat_valid,
	    output amnt_valid,
	    output D,
	    input out_valid,
	    input err_msg,
	    input complete,
	    input out_info,
	    input out_deposit
    );
	
    modport DRAM(
	    //code here
	    output AR_READY,
	    output R_VALID,
	    output R_DATA,
	    output R_RESP,
	    output AW_READY,
	    output W_READY,
	    output B_VALID,
	    output B_RESP,
	    input AR_VALID,
	    input AR_ADDR,
	    input R_READY,
	    input AW_VALID,
	    input AW_ADDR,
	    input W_VALID,
	    input W_DATA,
	    input B_READY
    );
	
    modport farm_inf(
	    //code here
	    input rst_n,
	    input id_valid,
	    input act_valid,
	    input cat_valid,
	    input amnt_valid,
	    input D,
	    input C_out_valid,
	    input C_data_r,
	    output out_valid,
	    output err_msg,
	    output complete,
	    output out_info,
	    output out_deposit,
	    output C_addr,
	    output C_data_w,
	    output C_in_valid,
	    output C_r_wb
	);
		
    modport bridge_inf(
	    //code here
	    input rst_n,
	    input C_addr,
	    input C_data_w,
	    input C_in_valid,
	    input C_r_wb,
	    input AR_READY,
	    input R_VALID,
	    input R_DATA,
	    input R_RESP,
	    input AW_READY,
	    input W_READY,
	    input B_VALID,
	    input B_RESP,
	    output C_out_valid,
	    output C_data_r,
	    output AR_VALID,
	    output AR_ADDR,
	    output R_READY,
	    output AW_VALID,
	    output AW_ADDR,
	    output W_VALID,
	    output W_DATA,
	    output B_READY
    );
	
	modport PATTERN_farm(
	    //code here
	    output rst_n,
	    output id_valid,
	    output act_valid,
	    output cat_valid,
	    output amnt_valid,
	    output D,
	    output C_out_valid,
	    output C_data_r,
	    input out_valid,
	    input err_msg,
	    input complete,
	    input out_info,
	    input out_deposit,
	    input C_addr,
	    input C_data_w,
	    input C_in_valid,
	    input C_r_wb
    );

	modport PATTERN_bridge(
	    //code here
	    output rst_n,
	    output C_addr,
	    output C_data_w,
	    output C_in_valid,
	    output C_r_wb,
	    output AR_READY,
	    output R_VALID,
	    output R_DATA,
	    output R_RESP,
	    output AW_READY,
	    output W_READY,
	    output B_VALID,
	    output B_RESP,
	    input C_out_valid,
	    input C_data_r,
	    input AR_VALID,
	    input AR_ADDR,
	    input R_READY,
	    input AW_VALID,
	    input AW_ADDR,
	    input W_VALID,
	    input W_DATA,
	    input B_READY
    );

endinterface
