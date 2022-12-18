# 2021_Spring_NCTU_ICLAB
NCTU 2021 Spring Integrated Circuit Design Laboratory (ICLAB)

## Course Content
Low Power Design

## Design
Lab08 Exercise  
Series Processing (SP)

| Input | Description |
| --- | --- |
| clk | Clock. |
| rst_n | Asynchronous active-low reset. |
| cg_en | If cg_en is high, the processing blocks should execute clock gating. Otherwise, if cg_en is low, the processing blocks follow clk. <br>`There is no cg_en signal in SP_wocg.v` |
| in_valid | High when input signals are valid. |
| in_data | Input the elements of the sequence. in_data will be sequentially sent as a0, a1, a2, a3, a4, a5, for 6 cycles. <br>`The elements are unsigned integers. 1 ≤ in_data < p, p = 2^9 − 3 = 509.` |
| in_mode | The signal will be given at the first cycle of in_valid.<br>in_mode [0] = 1 indicates modular multiplicative inverse.<br>in_mode [1] = 1 indicates modular multiplication.<br>in_mode [2] = 1 indicates sorting from low to high |

| Output | Description |
| --- | --- |
| out_valid | High when output is valid. It cannot be overlapped with in_valid signal. <br>Should be set to low after reset. |
| out_data | Sequentially output the resulting number, 𝑒0, 𝑒1, 𝑒2, 𝑒3, 𝑒4, 𝑒5, for 6 cycles. <br>`1 ≤ out_data < p, p = 29 − 3 = 509.` |


## Time
2021.04.28 - 2021.05.02

## Notes
+ Low Power Design
+ Static power, dynamic power
+ Clock gating
+ Sequential equivalency checking tool: Cadence JasperGold





