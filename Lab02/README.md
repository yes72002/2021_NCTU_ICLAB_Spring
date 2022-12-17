# 2021_Spring_NCTU_ICLAB
NCTU 2021 Spring Integrated Circuit Design Laboratory (ICLAB)

## Course Content
Sequential Circuit Design

## Design
Lab02 Exercise  
String match engine
 
| Input | Description |
| --- | --- |
| clk | clock |
| rst_n | asynchronous active-low reset |
| ispattern | high when input is pattern |
| isstring | high when input is string |
| chardata | the character sequence of pattern or string |

| Output | Description |
| --- | --- |
| out_valid | high when output is valid |
| match | high if pattern and string are matched |
| match_index | output the first matched position if pattern and string are matched, <br> otherwise output 0 |

## Time
2021.03.10 - 2021.03.14

## Notes
+ Sequential Circuit Design
+ DFF, flag
+ shift register store input
+ Finite State Machine (FSM)
+ use hardware thinking

