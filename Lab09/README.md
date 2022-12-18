# 2021_Spring_NCTU_ICLAB
NCTU 2021 Spring Integrated Circuit Design Laboratory (ICLAB)

## Course Content
SystemVerilog and Advanced Testbench

## Design
Lab09 Exercise  
Happy Farm (farm, bridge)

| Input | Description |
| --- | --- |
| clk | Clock. |
| rst_n | Asynchronous active-low reset. <br> Every output signal should be zero after rst_n.|
| id_valid | High when user enter land id. |
| act_valid | High when user enter action. |
| cat_valid | High when user enter crop category to seed. |
| amnt_valid | High when user enter water amount. |
| D | Represents the contents of current input. |
| C_out_valid | High when data from DRAM is ready. |
| C_data_r | The returned data from DRAM. |

| Output | Description |
| --- | --- |
| out_valid | Should set to high when your output is ready. <br> out_valid will be high for only one cycle. |
| err_msg | err_msg will be 4’0000(No error) if operation is complete, else it needs to be corresponding value. |
| complete | 1’b1: operation complete; <br> 1’b0: some error occurred, so the status of DRAM  won’t change. |
| out_info | Show information of land. |
| out_deposit | Show deposit. |
| C_addr | Indicates which address we want to access |
| C_data_w | The data to over write DRAM, including land id, land status, crop category, water amount. |
| C_in_valid | errHigh when farm system is ready to communicate with bridge_m |
| C_r_wb | 1’b1: Read DRAM. 1’b0: Write DRAM. |

## Time
2021.05.05 - 2021.05.09

## Notes
+ SystemVerilog
+ Advanced Testbench
+ interface
+ logic
+ always_comb, always_ff


