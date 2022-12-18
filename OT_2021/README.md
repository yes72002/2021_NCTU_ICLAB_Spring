# 2021_Spring_NCTU_ICLAB
NCTU 2021 Spring Integrated Circuit Design Laboratory (ICLAB)

## Course Content
Synthesis Flow with Synopsys Design Compiler

## Design
Online Test  
Length, angles of Triangle (OT)

| Input | Description |
| --- | --- |
| clk | Clock. |
| rst_n | Asynchronous active-low reset. |
| in_valid | Raised for `THREE` cycles to indicate coor_x, coor_y, and mode signals are valid. |
| coord_x | Unsigned integer. X value in Cartesian coordinates. |
| coord_y | Unsigned integer. Y value in Cartesian coordinates. |

| Output | Description |
| --- | --- |
| out_valid | Raised for `THREE` cycles to indicate output. It should be `LOW` after reset. |
| out_length | Unsigned Fixed-point format. <br> [12:7] is integer part while [6:0] is fractional part. |
| out_incenter | Unsigned Fixed-point format. <br> [12:7] is integer part while [6:0] is fractional part. |


## Time
2021.04.17

## Notes
+ IP
+ fractions calculations
+ time limit




