# 2021_Spring_NCTU_ICLAB
NCTU 2021 Spring Integrated Circuit Design Laboratory (ICLAB)

## Course Content
Testbench and Pattern

## Design
Lab03 Exercise  
Sudoku (SD)

| Input | Description |
| --- | --- |
| clk | clock |
| rst_n | asynchronous active-low reset |
| in_valid | high when **in** is pattern |
| in | 4’d0: the position is blank, need to be filled in. <br> 4’d1~4’d9: the position is filled with that digit. |

| Output | Description |
| --- | --- |
| out_valid | high when output is valid |
| out | `only range from 4’d1 to 4’d10` <br> 4’d10: Indicates that there are no solutions. |


## Time
2021.03.17 - 2021.03.21

## Notes
+ Testbench and Pattern
+ initial
+ function, task
+ @(negedge clk)
+ repeat(2)@(negedge clk)
+ $display, $finish
+ Be careful, my pattern was not perfectly passed in the demo, do not entirely copy.


