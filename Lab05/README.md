# 2021_Spring_NCTU_ICLAB
NCTU 2021 Spring Integrated Circuit Design Laboratory (ICLAB)

## Course Content
Macros and SRAM (generate)

## Design
Lab05 Exercise  
Matrix Computation (MC)

| Input | Description |
| --- | --- |
| clk | Clock. |
| rst_n | Asynchronous active-low reset. |
| in_valid | High when input signals are valid. |
| in_data | Element of input matrix. It will be sent in raster scan order continuously.<br> `The elements are unsigned integers. 0 ≤ in_data < p,p = 2^31 − 1 = 0x7fffffff = 2147483647(10)` |
| size | The signal will be given at the first cycle of in_valid and only given with set-up operation. It defines which size to be use to set up or reset matrix.<br>2’b00: 2x2. 2’b01: 4x4. 2’b10: 8x8. 2’b11: 16x16. |
| action | The signal will be given at the first cycle of in_valid. The definition is as following:<br>3’b000: Set-up. 3’b001: Addition. 3’b010: Multiplication.3’b011: Transpose. 3’b100: Mirror. 3’b101: Rotate counter-clockwise. |

| Output | Description |
| --- | --- |
| out_valid | High when out is valid. It cannot be overlapped with in_valid signal. |
| out | Result matrix outputted in raster scan order.<br>`The elements are unsigned integers. 0 ≤ in_data < p,p = 2^31 − 1 = 0x7fffffff = 2147483647(10)`<br>If operation is Transpose, Mirror, or Rotate counterclockwise, it must be zero. |


## Time
2021.03.31 - 2021.04.04

## Notes
+ Macros and SRAM
+ SRAM generation
+ read SRAM, write SRAM
+ lookup table
+ Remember to put the data in the SRAM file first, so that the read data from the SRAM do not become unknown.



