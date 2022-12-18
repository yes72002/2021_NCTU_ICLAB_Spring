# 2021_Spring_NCTU_ICLAB
NCTU 2021 Spring Integrated Circuit Design Laboratory (ICLAB)

## Course Content
Advanced Sequential Circuit Design (Timing & IP)

## Design
Lab04 Exercise  
Artificial Neural Network (NN)

| Input | Description |
| --- | --- |
| clk | clock |
| rst_n | asynchronous active-low reset |
| in_valid_d | high when data_point is valid |
| in_valid_t | high when target is valid |
| in_valid_w1 | high when weight1 is valid |
| in_valid_w2 | high when weight2 is valid |
| data_point | the input data point, 4 data points represent a data<br>using IEEE-754 floating number format |
| target | the target for current data<br>using IEEE-754 floating number format |
| weight1 | the weight for first layer<br>using IEEE-754 floating number format |
| weight2 | the weight for second layer<br>using IEEE-754 floating number format |

| Output | Description |
| --- | --- |
| out_valid | high when output is valid |
| out | the forward result for current data<br>using IEEE-754 floating number format |


## Time
2021.03.24 - 2021.03.28

## Notes
+ Advanced Sequential Circuit Design
+ Timing & IP
+ IEEE floating point number IP
+ IEEE-754
+ pipeline


