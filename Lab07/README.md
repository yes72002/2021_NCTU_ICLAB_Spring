# 2021_Spring_NCTU_ICLAB
NCTU 2021 Spring Integrated Circuit Design Laboratory (ICLAB)

## Course Content
Static Timing Analysis

## Design
Lab07 Exercise  
Polish Notation (PN)

| Input | Description |
| --- | --- |
| clk_1 | Positive edge trigger clock by clock 1 with clock period 20ns. (sent into CLK_1_MODULE) |
| clk_2 | Positive edge trigger clock by clock 2 with clock period 6ns. (sent into CLK_1_MODULE) (sent into CLK_2_MODULE) |
| clk_3 | Positive edge trigger clock by clock 3 with clock period 10ns. (sent into CLK_2_MODULE) (sent into CLK_3_MODULE) |
| rst_n | Asynchronous active-low reset. (sent into all three modules) |
| in_valid | High when in, operator, mode are valid. |
| mode | 1'b0: prefix expression; 1'b1: postfix expression (sent into CLK_1_MODULE) |
| operator | 1'b0: in is an operand; 1'b1: in is an operator (sent into CLK_1_MODULE) |
| in | When operator is 1'b0: <br> 3'b000~3'b111: the number of the operand.<br>When operator is 1'b1: 3'b000: +<br>3'b001: -<br>3'b010: * <br> 3'b011: $ =>a$b=\|𝑎 + 𝑏\| <br> 3'b100: @=>a@b=2*(a-b) <br> (sent into CLK_1_MODULE)|

| Output | Description |
| --- | --- |
| out_valid | High when out is valid. (output from CLK_3_MODULE) |
| out |The answer of the expression. (output from CLK_3_MODULE) |


## Time
2021.04.21 - 2021.04.25

## Notes
+ Static Timing Analysis (STA)
+ Multicycle Path Specification
+ Clock Domain Crossing (CDC)
+ Metastability
+ generate syntax
+ When I used the generate block to build some functions, I met some tool simulation bugs, that caused I passed on my computer but failed on TA's computer, so I recommend not using the generate block to complete complex functions.




